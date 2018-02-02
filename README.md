# stringtiePipe
Pipeline for stringtie assembly



### 1. clone scripts a local folder on your machine
```
git clone https://github.com/perllb/stringtiePipe.git
```

### 2. run PIPE script with run parameters set 
#### Can be run either with sh or sbatch (if you edit #SBATCH headers to fit your server)

```
sh PIPE_stringTie.sh \ 
  -a /projects/fs1/medpvb/no_backup/genomicData/hg38/gencode/gencode.v27/gencode.v27.annotation.gtf \
  -b /projects/fs1/medpvb/backup/projects/ChimpHuman/Aligned_hg38_STAR_unique \
  -s Aligned.sortedByCoord.out.bam \
  -o /projects/fs1/medpvb/backup/projects/ChimpHuman/StringTie/

```

#### Usage:

```
> PIPE_stringTie.sh -a </path/to/annotation.gtf> -b </path/ToBam/> -s <suffix of bam to remove> -o <outdir>
```

where:
    -a: annotation file. entire path needs to be included.
      : if no reference annotation needed, enter -a none
    -b: path to bamfile. only path, not name of the bamfile
    -s: suffix to remove from bamfiles (e.g. Aligned.SortedByCoord.out.bam)
    -o: director to put all output files
    -h: help

-- Program is a pipeline to use stringtie to assemble transcripts from bam files.
-- 5 main steps:
 1. assemble transcripts, using reference annotation given by user (if no ref wanted, enter '-a none')
 2. merge transcripts, from all individual sample assemblies
 3. GFF compare reference annotation with merged, to see how many novel transcripts
 4. estimate abundances, using merge transcripts gtf
 5. converting merged transcripts gtf to bed12 and bb

#### Acknowledgement
The pipeline was inspired by the StringTie section on this tutorial:
https://davetang.org/muse/2017/10/25/getting-started-hisat-stringtie-ballgown/
Thanks Dave Tang!
