####
SCHEDULER="SLURM"

#### Parameters to set
BATCHDIR="batch4"
PROJECTDIR="/"
JOBDIR="$PROJECTDIR//$BATCHDIR/"
INPUTDIR="$PROJECTDIR/DATA/BAM/"
OUTPUTDIR="$PROJECTDIR/haplotypeCalling/$BATCHDIR/"


REFERENCE="/hg38/decode/genome.fa"


####
EXPERIMENT_TYPE="Whole genome sequencing"
#EXPERIMENT_TYPE="Exome sequencing"
LIBRARY_STRATEGY="WGS"
#LIBRARY_STRATEGY="WXS"


DATE=$(date --iso-8601=seconds)

mkdir -p $JOBDIR
mkdir -p $OUTPUTDIR

#while read line
#do

for BAM in $( ls $INPUTDIR/*.bam)
do
	
	SAMPLE=$(basename $BAM .PE.ra.md.bam)

    
    echo "Generating job for sample: $SAMPLE"

##########
####CREATE JOB HEADER

JOBNAME="sample.$SAMPLE.haplotypeCalling.sh"
OUTPUTLOG="$JOBDIR/sample.$SAMPLE.haplotypeCalling.sh.out"
ERRORLOG="$JOBDIR/sample.$SAMPLE.haplotypeCalling.sh.err"
WALLTIME="72:00:00"
NUMTASKS="1"
NUMCPUS="28"
MEM="24G"
TMPSPACE="300G"
JOBFILE="$JOBDIR/sample.$SAMPLE.haplotypeCalling.sh"

if [[ $SCHEDULER == "SLURM" ]]
then
    cat <<- EOF > $JOBFILE
#!/bin/bash
#SBATCH --job-name=$JOBNAME
#SBATCH --output=$OUTPUTLOG
#SBATCH --error=$ERRORLOG
#SBATCH --partition=cpu
#SBATCH --time=$WALLTIME
#SBATCH --ntasks=$NUMTASKS
#SBATCH --cpus-per-task $NUMCPUS
#SBATCH --mem=$MEM
#SBATCH --gres=tmpspace:$TMPSPACE
#SBATCH --nodes=1
#SBATCH --open-mode=append

EOF

elif [[ $SCHEDULER == "SGE" ]]
then

    cat <<- EOF > $JOBFILE
#$ -S /bin/bash
#$ -N $JOBNAME
#$ -o $OUTPUTLOG
#$ -e $ERRORLOG
#$ -l h_rt=$WALLTIME
#$ -l h_vmem=$MEM
#$ -l tmpspace=$TMPSPACE
#$ -cwd


EOF

else
    echo "Type of scheduler not known: $SCHEDULER"
    exit
fi


    
echo "


set -e # exit if any subcommand or pipeline returns a non-zero status
set -u # exit if any uninitialised variable is used


startTime=\$(date +%s)
echo \"startTime: \$startTime\"

GATK4= \"gatk-4.0.5.1/gatk\"
# load the required modules
module load gatk/4.0.5.1
#gatk/3.8.0
module load Java/1.8.0_60

echo \"Starting GATK\"

#gatk HaplotypeCaller --help

#run gatk
gatk --java-options \"-Djava.io.tmpdir=\$TMPDIR -Xms4G -Xmx20G -XX:ParallelGCThreads=28\"  HaplotypeCaller \\
-R $REFERENCE \\
-O $OUTPUTDIR/$SAMPLE.haplotypeCalling.g.vcf.gz \\
-I $BAM \\
-ERC GVCF \\
--native-pair-hmm-threads 28



#Retrieve and check return code
returnCode=\$?
echo \"Return code \${returnCode}\"

if [ \"\${returnCode}\" -eq \"0\" ]
then
	
	echo -e \"Return code is zero, process was succesfull\n\n\"
	
else
  
	echo -e \"\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n\"
	#Return non zero return code
	exit 1
	
fi


#Write runtime of process to log file
endTime=\$(date +%s)
echo \"endTime: \$endTime\"


#Source: http://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds-in-bash

num=\$endTime-\$startTime
min=0
hour=0
day=0
if((num>59));then
    ((sec=num%60))
    ((num=num/60))
    if((num>59));then
        ((min=num%60))
        ((num=num/60))
        if((num>23));then
            ((hour=num%24))
            ((day=num/24))
        else
            ((hour=num))
        fi
    else
        ((min=num))
    fi
else
    ((sec=num))
fi
echo \"Running time: \${day} days \${hour} hours \${min} mins \${sec} secs\"

" >> $JOBFILE


done  
