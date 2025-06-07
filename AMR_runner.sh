#!/bin/bash

#TO USE: ./AMR_runner.sh [accession]

source /opt/mambaforge/etc/profile.d/conda.sh


#ABRICATE
conda activate abricate
abricate --threads 32 --db ncbi medaka/$1.medaka.fasta > results/$1.medaka.abricate.ncbi.tsv
abricate --threads 32 --db megares medaka/$1.medaka.fasta > results/$1.medaka.abricate.megares.tsv
abricate --threads 32 --db argannot medaka/$1.medaka.fasta > results/$1.medaka.abricate.argannot.tsv
abricate --threads 32 --db card medaka/$1.medaka.fasta > results/$1.medaka.abricate.card.tsv
abricate --threads 32 --db resfinder medaka/$1.medaka.fasta > results/$1.medaka.abricate.resfinder.tsv
abricate --threads 32 --db ncbi flye/$1.flye.fasta > results/$1.flye.abricate.ncbi.tsv 
abricate --threads 32 --db megares flye/$1.flye.fasta > results/$1.flye.abricate.megares.tsv
abricate --threads 32 --db argannot flye/$1.flye.fasta > results/$1.flye.abricate.argannot.tsv
abricate --threads 32 --db card flye/$1.flye.fasta > results/$1.flye.abricate.card.tsv
abricate --threads 32 --db resfinder flye/$1.flye.fasta > results/$1.flye.abricate.resfinder.tsv
abricate --threads 32 --db ncbi miniasm/$1.miniasm.fasta > results/$1.miniasm.abricate.ncbi.tsv
abricate --threads 32 --db megares miniasm/$1.miniasm.fasta > results/$1.miniasm.abricate.megares.tsv
abricate --threads 32 --db argannot miniasm/$1.miniasm.fasta > results/$1.miniasm.abricate.argannot.tsv
abricate --threads 32 --db card miniasm/$1.miniasm.fasta > results/$1.miniasm.abricate.card.tsv
abricate --threads 32 --db resfinder miniasm/$1.miniasm.fasta > results/$1.miniasm.abricate.resfinder.tsv
conda deactivate

#ABRITAMR
conda activate abritamr
abritamr run --contigs miniasm/$1.miniasm.fasta --prefix results/$1.miniasm.abritamr
abritamr run --contigs medaka/$1.medaka.fasta --prefix results/$1.medaka.abritamr
abritamr run --contigs flye/$1.flye.fasta --prefix results/$1.flye.abritamr  
conda deactivate

#AMRFINDER
conda activate amrfinder
amrfinder -a prokka -p prokka/$1.miniasm.prokka/$1.miniasm.prokka.faa -n prokka/$1.miniasm.prokka/$1.miniasm.prokka.fna -g prokka/$1.miniasm.prokka/$1.miniasm.prokka.gff --threads 32 -o results/$1.miniasm.amrfinder
amrfinder -a prokka -p prokka/$1.flye.prokka/$1.flye.prokka.faa -n prokka/$1.flye.prokka/$1.flye.prokka.fna -g prokka/$1.flye.prokka/$1.flye.prokka.gff --threads 32 -o results/$1.flye.amrfinder
amrfinder -a prokka -p prokka/$1.medaka.prokka/$1.medaka.prokka.faa -n prokka/$1.medaka.prokka/$1.medaka.prokka.fna -g prokka/$1.medaka.prokka/$1.medaka.prokka.gff --threads 32 -o results/$1.medaka.amrfinder
conda deactivate

#RESFINDER
conda activate resfinder
python -m resfinder -o results/$1.filtlong.resfinder -l 0.6 -t 0.8 --acquired --nanopore -ifq filtlong/$1.filtlong.500mb.fastq.gz
python -m resfinder -o results/$1.miniasm.resfinder -l 0.6 -t 0.8 --acquired --nanopore -ifa miniasm/$1.miniasm.fasta
python -m resfinder -o results/$1.flye.resfinder -l 0.6 -t 0.8 --acquired --nanopore -ifa flye/$1.flye.fasta
python -m  resfinder -o results/$1.medaka.resfinder -l 0.6 -t 0.8 --acquired --nanopore -ifa medaka/$1.medaka.fasta
conda deactivate

#RGI
conda activate rgi
rgi main --input_sequence miniasm/$1.miniasm.fasta --output_file results/$1.miniasm.rgi --input_type contig --low_quality --clean --num_threads 32
rgi main --input_sequence prokka/$1.miniasm.prokka/$1.miniasm.prokka.faa --output_file results/$1.miniasm.prokka.rgi --input_type protein --clean --num_threads 32
rgi main --input_sequence flye/$1.flye.fasta --output_file results/$1.flye.rgi --input_type contig --low_quality --clean --num_threads 32
rgi main --input_sequence prokka/$1.flye.prokka/$1.flye.prokka.faa --output_file results/$1.flye.prokka.rgi --input_type protein --clean --num_threads 32
rgi main --input_sequence medaka/$1.medaka.fasta --output_file results/$1.medaka.rgi --input_type contig --low_quality --clean --num_threads 32
rgi main --input_sequence prokka/$1.medaka.prokka/$1.medaka.prokka.faa --output_file results/$1.medaka.prokka.rgi --input_type protein --clean --num_threads 32
conda deactivate

#C-SSTAR
conda activate c-SSTAR
mkdir results/$1.miniasm.csstar
c-SSTAR -g miniasm/$1.miniasm.fasta -d /PATH/TO/c-SSTAR-2.1.0/db/ResGANNOT_srst2.fasta.gz --cpus 32 --outdir results/$1.miniasm.csstar > results/$1.miniasm.csstar/$1.miniasm.csstar.tsv
mkdir results/$1.medaka.csstar
c-SSTAR -g medaka/$1.medaka.fasta -d /PATH/TO/c-SSTAR-2.1.0/db/ResGANNOT_srst2.fasta.gz --cpus 32 --outdir results/$1.medaka.csstar > results/$1.medaka.csstar/$1.medaka.csstar.tsv
mkdir results/$1.flye.csstar
c-SSTAR -g flye/$1.flye.fasta -d /PATH/TO/c-SSTAR-2.1.0/db/ResGANNOT_srst2.fasta.gz --cpus 32 --outdir results/$1.flye.csstar > results/$1.flye.csstar/$1.flye.csstar.tsv
conda deactivate

#STARAMR
conda activate staramr
staramr search -o results/$1.miniasm.staramr miniasm/$1.miniasm.fasta
staramr search -o results/$1.flye.staramr flye/$1.flye.fasta
staramr search -o results/$1.medaka.staramr medaka/$1.medaka.fasta
conda deactivate
 
#AMR++
conda activate AMR++_env
nextflow run /PATH/TO/AMRplusplus/main_AMR++.nf --pipeline resistome --reads filtlong/$1.filtlong.500mb.fastq.gz --output "results/$1.reads.amrplusplus" --threads 32
conda deactivate

#DeepARG
conda activate deeparg
deeparg predict --model LS --type nucl --input prokka/$1.miniasm.prokka/$1.miniasm.prokka.ffn --out results/$1.miniasm.deeparg.nucl --data-path deeparg
deeparg predict --model LS --type prot --input prokka/$1.miniasm.prokka/$1.miniasm.prokka.faa --out results/$1.miniasm.deeparg.prot --data-path deeparg
deeparg predict --model LS --type nucl --input prokka/$1.flye.prokka/$1.flye.prokka.ffn --out results/$1.flye.deeparg.nucl --data-path deeparg
deeparg predict --model LS --type prot --input prokka/$1.flye.prokka/$1.flye.prokka.faa --out results/$1.flye.deeparg.prot --data-path deeparg
deeparg predict --model LS --type nucl --input prokka/$1.medaka.prokka/$1.medaka.prokka.ffn --out results/$1.medaka.deeparg.nucl --data-path deeparg
deeparg predict --model LS --type prot --input prokka/$1.medaka.prokka/$1.medaka.prokka.faa --out results/$1.medaka.deeparg.prot --data-path deeparg
conda deactivate

#Collect results into strain folder(s)
mkdir results/no_species/$1
mv results/$1.* results/no_species/$1
