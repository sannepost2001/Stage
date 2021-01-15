####
SCHEDULER="SLURM"

#### Parameters to set
BATCHDIR="batch4"
PROJECTNAME="BladderCancer"
PROJECTDIR="/"
JOBDIR="$PROJECTDIR//$BATCHDIR/"
OUTPUTDIR="$PROJECTDIR//$BATCHDIR/"
REFGENOME="/hg38/decode/genome.fa"
TRIOFILE="/TriosBladderCancer.txt"

####


DATE=$(date --iso-8601=seconds)

mkdir -p $JOBDIR
mkdir -p $OUTPUTDIR


#declare -a Array
Array=()
    
    
#Loop over BAM files to create jobs
sed '1d' TriosBladderCancer.txt | while read line
#tail -n1 /hpc/pmc_kuiper/WESKidTs/SAMPLE_LISTS/trios_info.updated.20200511.txt | while read line
do

echo $line

TRIOID=$( echo $line | awk '{print $1}' FS=" ")
CHILDID=$( echo $line | awk '{print $2}' FS=" ")
FATHERID=$( echo $line | awk '{print $3}' FS=" ")
MOTHERID=$( echo $line | awk '{print $4}' FS=" ")

INPUTVCF="$BATCHDIR/${TRIOID}_genotype_flt_fltLCR.recode.vcf"


##########
####CREATE JOB HEADER

JOBNAME="$PROJECTNAME.filterTrioVCFandAnnotateandParseAndRenameAnnovarAnnotation.trio.${TRIOID}.sh"
OUTPUTLOG="$JOBDIR/$PROJECTNAME.filterTrioVCFandAnnotateandParseAndRenameAnnovarAnnotation.trio.${TRIOID}.sh.out"
ERRORLOG="$JOBDIR/$PROJECTNAME.filterTrioVCFandAnnotateandParseAndRenameAnnovarAnnotation.trio.${TRIOID}.sh.err"
WALLTIME="08:59:00"
NUMTASKS="1"
NUMCPUS="16"
MEM="40G"
TMPSPACE="200G"
JOBFILE="$JOBDIR/$PROJECTNAME.filterTrioVCFandAnnotateandParseAndRenameAnnovarAnnotation.trio.${TRIOID}.sh"


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
#$ -pe threaded $NUMCPUS
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


module load gatk/4.0.8.1

#Extract trio from VCF
java -Djava.io.tmpdir=\$TMPDIR -Xmx20G \\
-jar \$GATK4 \\
SelectVariants \\
-R $REFGENOME \\
-V $INPUTVCF \\
-select 'DP > 0' \\
-O $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.vcf.gz

java -Djava.io.tmpdir=\$TMPDIR -Xmx20g \\
-jar \$GATK4 \\
SelectVariants \\
-R $REFGENOME \\
-V $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.vcf.gz \\
-select '! vc.getGenotype(\"$CHILDID\").isHomRef()' \\
-O $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.vcf.gz

java -Djava.io.tmpdir=\$TMPDIR -Xmx20g \\
-jar \$GATK4 \\
SelectVariants \\
-R $REFGENOME \\
-V $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.vcf.gz \\
-select 'vc.getGenotype(\"$CHILDID\").getDP() > 0' \\
-O $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf.gz
    

#Create checksum for output
cd $OUTPUTDIR
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.vcf.gz > ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.vcf.gz.md5
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.vcf.gz > ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.vcf.gz.md5
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf.gz > ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf.gz.md5
cd -



#load modules
module load annovar/20180416
module load R/3.6.1
module load samtools/1.9

echo \"Starting annotation..\"

cd $OUTPUTDIR

gunzip -c $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf.gz \\
> $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf

\$annovar/convert2annovar.pl \\
-format vcf4old \\
$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf \\
> $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.txt \\
-include \\
-withzyg \\
-allallele

\$annovar/table_annovar.pl \\
--thread 16 \\
$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.txt \\
software/Annovar/hg38/ \\
-protocol refGene,cytoBand,avsnp150,cosmic70,clinvar_20190305,gnomad30_genome,exac03,dbnsfp35a,cadd15,revel,dbscsnv11,regsnpintron,intervar_20180118,gwasCatalog \\
-operation gx,r,f,f,f,f,f,f,f,f,f,f,f,r \\
-otherinfo \\
-outfile $OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar \\
-buildver hg38 \\
-polish \\
-remove \\
-xref /gene_fullxref.txt

echo \"Finished annotation.\"


#Create checksum for output
cd $OUTPUTDIR
bgzip -@ 16 ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.hg38_multianno.txt
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.hg38_multianno.txt.gz > ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.hg38_multianno.txt.gz.md5
cd -



Rscript parseAndRenameAnnovarAnnotationTrioAnalysis.R \\
$TRIOID \\
$TRIOFILE \\
$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.hg38_multianno.txt.gz \\
$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.vcf \\
$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.txt

#perl $PROJECTDIR/CODE/automaticVariantListFiltration/annotateVariantListWithFilterColumns.v2.pl \\
#$PROJECTDIR/CODE/automaticVariantListFiltration/WES-KidTs_genes_open.txt \\
#$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.txt \\
#$CHILDID \\
#$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.filtersApplied.txt \\
#$OUTPUTDIR/${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.filtersApplied.popFreqLT10perc.txt

echo \"Finished annotation.\"


#Create checksum for output
cd $OUTPUTDIR
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.txt > ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.txt.md5
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.filtersApplied.txt > ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.filtersApplied.txt.md5
md5sum ${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.filtersApplied.popFreqLT10perc.txt >${PROJECTNAME}.trio.${TRIOID}.noHomRefSites.rmChildHomRef.childDPgt0.annovar.parsed.filtersApplied.popFreqLT10perc.txt.md5
cd -



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

