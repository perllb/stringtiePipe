#!/bin/bash
#SBATCH -n 8
#SBATCH -N 1
#SBATCH -A lsens2017-3-2
#SBATCH -p dell
#SBATCH -t 03:00:00
#SBATCH -J %j.stringTieMerge
#SBATCH -o %j.stringTieMerge.out
#SBATCH -e %j.stringTieMerge.err

ml GCC/6.4.0-2.28  OpenMPI/2.1.1
ml StringTie/1.3.3b

$mergedFile=$1

if [ ! -f $mergedFile ]
then
  # merge all transcripts from the different samples
  stringtie \
    --merge \
    -p 8 \
    -G /projects/fs1/medpvb/no_backup/genomicData/hg38/gencode/gencode.v27/gencode.v27.annotation.gtf \
    -o $mergedFile \
    assembly/mergelist.txt
fi
