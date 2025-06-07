#!/bin/bash

# Setup conda 
source /opt/mambaforge/etc/profile.d/conda.sh

#TO USE: genome_builder.sh [accession] 


#Download and gzip fastqs from SRA
mkdir fastq_raw && cd fastq_raw
fasterq-dump -e 8 $1
gzip $1.fastq
cd ..

#Run Porechop to remove adaptor sequences
conda activate porechop
mkdir porechop
porechop --threads 8 --input fastq_raw/$1.fastq.gz --output porechop/$1.porechop.fastq.gz --format fastq.gz
conda deactivate

#Run Filtlong to filter reads to 500 mb (longest, highest quality reads) 
conda activate filtlong
mkdir filtlong
filtlong -t 500000000 porechop/$1.porechop.fastq.gz | gzip > filtlong/$1.filtlong.500mb.fastq.gz
conda deactivate

#Run Flye to assemble filtered reads
conda activate flye
mkdir flye
flye --nano-raw filtlong/$1.filtlong.500mb.fastq.gz --out-dir flye/$1.flye --threads 8 --meta
cp flye/$1.flye/assembly.fasta flye/$1.flye.fasta
conda deactivate

#Run Medaka to polish assembled Flye genome
conda activate medaka
mkdir medaka
medaka_consensus -i fastq_raw/$1.fastq.gz -d $1.flye/assembly.fasta -o medaka/$1.medaka -t 8
cp medaka/$1.medaka/consensus.fasta medaka/$1.medaka.fasta
conda deactivate

#Assemble with Miniasm (assumes miniasm and minimap2 in the same conda environment)
conda activate miniasm
mkdir miniasm
minimap2 -x ava-ont -t8 fastq_raw/$1.fastq.gz fastq_raw/$1.fastq.gz | gzip -1 > miniasm/$1.reads.paf.gz
miniasm -f fastq_raw/$1.fastq.gz miniasm/$1.reads.paf.gz > miniasm/$1.gfa
awk '/^S/{print">"$2"\n"$3}' miniasm/$1.gfa | fold > miniasm/$1.miniasm.fasta
rm miniasm/$1.reads.paf.gz && rm miniasm/$1.gfa
conda deactivate 

#Prokka
conda activate prokka
mkdir prokka
prokka --compliant --metagenome --cpus 8 --outdir prokka/$1.flye.prokka --prefix $1.flye.prokka flye/$1.flye.fasta
prokka --compliant --metagenome --cpus 8 --outdir prokka/$1.medaka.prokka --prefix $1.medaka.prokka medaka/$1.medaka.fasta
prokka --compliant --metagenome --cpus 8 --outdir prokka/$1.miniasm.prokka --prefix $1.miniasm.prokka miniasm/$1.miniasm.fasta
conda deactivate


