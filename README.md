# A systematic comparison of tools available for predicting antimicrobial resistance using nanopore sequencing reads and paired phenotyping results
Code and commands used in our manuscript, "A systematic comparison of tools available for predicting antimicrobial resistance using nanopore sequencing reads and paired phenotyping results"


## PLEASE NOTE: This is still a work-in-progress. Message Natalie Ring for further information.

## Abstract
Antimicrobial resistance is of growing important in numerous settings around the globe, from healthcare to agriculture. There is a pressing need to ensure that antimicrobials are used appropriately: to target the right microbes, at the right time. In the healthcare setting, the appropriate antimicrobial is usually selected after patient samples have been cultured, and antimicrobial sensitivity testing conducted. However, these tests can take several days, from sample collection to diagnosis and antimicrobial prescription. In the meantime, inappropriate, or broad-spectrum, antimicrobials may be used. Alternatives to culture-based diagnosis are therefore increasingly being tested. One alternative is the use of nanopore DNA sequencing to identify pathogens present in patient samples, followed by bioinformatic analysis of the sequencing data to predict potential antimicrobial resistance present in those pathogens. The major advantage of this approach is its speed, with the ability to produce results in hours instead of days. Thus far, the major disadvantage has been the inconsistency of predicted AMR phenotypes, as demonstrated by recent studies showing that different bioinformatics tools may predict different AMR phenotypes from the same dataset. Here, we sought to identify and understand the differences between these predictions. We gathered nanopore sequencing data from a range of previous publications, specifically selected those datasets for which known AST phenotype calls were available. In addition, we sequenced >100 isolates from our biobank, for which AST results were known. We then analysed these datasets using eleven widely available AMR prediction tools. 


## Commands for tools mentioned in manuscript
Each of the tools we used can be further optimised; we tended to use the default settings in most cases, often exactly as recommended in the tool's README.
### Downloading relevant nanopore datasets in fastq format
**[fasterq-dump (download of reads from SRA)](https://github.com/ncbi/sra-tools)**  
`fasterq-dump ACCESSION_NUMBER --gzip`

### Adaptor trimming
**[Porechop](https://github.com/rrwick/Porechop)**  
`porechop -i INPUT.fastq -o OUTPUT.fastq`


### Genome assembly
**[Flye](https://github.com/fenderglass/Flye)**  
`flye --meta --threads 8 --out-dir OUTPUT_DIRECTORY --nano-raw INPUT.fastq`

**[Minimap2](https://github.com/lh3/Minimap2) and [Miniasm](https://github.com/lh3/Miniasm)**  
minimap2 -x ava-ont -t16 INPUT.fastq INPUT.fastq | gzip -1 > OUTPUT.paf.gz
miniasm -f INPUT.fastq OUTPUT.paf.gz > OUTPUT.gfa
awk '/^S/{print">"$2"\n"$3}' OUTPUT.gfa | fold > OUTPUT.fasta

