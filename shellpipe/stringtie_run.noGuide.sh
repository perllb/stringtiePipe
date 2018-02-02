#!/bin/bash
#SBATCH -n 8
#SBATCH -N 1
#SBATCH -A lsens2017-3-2
#SBATCH -p dell
#SBATCH -t 03:00:00
#SBATCH -J %j.stringTie.noG
#SBATCH -o %j.stringTie.noG.out
#SBATCH -e %j.stringTie.noG.err

ml GCC/6.4.0-2.28  OpenMPI/2.1.1
ml StringTie/1.3.3b

bam=$1
sample=$2

## create basename variable
basename=$sample.stringtie.noGuide.rf

if [ ! -f assembly/$basename.gtf ]
then
  # assemble using Gencode.v27.annotation.gtf
  stringtie \
      $bam \
      -p 8 \
      --rf \
      -l $sample \
      -o assembly/$basename.gtf
fi
