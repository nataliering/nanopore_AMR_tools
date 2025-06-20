import pandas as pd
import re
import sys

"""
This script processes AMR tool outputs to match gene names
with the antibiotic class to which they may convery resistnace. 
The script assumes your AMR tool output has been run through Hamronization.

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
    - "ncbi_reference_table.tsv" from the NCBI reference gene catalogue (https://www.ncbi.nlm.nih.gov/pathogens/refgene/). 
      The version I used can be downloaded from this github (https://github.com/nataliering/nanopore_AMR_tools) or you 
      can get the latest version by downloading the table from NCBI for yourself

Output:
  the same hamronization_output.tsv file you input, but with predicted
  classes in the antibiotic_class column.
"""

accession = sys.argv[1]

def clean_gene_name(gene):
    # Remove prefixes like (xxx) and brackets, then split by underscores
    gene_parts = re.sub(r'^\([A-Za-z]+\)\s*', '', gene).lower().split('_')
    cleaned_parts = []

    for part in gene_parts:
        part = re.sub(r'\((.*?)\)', r'\1', part)
        if part.startswith('bla'):
            part = part[3:]  # Remove 'bla' prefix
        cleaned_parts.append(part)

    return cleaned_parts

def clean_ncbi_gene(gene):
    if isinstance(gene, str):
        gene = re.sub(r'\((.*?)\)', r'\1', gene.lower())
        if gene.startswith('bla'):
            gene = gene[3:]  # Remove 'bla' prefix
        return gene
    return ""

def update_predicted_class(tool_output, ncbi_dict):
    if 'antibiotic_class' not in tool_output.columns:
        tool_output['antibiotic_class'] = ""

    tool_output['antibiotic_class'] = tool_output['antibiotic_class'].astype(str)

    for index, row in tool_output.iterrows():
        predicted_classes = set()

        gene_names = set()
        for col in ['gene_symbol', 'gene_name']:
            if pd.notna(row[col]):
                gene_names.update(clean_gene_name(str(row[col])))

        for ncbi_gene, class_name in ncbi_dict.items():
            ncbi_gene_clean = clean_ncbi_gene(ncbi_gene)
            for gene_base in gene_names:
                if (
                    len(gene_base) > 2 and
                    len(ncbi_gene_clean) > 2 and
                    (ncbi_gene_clean.startswith(gene_base) or gene_base.startswith(ncbi_gene_clean))
                ):
                    if isinstance(class_name, str):
                        classes = class_name.split(', ')
                        predicted_classes.update(classes)
                        #print(f"Match found: {ncbi_gene_clean} for {gene_names} -> {classes}")

        tool_output.at[index, 'antibiotic_class'] = ', '.join(sorted(predicted_classes)) if predicted_classes else ""
        #print(f"Index {index}: Predicted classes: {predicted_classes}")

    return tool_output

# Load the NCBI table and tool results
ncbi = pd.read_csv('/path/to/ncbi_reference_table.tsv', sep='\t')
ncbi['Gene'] = ncbi['Gene family'].apply(clean_ncbi_gene)
ncbi_dict = ncbi.set_index('Gene')['Class'].to_dict()

tool_results = pd.read_csv(f'{accession}', sep='\t')
updated_results = update_predicted_class(tool_results, ncbi_dict)
updated_results.to_csv(f'{accession}', sep='\t', index=False)
