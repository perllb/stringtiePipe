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
guide=$3

if [ ! -f ballgown/$sample/$sample.gtf ]
then
  # estimate abundances using merged assemly
  stringtie \
      $bam \
      -e \
      -B \
      -p 8 \
      -G $guide \
      --rf \
      -l $sample \
      -o ballgown/$sample/$sample.gtf \
      -A abundance/$sample.tab
fi
