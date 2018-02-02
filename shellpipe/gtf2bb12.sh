#!/bin/bash

usage="Usage:
> $(basename "$0") -g gtfFile.gtf
where:
    -g <gtffile> gtf-file to convert
    -h help
    
-- Program to convert gtf files to bed12 and further to bigbed.
- Creates three files in same directory as .gtf file:
- 1. .genePred
- 2. .bed (in bed12 format)
- 3. .bb (bigbed format)
    "
go=0
seed=42
while getopts ':hg:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    g)
    gtf=$OPTARG
    if [ -r $gtf ]
      then
        basename=${gtf%.*} # filepath and name without .gtf suffix
        go=1
        break;
    elif [ ! -r $gtf ]
      then
        echo ">> ERROR: gtf file $gtf does not exists or is not readable!"
        exit 1
    fi
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ $go == 1 ]
then
  ## Convert Gtf to genePred
  echo ">> Converting to genePred.."
  gtfToGenePred $basename.gtf $basename.genePred
  echo " ..Success: Converted to genePred!"
  ## Convert genPred to bed12
  echo ">> Converting to bed12.."
  genePredToBed $basename.genePred $basename.bed12
  echo " ..Success: Converted to bed12!"
  ## sort bed12
  echo ">> Sorting bed12.."
  sort -k1,1 -k2,2n $basename.bed12 > $basename.sorted.bed
  echo " ..Success: Sorted bed12!"
  ## Convert sorted bed12 to bigBed (useful for trackhubs)
  echo ">> Converting to bigbed.."
  bedToBigBed $basename.sorted.bed /projects/fs1/common/genome/lunarc/genomes/human/hg38/hg38.chrom.sizes.txt $basenme.bb
  echo " ..Success: Converted to bigbed!"
  echo ">> Program completed!"
else
  echo "$usage" >&2
fi
