import pandas as pd
import re
import sys

"""
This script processes AMR tool outputs to match gene names
with known phenotypes from the ResFinder database. The script
assumes your AMR tool output has been run through Hamronization.

This script has been tested with the outputs of:
    -ABRicate (with ncbi, card, argannot, resfinder and megares DBs)
    -starAMR
    -Resfinder
    -AMRFinderPlus
    -c-SSTAR
    -RGI
    -DeepARG
    -AMR++
    
Usage:
    python script_name.py <hamronization_output.tsv>

Dependencies:
    - pandas
    - re
    - sys
    - "phenotypes.txt" from the resfinder database - the version I used can 
    be downloaded from this github (https://github.com/nataliering/nanopore_AMR_tools) 
    or you can get the latest version by downloading the resfinder database files for yourself

Output:
  the same hamronization_output.tsv file you input, but with predicted
  phenotypes in the predicted_phenotypes column.
"""

import pandas as pd
import re
import sys

accession = sys.argv[1]

def clean_gene_name(gene):
    # Remove prefixes and brackets, split by underscores
    gene_parts = re.sub(r'^\([A-Za-z]+\)\s*', '', gene).lower().split('_')
    cleaned_parts = []

    for part in gene_parts:
        # Remove 'bla' prefix if present
        if part.startswith('bla'):
            part = part[3:]
        # Remove content within parentheses
        part = re.sub(r'\((.*?)\)', r'\1', part)
        cleaned_parts.append(part)
	#print(f"Cleaned gene parts: {cleaned_parts}")  # Debugging
    return cleaned_parts

def clean_resfinder_gene(gene):
    # Remove content within parentheses and convert to lowercase
    cleaned_gene = re.sub(r'\((.*?)\)', r'\1', gene.lower())
    # Remove 'bla' prefix if present
    if cleaned_gene.startswith('bla'):
        cleaned_gene = cleaned_gene[3:]
    # Ignore everything after the first underscore
    cleaned_gene = cleaned_gene.split('_')[0]
	#print(f"Cleaned resfinder genes: {cleaned_gene}")  # Debugging
    return cleaned_gene

def update_predicted_phenotype(tool_output, resfinder_dict):
    if 'predicted_phenotype' not in tool_output.columns:
        tool_output['predicted_phenotype'] = ""

    tool_output['predicted_phenotype'] = tool_output['predicted_phenotype'].astype(str)

    for index, row in tool_output.iterrows():
        predicted_antibiotics = set()

        gene_names = set()
        for col in ['gene_symbol', 'gene_name']:
            if pd.notna(row[col]):
                gene_names.update(clean_gene_name(str(row[col])))

        for res_gene, phenotype in resfinder_dict.items():
            res_gene_clean = clean_resfinder_gene(res_gene)
            #print(f"Comparing: {res_gene_clean} with {gene_names}")  # Debugging
            for gene_base in gene_names:
                # Ensure substantial matches only
                if (
                    len(gene_base) > 2 and
                    len(res_gene_clean) > 2 and
                    (gene_base.startswith(res_gene_clean) or res_gene_clean.startswith(gene_base))
                ):
                    antibiotics = phenotype.split(', ')
                    predicted_antibiotics.update(antibiotics)
                    #print(f"Match found: {res_gene_clean} for {gene_base} -> {antibiotics}")

        tool_output.at[index, 'predicted_phenotype'] = ', '.join(sorted(predicted_antibiotics)) if predicted_antibiotics else ""

    return tool_output

# Load the phenotypes table and tool results
resfinder = pd.read_csv('/path/to/phenotypes.txt', sep='\t')
resfinder['Gene'] = resfinder['Gene_accession no.'].apply(clean_resfinder_gene)
resfinder_dict = resfinder.set_index('Gene')['Phenotype'].to_dict()

tool_results = pd.read_csv(f'{accession}', sep='\t')
updated_results = update_predicted_phenotype(tool_results, resfinder_dict)
updated_results.to_csv(f'{accession}', sep='\t', index=False)

