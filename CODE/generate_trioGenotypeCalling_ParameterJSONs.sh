
####
BATCHDIR="batch4"
PROJECTDIR="/"
PARAMDIR="$PROJECTDIR/trioGenotypeCalling/$BATCHDIR/"
INPUTDIR="$PROJECTDIR//$BATCHDIR/"

for GVCFINPUT in $( ls $INPUTDIR/*.gz)
do
	
	SAMPLE=$(basename $GVCFINPUT .g.vcf.gz)

    
    echo "Generating job for sample: $SAMPLE"

GVCF="$INPUTDIR/$SAMPLE.g.vcf.gz"
GVCFIDX="$INPUTDIR/$SAMPLE.g.vcf.gz.tbi"
PEDFILE="$PROJECTDIR/CODE/$SAMPLE.ped"
BASENAME="$SAMPLE"

## Static, dont change
INTERVALLIST="wgs_calling_regions.hg38.interval_list"


  
#
DATE=$(date --iso-8601=seconds)

mkdir -p "$PARAMDIR/"



#Iterate over chromosomes
declare -a chromosomes=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "X" "Y")


echo "
{
\"TrioGenotypeCalling.gvcf\" : \"$GVCF\",
\"TrioGenotypeCalling.gvcfidx\" : \"$GVCFIDX\",
\"TrioGenotypeCalling.ped_file\" : \"$PEDFILE\",
\"TrioGenotypeCalling.base_filename\" : \"$BASENAME\",
\"TrioGenotypeCalling.intervallist\" : \"$INTERVALLIST\",

\"TrioGenotypeCalling.ref_fasta\" : \"/hg38/decode/genome.fa\",
\"TrioGenotypeCalling.ref_fasta_index\" : \"/hg38/decode/genome.fa.fai\",
\"TrioGenotypeCalling.ref_dict\" : \"/hg38/decode/genome.dict\",
\"TrioGenotypeCalling.hapmap_vcfgz\" : \"/hapmap_3.3.hg38.vcf.gz\",
\"TrioGenotypeCalling.hapmap_vcfgz_index\" : \"/hapmap_3.3.hg38.vcf.gz.tbi\",
\"TrioGenotypeCalling.omni_vcfgz\" : \"/1000G_omni2.5.hg38.vcf.gz\",
\"TrioGenotypeCalling.omni_vcfgz_index\" : \"/1000G_omni2.5.hg38.vcf.gz.tbi\",
\"TrioGenotypeCalling.dbsnp_vcfgz\" : \"/All_20180418.vcf.gz\",
\"TrioGenotypeCalling.dbsnp_vcfgz_index\" : \"/All_20180418.vcf.gz.tbi\",
\"TrioGenotypeCalling.T1000G_vcfgz\" : \"/1000G_phase1.snps.high_confidence.hg38.vcf.gz\",
\"TrioGenotypeCalling.T1000G_vcfgz_index\" : \"//1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi\",
\"TrioGenotypeCalling.mills_vcfgz\" : \"/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz\",
\"TrioGenotypeCalling.mills_vcfgz_index\" : \"/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi\",
\"TrioGenotypeCalling.axiom_vcfgz\" : \"/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz\",
\"TrioGenotypeCalling.axiom_vcfgz_index\" : \"/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi\",
\"TrioGenotypeCalling.supporting_vcf\" : \"/1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf.gz\",
\"TrioGenotypeCalling.supporting_vcf_index\" : \"/1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf.gz.tbi\",
\"TrioGenotypeCalling.regions_bed\" : \"/wgs_calling_regions.hg38.interval_list\",
\"TrioGenotypeCalling.vcf_exp\" : \"*.vcf.gz\",
   \"TrioGenotypeCalling.scattered_calling_intervals\" : [
      \"/scattered_calling_intervals/temp_0001_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0002_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0003_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0004_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0005_of_50/scattered.interval_list\",
    \"/scattered_calling_intervals/temp_0006_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0007_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0008_of_50/scattered.interval_list\",
      \"//scattered_calling_intervals/temp_0009_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0010_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0011_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0012_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0013_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0014_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0015_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0016_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0017_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0018_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0019_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0020_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0021_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0022_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0023_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0024_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0025_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0026_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0027_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0028_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0029_of_50/scattered.interval_list\",
     \"/scattered_calling_intervals/temp_0030_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0031_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0032_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0033_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0034_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0035_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0036_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0037_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0038_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0039_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0040_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0041_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0042_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0043_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0044_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0045_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0046_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0047_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0048_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0049_of_50/scattered.interval_list\",
      \"/scattered_calling_intervals/temp_0050_of_50/scattered.interval_list\"
   ],
\"TrioGenotypeCalling.tmp_dir\" : \"tmp\"
}

">$PARAMDIR/TrioGenotypeCalling.$BASENAME.json

done
