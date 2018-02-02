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

if [ ! -f ballgown/$sample/$sample.gtf ] && [ ! -f abundance/$sample.tab ]
then
  # estimate abundances using merged assemly
  # assemble using given guide
  echo "> Running stringtie with: "
  echo "- Merged annotation guide: $guide"
  echo "- Sample:               $sample"
  echo "- output ballgown:      ballgown/$sample/$sample.gtf"
  echo "- output abundance:     abundance/$sample.tab"

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

else
  echo " ... (ballgown/$sample/$sample.gtf and abundance/$sample.tab already exist.. Nothing to do with sample $sample)"
fi
