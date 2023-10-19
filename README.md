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

### Read filtering
**[Filtlong](https://github.com/rrwick/Filtlong)**  
`filtlong -t 500000000 INPUT.fastq.gz | gzip > OUTPUT.fastq.gz`

### Genome assembly and annotation
**[Flye](https://github.com/fenderglass/Flye)**  
`flye --meta --threads 8 --out-dir OUTPUT_DIRECTORY --nano-raw INPUT.fastq`

**[Minimap2](https://github.com/lh3/Minimap2) and [Miniasm](https://github.com/lh3/Miniasm)**  
`minimap2 -x ava-ont -t16 INPUT.fastq INPUT.fastq | gzip -1 > OUTPUT.paf.gz`                                                                                           

`miniasm -f INPUT.fastq OUTPUT.paf.gz > OUTPUT.gfa`                                                                                                           

`awk '/^S/{print">"$2"\n"$3}' OUTPUT.gfa | fold > OUTPUT.fasta`

**[Prokka](https://github.com/tseemann/Prokka)**                                                                                                            
`prokka --metagenome --cpus 8 --outdir OUTPUT_DIRECTORY --prefix OUTPUT INPUT_ASSEMBLY.fasta`

**[Conversion of Prokka .gff output into format compatible with AMRFinderPlus](https://github.com/ncbi/amr/issues/24)**                                                 
`perl -pe '/^##FASTA/ && exit; s/(\W)Name=/$1OldName=/i; s/ID=([^;]+)/ID=$1;Name=$1/' OUTPUT.gff>  > OUTPUT.for_amrfinder.gff`

### AMR prediction tools                                                                                                                                    
**[ABRicate](https://github.com/tseemann/ABRicate)**                                                                                                     
`abricate --fofn FILE_OF_ASSEMBLY_FILE_NAMES.txt > OUTPUT.tsv`                                                                        

`abricate --summary OUTPUT.tsv > SUMMARY.tsv`

**[abriTAMR](https://github.com/MDU-PHL/abritamr)**                                                                                                     
`abriTAMR run --contigs INPUT_ASSEMBLY.fasta --prefix OUTPUT_DIRECTORY --species SPECIES(where relevant)` 

**[AMRFinderPlus](https://github.com/ncbi/amr)**                                                                                       
`amrfinder -p PROKKA_OUTPUT.faa -n INPUT_ASSEMBLY.fasta -g PROKKA_OUTPUT.for_amrfinder.gff --threads 8 -o OUTPUT_DIRECTORY`

**[c-SSTAR](https://github.com/chrisgulvik/c-SSTAR)**                                                                            
`c-SSTAR -g INPUT_ASSEMBLY.fasta -d /PATH/TO/c-SSTAR/DB/ResGANNOT_srst2.fasta.gz --cpus 8 --outdir OUTPUT_DIRECTORY --report OUTPUT.txt`

**[deepARG (nucleotide annotations)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model LS --type nucl --input INPUT_ANNOTATIONS.ffn --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA`

**[deepARG (amino acid annotations)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model LS --type prot --input INPUT_ANNOTATIONS.faa --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA`                                                  

**[Meta-MARC (read-based)](https://github.com/lakinsm/meta-marc)**                                                                        
`meta-marc -i INPUT_READS.FASTQ -o OUTPUT -d -m -l 3 -t 8`  

**[Meta-MARC (assembly-based)](https://github.com/lakinsm/meta-marc)**                                                                        
`meta-marc -i INPUT_ASSEMBLY.FASTA -o OUTPUT -l 3 -t 8` 

**[ResFinder (read-based)](https://bitbucket.org/genomicepidemiology/resfinder/src/master/)**                                                                                
`resfinder -o OUTPUT_DIRECTORY -l 0.6 -t 0.8 --acquired -ifq INPUT.fastq`

**[ResFinder (assembly-based)](https://bitbucket.org/genomicepidemiology/resfinder/src/master/)**                                                                            
`resfinder -o OUTPUT_DIRECTORY -l 0.6 -t 0.8 --acquired -ifa INPUT_ASSEMBLY.fasta`

**[RGI (assembly-based)](https://github.com/arpcard/rgi)**                                                                                         
`rgi main --input_sequence INPUT_ASSEMBLY.fasta --output_file OUTPUT --input_type contig --low_quality --local --clean --num_threads 8`

`rgi heatmap -cat drug_class --input /path/to/folder/of/collated/OUTPUT.jsons --output OUTPUT`

**[RGI (protein-based)](https://github.com/arpcard/rgi)**                                                                                         
`rgi main --input_sequence INPUT_ANNOTATIONS.faa --output_file OUTPUT --input_type protein --local --clean --num_threads 8`

`rgi heatmap -cat drug_class --input /path/to/folder/of/collated/OUTPUT.jsons --output OUTPUT`

**[StarAMR](https://github.com/phac-nml/staramr)**                                                                                                            
`staramr search -o OUTPUT_DIRECTORY INPUT.fasta`
