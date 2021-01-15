BATCHDIR="batch1/"
PROJECTDIR="/hpc/pmc_kuiper/spost/BladderCancer/CODE/"
PIPELINEDIR="$PROJECTDIR/pmc_kuiper_pipelines/wdl_pipeline_v2.1.0/wdl/"
INPUTDIR="$PROJECTDIR/runConfigs/haplotypeCaling/$BATCHDIR/"
WDL="$PIPELINEDIR/genotype_calling_single_sample_workflow.wdl"



mkdir -p $INPUTDIR

#Zip pipeline and dependencies
cd $PIPELINEDIR
zip workflowDependencies.zip \
cnv_common_tasks.wdl \
dataprep.wdl \
getVersion.wdl \
simpleChecks.wdl \
picard.wdl \
structureConversion.wdl \
align.wdl \
qc.wdl \
genomicIntervals.wdl \
gatk.wdl \
samtools.wdl \
bedTools.wdl \
ensemblVep.wdl \
map_keys.wdl \
dataconnections.wdl \
annotate.wdl \
molgenis.wdl
cd -


#Move dependencies zip to json directory
mv $PIPELINEDIR/workflowDependencies.zip $INPUTDIR

#Execute pipeline using cromwell

for JSON in $( ls $INPUTDIR/*.json )
do
echo "$JSON"
    
curl -X POST "https://spost.hpccw.op.umcutrecht.nl/api/workflows/v1" \
  --user spost:Jo+vie2K \
    --header "accept: application/json" \
    --header "Content-Type: multipart/form-data" \
    --form "workflowSource=@$WDL" \
    --form "workflowInputs=@$JSON" \
    --form "workflowDependencies=@$INPUTDIR/workflowDependencies.zip"

echo ""


done



#Check progress
#curl -X GET "https://spost.hpccw.op.umcutrecht.nl/api/workflows/v1/3c5ff852-9d74-4e7d-9edb-a5372e096d16/status" --user spost:Jo+vie2K
#curl -X GET "https://spost.hpccw.op.umcutrecht.nl/api/workflows/v1/7fe1cee1-75f6-4fa8-a3ad-f179de070c5a/metadata" --user spost:Jo+vie2K
#curl -X POST "https://spost.hpccw.op.umcutrecht.nl/api/workflows/v1/7fe1cee1-75f6-4fa8-a3ad-f179de070c5a/abort" --user spost:Jo+vie2K






