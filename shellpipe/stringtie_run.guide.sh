#!/bin/bash
#SBATCH -n 8
#SBATCH -N 1
#SBATCH -A lsens2017-3-2
#SBATCH -p dell
#SBATCH -t 03:00:00
#SBATCH -J %j.stringTie.
#SBATCH -o %j.stringTie.out
#SBATCH -e %j.stringTie.err

ml GCC/6.4.0-2.28  OpenMPI/2.1.1
ml StringTie/1.3.3b

bam=$1
sample=$2
guideName=$3
guide=$4

## create basename variable
basename=$sample.stringtie.$guideName.guide.rf

if [ ! -f assembly/$basename.gtf ]
then
  # assemble using Gencode.v27.annotation.gtf
  stringtie \
      $bam \
      -B \
      -p 8 \
      -G $guide \
      --rf \
      -l $sample \
      -o assembly/$basename.gtf

fi
