#!/bin/bash
#SBATCH -n 8
#SBATCH -N 1
#SBATCH -A lsens2017-3-2
#SBATCH -p dell
#SBATCH -t 10:00:00
#SBATCH -J %j.stringTie.pipe
#SBATCH -o %j.stringTie.pipe.out
#SBATCH -e %j.stringTie.pipe.err

## print usage and description
usage="Usage:
> $(basename "$0") -a </path/to/annotation.gtf> -b </path/ToBam/> -s <suffix of bam to remove> -o <outdir>
where:
    -a: annotation file. entire path needs to be included.
      : if no reference annotation needed, enter '-a noGuide'
    -b: path to bamfile. only path, not name of the bamfile
    -s: suffix to remove from bamfiles (e.g. Aligned.SortedByCoord.out.bam)
    -o: director to put all output files
    -h: help

-- Program is a pipeline to use stringtie to assemble transcripts from bam files.
-- 5 main steps:
 1. assemble transcripts, using reference annotation given by user (if no ref wanted, enter '-a noGuide')
 2. merge transcripts, from all individual sample assemblies
 3. GFF compare reference annotation with merged, to see how many novel transcripts
 4. estimate abundances, using merge transcripts gtf
 5. converting merged transcripts gtf to bed12 and bb

    "
go=0
seed=42

while getopts ':a:b:s:o:' option; do
  case "$option" in
    h) echo "$usage"; exit ;;
    a)
    if [ -r $OPTARG ]
      then
        guide=$OPTARG
    elif [ ! -r $OPTARG ]
      then
        if [ $OPTARG == "noGuide" ]
          then
          guide=$OPTARG
        else
          echo ">> ERROR: reference annotation file $OPTARG does not exists or is not readable!"
          echo ">> If no reference annotation wanted, enter '-a noGuide'"
          exit 1
        fi
    fi
       ;;
    b)
    if [ -d $OPTARG ]
      then
        bamPath=$OPTARG
    else
      echo ">> ERROR: bam directory $OPTARG does not exist!"
      exit 1
    fi
        ;;
    s) suff=$OPTARG;;
    o)
      if [ -d $OPTARG ]
        then
          outdir=$OPTARG
      else
        echo ">> ERROR: output directory $OPTARG does not exist!"
        exit 1
      fi
          ;;
    :)  echo "$usage" >&2; echo "missing argument for -$OPTARG" >&2 ; exit 1;;
    \?) echo "$usage" >&2; echo "Invalid option: -$OPTARG" >&2; exit 1;;
    *)  echo "Unimplemented option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# If all parameters set, the go
if [ -d $bamPath ] && [ ! -z "$suff" ] && [ ! -z $outdir ]
  then
  if [ -f $guide ] || [ $guide == 'noGuide' ]
    then

    ## 1. make folder to output gtf and bedfiles
    if [ ! -d assembly ]
    then
      mkdir assembly
    fi

    # set variables
    scrPath=$(pwd)
    baseGuide=$(basename $guide .gtf)

    # go to output directory to put files there!
    cd $outdir

    ## 1. Run stringtie
    echo "> Run stringtie assembly .. "

    # If NO reference annotation wanted (-a none)
    if [ $guide == 'noGuide' ]
      then
      echo ".. no reference annotation used to guide assembly.. "

      # run stringtie for each file
      for file in $bamPath/*out.bam
        do id=$(basename $file $suff) # get ID of file (include hg38.unique)
        echo " .. sample $id : $(date)"
        sh $scrPath/stringtie_run.noGuide.sh $file $id
      done
    ### If reference annotation wanted
    else

      echo ".. reference annotation: $baseGuide "
      for file in $bamPath/*out.bam
        do id=$(basename $file $suff) # get ID of file (include hg38.unique)
        echo " .. sample $id : $(date)"
        sh $scrPath/stringtie_run.guide.sh $file $id $baseGuide $guide
      done

    fi

    ## 2. Merge transcripts
    # First, make mergelist
    ls assembly/*.stringtie.$baseGuide.gtf > assembly/mergelist.txt
    merged=assembly/stringtie_merged.$baseGuide.gtf
    echo "> Merge transcripts.."
    sh $scrPath/stringtie_merge.sh $merged $guide

    # get number of transcripts
    #cat $merged  | grep -v "^#" | awk '$3=="transcript" {print}' | wc -l

    # 3, Compare the assembled transcripts to known transcripts
    if [ $guide != 'noGuide' ]
    then
      echo "> Compare assembled to known.."
      if [ ! -f $merged ]
      then
        gffcompare -r $guide -G -o assembly/merged $merged
      fi
    fi

    ## 4. Estimate abuncances
    echo "> Estimate abundances of merged transcripts.."
    for file in $bamPath/*out.bam
      do id=$(basename $file $suff) # get ID of file (include hg38.unique)
      echo " .. sample $id : $(date)"
      sh $scrPath/stringtie_run.merged.sh $file $id -i $merged
    done

    ## 5. gtf to bed12 and bb for merged transcripts
    $scrPath/gtf2bb12.sh -g $merged
  fi

else
  echo "$usage" >&2
  if [ -z $guide ]
    then
      echo "ERROR: Missing -a <reference annotation>!"
  fi
  if [ -z $bamPath ]
    then
      echo "ERROR: Missing -b <bam-path>!"
  fi
  if [ -z $suff ]
    then
      echo "ERROR: Missing -s <suffix>!"
  fi
  if [ -z $outdir ]
    then
      echo "ERROR: Missing -o <outdir>!"
  fi
fi
