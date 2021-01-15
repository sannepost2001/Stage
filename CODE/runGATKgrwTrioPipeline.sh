

BATCHDIR="batch4/"
PROJECTDIR="/"
PIPELINEDIR="$PROJECTDIR//wdl/"
INPUTDIR="$PROJECTDIR//$BATCHDIR/"
WDL="$PROJECTDIR/gatkgrw.wdl"



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
  --user USER:PASSWORD \
    --header "accept: application/json" \
    --header "Content-Type: multipart/form-data" \
    --form "workflowSource=@$WDL" \
    --form "workflowInputs=@$JSON" \
    --form "workflowDependencies=@$INPUTDIR/workflowDependencies.zip"

echo ""


done





