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



accession = sys.argv[1]

def clean_gene_name(gene):
    # Remove prefixes like (xxx) and brackets, then split by underscores
    gene_parts = re.sub(r'^\([A-Za-z]+\)\s*', '', gene).lower().split('_')
    # Remove 'bla' prefix and brackets from each part
    cleaned_parts = [re.sub(r'\((.*?)\)', r'\1', part.lstrip('bla')) for part in gene_parts]
    return cleaned_parts

def clean_resfinder_gene(gene):
    cleaned_gene = re.sub(r'\((.*?)\)', r'\1', gene.lower())
    return cleaned_gene.lstrip('bla')

def update_predicted_phenotype(tool_output, resfinder_dict):
    if 'predicted_phenotype' not in tool_output.columns:
        tool_output['predicted_phenotype'] = ""

    # Ensure the column is a string type
    tool_output['predicted_phenotype'] = tool_output['predicted_phenotype'].astype(str)

    for index, row in tool_output.iterrows():
        predicted_antibiotics = set()

        gene_names = set()
        for col in ['gene_symbol', 'gene_name']:
            if pd.notna(row[col]):
                gene_names.update(clean_gene_name(str(row[col])))

        for res_gene, phenotype in resfinder_dict.items():
            res_gene_clean = clean_resfinder_gene(res_gene)
            for gene_base in gene_names:
                if gene_base.startswith(res_gene_clean[:4]) or res_gene_clean.startswith(gene_base):
                    antibiotics = phenotype.split(', ')
                    predicted_antibiotics.update(antibiotics)

        tool_output.at[index, 'predicted_phenotype'] = ', '.join(sorted(predicted_antibiotics)) if predicted_antibiotics else ""

    return tool_output

# Load the phenotypes table and tool results
resfinder = pd.read_csv('/path/to/phenotypes.txt', sep='\t')
resfinder['Gene'] = resfinder['Gene_accession no.'].apply(clean_resfinder_gene)
resfinder_dict = resfinder.set_index('Gene')['Phenotype'].to_dict()

tool_results = pd.read_csv(f'{accession}', sep='\t')
updated_results = update_predicted_phenotype(tool_results, resfinder_dict)
updated_results.to_csv(f'{accession}', sep='\t', index=False)
