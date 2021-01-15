####
SCHEDULER="SLURM"

#### Parameters to set
BATCHDIR="batch4"
INPUTBATCH="batch4"
PROJECTDIR=""
JOBDIR="$PROJECTDIR//$BATCHDIR/"
INPUTDIR="$PROJECTDIR//$INPUTBATCH/"
OUTPUTDIR="$PROJECTDIR//$BATCHDIR/"


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

for INPUT in $( ls $INPUTDIR/*1.haplotypeCalling.g.vcf.gz)
do
	
	SAMPLE=$(basename $INPUT 1.haplotypeCalling.g.vcf.gz)

    
    echo "Generating job for sample: $SAMPLE"


SAMPLE1="${SAMPLE}1"
SAMPLE2="${SAMPLE}2"
SAMPLE3="${SAMPLE}3"

##########
####CREATE JOB HEADER

JOBNAME="sample.$SAMPLE.CombineGVCFs.sh"
OUTPUTLOG="$JOBDIR/$SAMPLE.CombineGVCFs.sh.out"
ERRORLOG="$JOBDIR/$SAMPLE.CombineGVCFs.sh.err"
WALLTIME="15:00:00"
NUMTASKS="1"
NUMCPUS="1"
MEM="24G"
TMPSPACE="300G"
JOBFILE="$JOBDIR/$SAMPLE.CombineGVCFs.sh"

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






GATK4= \"software/gatk/gatk-4.0.5.1/gatk\"
# load the required modules
module load gatk/4.0.5.1
#gatk/3.8.0
module load Java/1.8.0_60

echo \"Starting GATK\"

#gatk CombineGVCFs --help
#run gatk

gatk CombineGVCFs \\
-R /hpc/pmc_kuiper/References/hg38/decode/genome.fa \\
--variant $INPUTDIR/$SAMPLE1.haplotypeCalling.g.vcf.gz \\
--variant $INPUTDIR/$SAMPLE2.haplotypeCalling.g.vcf.gz \\
--variant $INPUTDIR/$SAMPLE3.haplotypeCalling.g.vcf.gz \\
-O $OUTPUTDIR/$SAMPLE.g.vcf.gz


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
