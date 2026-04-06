


<p align="center">
  <img src="https://github.com/nataliering/nanopore_AMR_tools/blob/main/AMR_tools_github_logo.png" width="250" class="center" title="Pipeline logo" alt="Pipeline logo"/>
</p>


# A systematic comparison of strategies for predicting antimicrobial resistance, using nanopore sequencing reads and paired phenotyping results
Code and commands used in our manuscript


## Abstract
Antimicrobial resistance (AMR) presents a pressing need to ensure that the right antimicrobials are used to target the right microbes at the right time. Ideally, the appropriate antimicrobial is selected after patient samples have been cultured and assessed with antimicrobial sensitivity testing (AST). However, the time needed for culture-based diagnosis leads to immediate empirical treatment, often with broad-spectrum and/or high-tier antimicrobials. Direct nanopore metagenomic whole genome sequencing to identify the pathogens and predict their antimicrobial resistance is a rapid and patient-side alternative. A limitation of this approach is the inconsistency of in silico predicted AMR phenotypes. Here, we benchmarked the current performance of in silico AMR prediction strategies for nanopore-generated long read data. Using nanopore data paired with AST phenotyping for 201 samples, we assessed the impact of basecalling mode, data volume, and assembly strategy to compare the performance of eight in silico AMR prediction tools with seven AMR databases. We found that basecalling accuracy mode does not affect the overall accuracy of in silico AMR predictions, but assembly strategy and data volume both do. Prediction tools using the ResFinder database scored best for balanced accuracy (0.8 ± 0.02 for both ResFinder and ABRicate), whilst DeepARG scored best for sensitivity (0.65 ± 0.03). However, even the best performing in silico AMR prediction strategy missed some resistance identified by lab-based AST. In silico AMR prediction can therefore supplement lab-based AST, but cannot yet replace it.


## Commands for tools mentioned in manuscript
Each of the tools we used can be further optimised; we tended to use the default settings in most cases, often exactly as recommended in the tool's README.
### Downloading relevant nanopore datasets in fastq format
**[fasterq-dump (download of reads from SRA)](https://github.com/ncbi/sra-tools)**  
`fasterq-dump --gzip -e NUM_THREADS ACCESSION_NUMBER`

### Conversion from fast5 to pod5
**[POD5](https://pod5-file-format.readthedocs.io/en/latest/docs/install.html)**                                                                                                                                             
`pod5 convert fast5 -o [INPUT].pod5 -t [NUM_THREADS] /path/to/*.fast5`

### Basecalling and demuxing with Dorado v1.0.2 in fast, hac and sup modes                                                                                                                                                  
**[Dorado](https://github.com/nanoporetech/dorado/)**                                                                                                                                                                                                      
`dorado basecaller fast [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK114-24 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                                        
`dorado basecaller hac [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK114-24 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                                                        
`dorado basecaller sup [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK114-24 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                         

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
                                                                                                                                                                                                                                                                         
**[AMR++](https://github.com/Microbial-Ecology-Group/AMRplusplus)**                                                                                       
`nextflow run /path/to/AMRplusplus/main_AMR++.nf --pipeline resistome --reads FILTLONG_READS.fastq.gz --output "OUTPUT_DIRECTORY" --threads NUM_THREADS`

**[c-SSTAR](https://github.com/chrisgulvik/c-SSTAR)**                                                                            
`c-SSTAR -g INPUT_ASSEMBLY.fasta -d /PATH/TO/c-SSTAR/DB/ResGANNOT_srst2.fasta.gz --cpus NUM_THREADS --outdir OUTPUT_DIRECTORY > OUTPUT_DIRECTORY/OUTPUT.tsv`

**[deepARG (nucleotide annotations)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model LS --type nucl --input INPUT_ANNOTATIONS.ffn --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA`

**[deepARG (amino acid annotations)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model LS --type prot --input INPUT_ANNOTATIONS.faa --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA`                                                  

**[deepARG (read-based)](https://bitbucket.org/gusphdproj/deeparg-ss/src/master/)**                                                                        
`deeparg predict --model SS --type nucl --input INPUT_READS.FASTQ.GZ --out OUTPUT --data-path /PATH/TO/DEEPARG_DATA` 


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
 

