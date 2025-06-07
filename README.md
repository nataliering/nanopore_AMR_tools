# A systematic comparison of tools available for predicting antimicrobial resistance using nanopore sequencing reads and paired phenotyping results
Code and commands used in our manuscript, "A systematic comparison of tools available for predicting antimicrobial resistance using nanopore sequencing reads and paired phenotyping results"


## PLEASE NOTE: This is still a work-in-progress. Message Natalie Ring for further information.

## Abstract
Antimicrobial resistance is of growing important in numerous settings around the globe, from healthcare to agriculture. There is a pressing need to ensure that antimicrobials are used appropriately: to target the right microbes, at the right time. In the healthcare setting, the appropriate antimicrobial is usually selected after patient samples have been cultured, and antimicrobial sensitivity testing conducted. However, these tests can take several days, from sample collection to diagnosis and antimicrobial prescription. In the meantime, inappropriate, or broad-spectrum, antimicrobials may be used. Alternatives to culture-based diagnosis are therefore increasingly being tested. One alternative is the use of nanopore DNA sequencing to identify pathogens present in patient samples, followed by bioinformatic analysis of the sequencing data to predict potential antimicrobial resistance present in those pathogens. The major advantage of this approach is its speed, with the ability to produce results in hours instead of days. Thus far, the major disadvantage has been the inconsistency of predicted AMR phenotypes, as demonstrated by recent studies showing that different bioinformatics tools may predict different AMR phenotypes from the same dataset. Here, we sought to identify and understand the differences between these predictions. We gathered nanopore sequencing data from a range of previous publications, specifically selected those datasets for which known AST phenotype calls were available. In addition, we sequenced >100 isolates from our biobank, for which AST results were known. We then analysed these datasets using eleven widely available AMR prediction tools. 


## Commands for tools mentioned in manuscript
Each of the tools we used can be further optimised; we tended to use the default settings in most cases, often exactly as recommended in the tool's README.
### Downloading relevant nanopore datasets in fastq format
**[fasterq-dump (download of reads from SRA)](https://github.com/ncbi/sra-tools)**  
`fasterq-dump --gzip -e NUM_THREADS ACCESSION_NUMBER`

### Adaptor trimming
**[Porechop](https://github.com/rrwick/Porechop)**  
`porechop -i INPUT.fastq -o OUTPUT.fastq --threads NUM_THREADS --format fastq.gz`

### Read filtering
**[Filtlong](https://github.com/rrwick/Filtlong)**  
`filtlong -t 500000000 INPUT.fastq.gz | gzip > OUTPUT.fastq.gz`

### Genome assembly, polishing and annotation
**[Flye](https://github.com/fenderglass/Flye)**  
`flye --meta --threads NUM_THREADS --out-dir OUTPUT_DIRECTORY --nano-raw INPUT.fastq`

**[Minimap2](https://github.com/lh3/Minimap2) and [Miniasm](https://github.com/lh3/Miniasm)**  
`minimap2 -x ava-ont -t[NUM_THREADS] INPUT.fastq INPUT.fastq | gzip -1 > OUTPUT.paf.gz`                                                                                           

`miniasm -f INPUT.fastq OUTPUT.paf.gz > OUTPUT.gfa`                                                                                                           

`awk '/^S/{print">"$2"\n"$3}' OUTPUT.gfa | fold > OUTPUT.fasta`

**[Medaka](https://github.com/nanoporetech/medaka)**                                                                                                                                                                                                        
`medaka_consensus -i FILTLONG_READS.fastq.gz -d DRAFT_ASSEMBLY.fasta -o OUTPUT_DIRECTORY -t NUM_THREADS`

**[Prokka](https://github.com/tseemann/Prokka)**                                                                                                            
`prokka --compliant --metagenome --cpus NUM_THREADS --outdir OUTPUT_DIRECTORY --prefix OUTPUT_PREFIX INPUT_ASSEMBLY.fasta`

### AMR prediction tools [species-specific options]                                                                                                                                    
**[ABRicate](https://github.com/tseemann/ABRicate)**                                                                                                     
`abricate --threads NUM_THREADS --db [ncbi|megares|argannot|card|resfinder] INPUT_ASSEMBLY.fasta > OUTPUT.tsv`                                                                        

**[abriTAMR](https://github.com/MDU-PHL/abritamr)**                                                                                                     
`abriTAMR run --contigs INPUT_ASSEMBLY.fasta --prefix OUTPUT_PREFIX [--species SPECIES]` 

**[AMRFinderPlus](https://github.com/ncbi/amr)**                                                                                       
`amrfinder -a prokka -p PROKKA_OUTPUT.faa -n PROKKA_OUTPUT.fna -g PROKKA_OUTPUT.gff --threads NUM_THREADS -o OUTPUT_DIRECTORY [--organism ORGANISM]`

**[c-SSTAR](https://github.com/chrisgulvik/c-SSTAR)**                                                                            
`c-SSTAR -g INPUT_ASSEMBLY.fasta -d /PATH/TO/c-SSTAR/DB/ResGANNOT_srst2.fasta.gz --cpus NUM_THREADS --outdir OUTPUT_DIRECTORY > OUTPUT_DIRECTORY/OUTPUT.tsv`

**[deepARG (nucleotide annotations)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model LS --type nucl --input INPUT_ANNOTATIONS.ffn --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA`

**[deepARG (amino acid annotations)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model LS --type prot --input INPUT_ANNOTATIONS.faa --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA`                                                  

**[ResFinder (read-based)](https://bitbucket.org/genomicepidemiology/resfinder/src/master/)**                                                                                
`python -m resfinder -o OUTPUT_DIRECTORY -l 0.6 -t 0.8 --acquired --nanopore -ifq INPUT.fastq [-s SPECIES]`

**[ResFinder (assembly-based)](https://bitbucket.org/genomicepidemiology/resfinder/src/master/)**                                                                            
`python -m resfinder -o OUTPUT_DIRECTORY -l 0.6 -t 0.8 --acquired --nanopore -ifa INPUT_ASSEMBLY.fasta [-s SPECIES]`

**[RGI (assembly-based)](https://github.com/arpcard/rgi)**                                                                                         
`rgi main --input_sequence INPUT_ASSEMBLY.fasta --output_file OUTPUT --input_type contig --low_quality --clean --num_threads NUM_THREADS`

**[RGI (protein-based)](https://github.com/arpcard/rgi)**                                                                                         
`rgi main --input_sequence INPUT_ANNOTATIONS.faa --output_file OUTPUT --input_type protein --clean --num_threads NUM_THREADS`

**[StarAMR](https://github.com/phac-nml/staramr)**                                                                                                            
`staramr search -o OUTPUT_DIRECTORY INPUT.fasta [--pointfinder-organism ORGANISM]`
 

