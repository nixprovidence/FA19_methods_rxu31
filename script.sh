#!/bin/sh
#
#SBATCH --job-name=QIIME2_single
#SBATCH --time=72:00:00
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=1
#SBATCH --partition=lrgmem
#SBATCH --mem-per-cpu=20G

ml qiime2/2018.8
export TMPDIR='/scratch/users/t-sprehei1@jhu.edu/tmp'
export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

mkdir qiime2-moving-pictures-tutorial
cd qiime2-moving-pictures-tutorial

wget \
  -O "sample-metadata.tsv" \
  "https://data.qiime2.org/2018.8/tutorials/moving-pictures/sample_metadata.tsv"

wget \
  -O "emp-single-end-sequences/barcodes.fastq.gz" \
  "https://data.qiime2.org/2018.8/tutorials/moving-pictures/emp-single-end-sequences/barcodes.fastq.gz"

wget \
  -O "emp-single-end-sequences/sequences.fastq.gz" \
  "https://data.qiime2.org/2018.8/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz"

qiime tools import \
  --type EMPSingleEndSequences \
  --input-path emp-single-end-sequences \
  --output-path emp-single-end-sequences.qza

echo "Demultiplexing sequence"
date

qiime demux emp-single \
  --i-seqs emp-single-end-sequences.qza \
  --m-barcodes-file sample-metadata.tsv \
  --m-barcodes-column BarcodeSequence \
  --o-per-sample-sequences demux.qza

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv

echo "Sequence quality control and feature table construction"
date

qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left 0 \
  --p-trunc-len 120 \
  --o-representative-sequences rep-seqs-dada2.qza \
  --o-table table-dada2.qza \
  --o-denoising-stats stats-dada2.qza

qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv

mv rep-seqs-dada2.qza rep-seqs.qza
mv table-dada2.qza table.qza

echo "FeatureTable and FeatureData summaries"
date

qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file sample-metadata.tsv
qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
