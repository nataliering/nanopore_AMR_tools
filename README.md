


<p align="center">
  <img src="https://github.com/nataliering/nanopore_AMR_tools/blob/main/AMR_tools_github_logo.png" width="250" class="center" title="Pipeline logo" alt="Pipeline logo"/>
</p>


# Benchmarking nanopore-based strategies for antimicrobial resistance prediction
Code and commands used in our manuscript


## Abstract
Antimicrobial resistance (AMR) presents a pressing need to ensure that the right
antimicrobials are used to target the right microbes at the right time. Ideally, the
appropriate antimicrobial is selected after patient samples have been cultured and
assessed with antimicrobial sensitivity testing (AST). However, the time needed for
culture-based diagnosis leads to immediate empirical treatment, often with broadspectrum
and/or high-tier antimicrobials. Direct nanopore metagenomic whole genome
sequencing to identify pathogens and predict their antimicrobial resistance is a rapid
and patient-side alternative. A limitation of this approach is potential inconsistencies in
in silico predicted AMR phenotypes. Here, we benchmarked the current performance
of in silico AMR prediction strategies for nanopore-generated long read data. Using
nanopore data paired with AST phenotyping for 201 samples representing 27 bacterial
species, we assessed the impact of basecalling mode, data volume, and assembly
strategy, and compared the performance of eight in silico AMR prediction tools with
seven AMR databases. We found that basecalling accuracy mode does not
significantly affect the overall accuracy of in silico AMR predictions, but assembly
strategy and data volume both do. Prediction tools using the ResFinder database
scored best for balanced accuracy (0.80 ± 0.02 for both ResFinder and ABRicate),
whilst DeepARG scored best for sensitivity (0.65 ± 0.03); predictions were more
accurate for some antibiotic classes and genera than others. However, even the best
performing in silico AMR prediction strategy missed some resistance identified by labbased
AST. We conclude therefore that, currently, in silico AMR prediction can
supplement lab-based AST, but cannot yet replace it.

## Analysis workflow

The overall analysis followed the workflow below. Individual commands and software versions are documented in the sections that follow.

1.Data was downloaded from NCBI, where relevant                                                                                         
2. Basecalling (where raw signal data were available; otherwise, previously basecalled reads were used).                                                                                    
3. Adapter trimming with Porechop.
4. Read filtering with Filtlong for datasets exceeding 500 Mb, retaining up to 500 Mb for the main benchmark. Separate target volumes of 250, 100, 50 and 25 Mb were used for the data-volume analysis.
5. AMR prediction using one of the following input routes:
   - **Read-based:** filtered FASTQ reads supplied directly to compatible AMR prediction tools.
   - **Assembly-based:** filtered reads assembled using Miniasm or Flye. Flye assemblies were additionally polished with Medaka to produce a third assembly type. Assemblies were annotated with Prokka, and the appropriate contig and/or annotation files were supplied to each AMR tool.
6. AMR tool outputs were harmonised using HAMRonization.
7. Detected resistance determinants were mapped to antibiotic phenotypes and classes using `gene_to_phenotype.py` and `gene_to_class.py`.
8. The harmonised predictions were compared with the corresponding phenotypic AST ground-truth table using a Python script, generating a combined results dataframe.
9. Python and R scripts were used to calculate, summarise and visualise the performance metrics.


## Commands for tools used in this study
Each of the tools we used can be further optimised; we tended to use the default settings in most cases, often exactly as recommended in the tool's README.

### Downloading relevant nanopore datasets in fastq format
**[fasterq-dump (download of reads from SRA)](https://github.com/ncbi/sra-tools)**  
`fasterq-dump --gzip -e NUM_THREADS ACCESSION_NUMBER`

### Conversion from fast5 to pod5 where necessary
**[POD5](https://pod5-file-format.readthedocs.io/en/latest/docs/install.html)**                                                                                                                                             
`pod5 convert fast5 -o [INPUT].pod5 -t [NUM_THREADS] /path/to/*.fast5`

### Basecalling and demuxing with Dorado v1.0.2 in fast, hac and sup modes for R10.4.1 samples. Model selection (e.g. dna_r10.4.1_e8_sup@v3.6 was carried out automatically by Dorado)                                                                                                                               
**[Dorado](https://github.com/nanoporetech/dorado/)**                                                                                                                                                                                                      
`dorado basecaller fast [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK114-24 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                                        
`dorado basecaller hac [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK114-24 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                                                        
`dorado basecaller sup [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK114-24 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                         

### Basecalling and demuxing with Dorado v0.9.6 in fast, hac and sup modes for R9.4.1 samples. Model selection (e.g. dna_r9.4.1_e8_sup@v3.6 was carried out automatically by Dorado)                                                                                                                                                  
**[Dorado](https://github.com/nanoporetech/dorado/)**                                                                                                                                                                                                      
`dorado basecaller fast [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK004 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                                        
`dorado basecaller hac [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK004 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq`                                                                                        
`dorado basecaller sup [INPUT_FOLDER] --device auto --recursive --kit-name SQK-RBK004 | dorado demux --output-dir [OUTPUT] --no-classify --emit-fastq` 

### Adaptor trimming
**[Porechop](https://github.com/rrwick/Porechop)**  
`porechop -i INPUT.fastq -o OUTPUT.fastq --threads NUM_THREADS --format fastq.gz`

### Read filtering
**[Filtlong](https://github.com/rrwick/Filtlong) for 500 Mb output. -t was changed accordingly to produce 250 Mb, 100 Mb, 50 Mb and 25 Mb for volume analysis **  
`filtlong -t 500000000 INPUT.fastq.gz | gzip > OUTPUT.fastq.gz`

### Genome assembly, polishing and annotation
**[Flye](https://github.com/fenderglass/Flye) for 50 metagenomic samples**  
`flye --meta --threads NUM_THREADS --out-dir OUTPUT_DIRECTORY --nano-raw INPUT.fastq`

**[Flye](https://github.com/fenderglass/Flye) for 151 monocultured isolate samples**  
`flye --threads NUM_THREADS --out-dir OUTPUT_DIRECTORY --nano-raw INPUT.fastq`

**[Minimap2](https://github.com/lh3/Minimap2) and [Miniasm](https://github.com/lh3/Miniasm)**  
`minimap2 -x ava-ont -t[NUM_THREADS] INPUT.fastq INPUT.fastq | gzip -1 > OUTPUT.paf.gz`                                                                                           

`miniasm -f INPUT.fastq OUTPUT.paf.gz > OUTPUT.gfa`                                                                                                           

`awk '/^S/{print">"$2"\n"$3}' OUTPUT.gfa | fold > OUTPUT.fasta`

**[Medaka](https://github.com/nanoporetech/medaka) with automatic model selection**                                                                                                                                                                                                        
`medaka_consensus -i FILTLONG_READS.fastq.gz -d DRAFT_ASSEMBLY.fasta -o OUTPUT_DIRECTORY -t NUM_THREADS`

**[Prokka](https://github.com/tseemann/Prokka)**                                                                                                            
`prokka --compliant --metagenome --cpus NUM_THREADS --outdir OUTPUT_DIRECTORY --prefix OUTPUT_PREFIX INPUT_ASSEMBLY.fasta`

### AMR prediction tools [species-specific options]                                                                                                                                    
**[ABRicate](https://github.com/tseemann/ABRicate)**                                                                                                     
`abricate --threads NUM_THREADS --db [ncbi|megares|argannot|card|resfinder] INPUT_ASSEMBLY.fasta > OUTPUT.tsv`                                                                        

**[abriTAMR](https://github.com/MDU-PHL/abritamr)**                                                                                                     
`abriTAMR run --contigs INPUT_ASSEMBLY.fasta --prefix OUTPUT_PREFIX [--species SPECIES]` 

**[AMRFinderPlus](https://github.com/ncbi/amr)**                                                                                       
`amrfinder -a prokka -p PROKKA_OUTPUT.faa -n PROKKA_OUTPUT.fna -g PROKKA_OUTPUT.gff --threads NUM_THREADS -o OUTPUT_FILE [--organism ORGANISM]`                                                                       

N.B. AMRFinderPlus was used with the Prokka-generated protein FASTA, nucleotide FASTA and GFF files, using the -a prokka option to specify the annotation format, because Prokka GFF files are not interpreted correctly by the default parser, as per NCBI's own documentation.
                                                                                                                                                                                                                                                                         
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
`python -m resfinder -o OUTPUT_DIRECTORY -l 0.6 -t 0.8 --acquired --nanopore -ifq INPUT.fastq [-s SPECIES] [--point]`

**[ResFinder (assembly-based)](https://bitbucket.org/genomicepidemiology/resfinder/src/master/)**                                                                            
`python -m resfinder -o OUTPUT_DIRECTORY -l 0.6 -t 0.8 --acquired --nanopore -ifa INPUT_ASSEMBLY.fasta [-s SPECIES] [--point]`

**[RGI (assembly-based)](https://github.com/arpcard/rgi)**                                                                                         
`rgi main --input_sequence INPUT_ASSEMBLY.fasta --output_file OUTPUT --input_type contig --low_quality --clean --num_threads NUM_THREADS`

**[RGI (protein-based)](https://github.com/arpcard/rgi)**                                                                                         
`rgi main --input_sequence INPUT_ANNOTATIONS.faa --output_file OUTPUT --input_type protein --clean --num_threads NUM_THREADS`

**[StarAMR](https://github.com/phac-nml/staramr)**                                                                                                            
`staramr search -o OUTPUT_DIRECTORY INPUT.fasta [--pointfinder-organism ORGANISM]`
 

