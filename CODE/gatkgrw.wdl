import "structureConversion.wdl" as StructureConversion
import "genomicIntervals.wdl" as GenomicIntervals


task GenotypeGVCF {
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File intervallist
  File gvcf
  File gvcfidx
  String base_filename

  command {
    module load gatk/4.0.8.1

    java -Xmx30g -Xms30g -jar $GATK4 \
    GenotypeGVCFs \
    -R ${ref_fasta} \
    -V ${gvcf} \
    -L ${intervallist} \
    -O ${base_filename}_genotype.vcf
  }
  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "14:59:00"
  }
  output {
    File genotype_vcf = "${base_filename}_genotype.vcf"
    File genotype_vcf_index = "${base_filename}_genotype.vcf.idx"
  }
}

task MergeVCFs {
  String vcf_exp
  Array[File] genotype_vcf
  Array[File] genotype_vcf_index
  String base_filename

  # using MergeVcfs instead of GatherVcfs so we can create indices
  # See https://github.com/broadinstitute/picard/issues/789 for relevant GatherVcfs ticket
  command {
    module load picardtools/2.10.10
    java -Djava.io.tmpdir=$TMPDIR -Xmx6G -jar $PICARD \
    MergeVcfs \
    INPUT=${sep=' INPUT=' genotype_vcf} \
    OUTPUT=${base_filename}_genotype_merged.vcf
  }
  output {
    File merged_output_vcf = "${base_filename}_genotype_merged.vcf"
    File merged_output_vcf_index = "${base_filename}_genotype_merged.vcf.idx"
  }
  runtime {
    cpu : "1"
    memory : "8 GB"
    tmpspace_gb : "300"
    wallclock : "14:59:00"
  }
}

task VariantRecalibrator_SNP {
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File merged_output_vcf
  File merged_output_vcf_index
  File hapmap_vcfgz
  File hapmap_vcfgz_index
  File omni_vcfgz
  File omni_vcfgz_index
  File dbsnp_vcfgz
  File dbsnp_vcfgz_index
  File T1000G_vcfgz
  File T1000G_vcfgz_index
  File intervallist
  String base_filename

  command {
    module load gatk/4.0.8.1

    java -Djava.io.tmpdir=$TMPDIR -Xmx30g -Xms30g -jar $GATK4 \
    VariantRecalibrator \
    -R ${ref_fasta} \
    -V ${merged_output_vcf} \
    --resource hapmap,known=false,training=true,truth=true,prior=15:${hapmap_vcfgz} \
    --resource omni,known=false,training=true,truth=true,prior=12:${omni_vcfgz} \
    --resource dbsnp,known=true,training=false,truth=false,prior=7:${dbsnp_vcfgz} \
    --resource 1000G,known=false,training=true,truth=false,prior=10:${T1000G_vcfgz} \
    -an QD -an DP -an MQ \
    -mode SNP \
    --tranches-file ${base_filename}_genotype_snp_tranches_file \
    -L ${intervallist} \
    -O ${base_filename}_genotype_recal

  }
  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "03:59:00"
  }
  output {
    File genotype_recal = "${base_filename}_genotype_recal"
    File genotype_recal_index = "${base_filename}_genotype_recal.idx"
    File genotype_snp_tranches_file = "${base_filename}_genotype_snp_tranches_file"
  }
}
task ApplyVQSR_SNP {
  File merged_output_vcf
  File merged_output_vcf_index
File genotype_recal
File genotype_recal_index
File genotype_snp_tranches_file
File intervallist
  String base_filename

  command {
    module load gatk/4.0.8.1

    java -Djava.io.tmpdir=$TMPDIR -Xmx30g -Xms30g -jar $GATK4 \
    ApplyVQSR \
    -V ${merged_output_vcf} \
    -mode SNP \
    --truth-sensitivity-filter-level 99.7 \
    --tranches-file ${genotype_snp_tranches_file} \
    --recal-file ${genotype_recal} \
    --create-output-variant-index true \
    -L ${intervallist} \
    -O ${base_filename}_genotype_tmpSNP.vcf
  }
  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "00:59:00"
  }
  output {
    File genotype_tmpSNP_vcf = "${base_filename}_genotype_tmpSNP.vcf"
    File genotype_tmpSNP_vcf_index = "${base_filename}_genotype_tmpSNP.vcf.idx"
  }
}
task VariantRecalibrator_INDEL {
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File genotype_tmpSNP_vcf
  File genotype_tmpSNP_vcf_index
  File dbsnp_vcfgz
File dbsnp_vcfgz_index
  File mills_vcfgz
File mills_vcfgz_index
  File axiom_vcfgz
File axiom_vcfgz_index
File intervallist
  String base_filename

  command {
    module load gatk/4.0.8.1

    java -Djava.io.tmpdir=$TMPDIR -Xmx30g -Xms30g -jar $GATK4 \
    VariantRecalibrator \
    -R ${ref_fasta} \
    -V ${genotype_tmpSNP_vcf} \
    --resource dbsnp,known=true,training=false,truth=false,prior=7:${dbsnp_vcfgz} \
    --resource mills,known=false,training=true,truth=true,prior=12:${mills_vcfgz} \
    --resource axiomPoly,known=false,training=true,truth=false,prior=10:${axiom_vcfgz} \
-an QD -an DP -an MQ \
    -mode INDEL \
    --tranches-file ${base_filename}_genotype_indel_tranches_file \
    -L ${intervallist} \
    -O ${base_filename}_genotype_indel_recal

  }
  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "03:59:00"
  }
  output {
    File genotype_indel_recal = "${base_filename}_genotype_indel_recal"
    File genotype_indel_recal_index = "${base_filename}_genotype_indel_recal.idx"
    File genotype_indel_tranches_file = "${base_filename}_genotype_indel_tranches_file"
  }
}
task ApplyVQSR_INDEL {
  File genotype_tmpSNP_vcf
  File genotype_tmpSNP_vcf_index
File genotype_indel_recal
File genotype_indel_recal_index
File genotype_indel_tranches_file
File intervallist
  String base_filename

  command {
    module load gatk/4.0.8.1

    java -Djava.io.tmpdir=$TMPDIR -Xmx30g -Xms30g -jar $GATK4 \
    ApplyVQSR \
    -V ${genotype_tmpSNP_vcf} \
    -mode INDEL \
    --truth-sensitivity-filter-level 99.7 \
    --tranches-file ${genotype_indel_tranches_file} \
    --recal-file ${genotype_indel_recal} \
    --create-output-variant-index true \
    -L ${intervallist} \
    -O ${base_filename}_genotype_tmpSNP_VQSR.vcf
  }
  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "00:59:00"
  }
  output {
    File genotype_tmpSNP_VQSR_vcf = "${base_filename}_genotype_tmpSNP_VQSR.vcf"
    File genotype_tmpSNP_VQSR_vcf_index = "${base_filename}_genotype_tmpSNP_VQSR.vcf.idx"
  }
}
task CalculateGenotypePosteriors {
  File supporting_vcf
File supporting_vcf_index
  File ped_file
  File genotype_tmpSNP_VQSR_vcf
  File genotype_tmpSNP_VQSR_vcf_index
  File intervallist
  String base_filename

  command {
    module load gatk/4.0.8.1

    java -Djava.io.tmpdir=$TMPDIR -Xmx30g -Xms30g -jar $GATK4 \
    CalculateGenotypePosteriors \
    --supporting ${supporting_vcf} \
    --pedigree ${ped_file} \
    -V ${genotype_tmpSNP_VQSR_vcf} \
    -L ${intervallist} \
    -O ${base_filename}_genotype_tmpSNP_VQSR_genotype.vcf
  }
  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "02:59:00"
  }
  output {
    File genotype_tmpSNP_VQSR_genotype_vcf = "${base_filename}_genotype_tmpSNP_VQSR_genotype.vcf"
    File genotype_tmpSNP_VQSR_genotype_vcf_index = "${base_filename}_genotype_tmpSNP_VQSR_genotype.vcf.idx"
  }
}
task VariantFiltration {
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File genotype_tmpSNP_VQSR_genotype_vcf
  File genotype_tmpSNP_VQSR_genotype_vcf_index
  File intervallist
  String base_filename

  command {
    #..load module..
    module load gatk/4.0.8.1
    
    #check that the input vcf is not empty

    #..run..
    java -Djava.io.tmpdir=$TMPDIR -Xmx30g -Xms30g -jar $GATK4 \
    VariantFiltration \
    -R ${ref_fasta} \
    -V ${genotype_tmpSNP_VQSR_genotype_vcf} \
    --filter-expression "QD < 2.0" \
    --filter-expression "FS > 60.0" \
    --filter-expression "MQ < 40.0" \
    --filter-expression "MQRankSum < -12.5" \
    --filter-expression "ReadPosRankSum < -8.0" \
    --filter-expression "HaplotypeScore > 13.0" \
    --filter-name "SNP_LowQualityDepth" \
    --filter-name "SNP_StrandBias" \
    --filter-name "SNP_MappingQuality" \
    --filter-name "SNP_MQRankSumLow" \
    --filter-name "SNP_ReadPosRankSumLow" \
    --filter-name "SNP_HaplotypeScoreHigh" \
    -L ${intervallist} \
    -O ${base_filename}_genotype_tmpSNP_VQSR_genotype_flt.vcf

#echo "append this text2" >> /hpc/pmc_kuiper/PBT_test/DATA/VF2.txt
  }

  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "00:59:00"
  }
  output {
    File genotype_tmpSNP_VQSR_genotype_flt_vcf = "${base_filename}_genotype_tmpSNP_VQSR_genotype_flt.vcf"
    File genotype_tmpSNP_VQSR_genotype_flt_vcf_index = "${base_filename}_genotype_tmpSNP_VQSR_genotype_flt.vcf.idx"
  }
}
task VariantAnnotator {
  String tmp_dir
  File ref_fasta
  File ref_fasta_index
  File ref_dict
File ped_file
  File genotype_tmpSNP_VQSR_genotype_flt_vcf
  File genotype_tmpSNP_VQSR_genotype_flt_vcf_index
  File intervallist
  String base_filename


  command {
    #..load module..
    module load gatk/all
    #gatk/3.8-1-0-gf15c1c3ef
    
    #check that the input vcf is not empty

    #..run..
    java -Djava.io.tmpdir=$TMPDIR -jar $GATK35 \
    -T VariantAnnotator \
    -R ${ref_fasta} \
    -V ${genotype_tmpSNP_VQSR_genotype_flt_vcf} \
    -A PossibleDeNovo \
    -ped ${ped_file} \
    -L ${intervallist} \
    -o ${base_filename}_genotype_flt_An.vcf
  }

  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "02:59:00"
  }
  output {
    File genotype_flt_An_vcf = "${base_filename}_genotype_flt_An.vcf"
    File genotype_flt_An_vcf_index = "${base_filename}_genotype_flt_An.vcf.idx"
  }
}
task filter_vqsr_pass_samples {
  File genotype_flt_An_vcf
  File genotype_flt_An_vcf_index
  String base_filename

  command {
    #..load module..
    module load bcftools

    #..run..
    bcftools view -Ov -f 'PASS' ${genotype_flt_An_vcf} > ${base_filename}_genotype_flt_flt_An_pass.vcf
  }

  runtime {
    cpu: "1"
    memory: "45 GB"
    tmpspace_gb: "12"
    wallclock: "00:10:00"
  }
  output {
    File genotype_flt_flt_An_pass_vcf = "${base_filename}_genotype_flt_flt_An_pass.vcf"
    File genotype_flt_flt_An_pass_vcf_index = "${base_filename}_genotype_flt_flt_An_pass.vcf.idx"
  }
}
task filter_low_complexity_regions {
  File genotype_flt_An_vcf
  File genotype_flt_An_vcf_index
  File regions_bed
  String base_filename


  command {
    #..load module..
    module load vcftools

    #..run..
    vcftools --vcf ${genotype_flt_An_vcf} \
    --exclude-positions ${regions_bed} \
    --recode \
    --recode-INFO-all \
    --out ${base_filename}_genotype_flt_fltLCR
  }

  runtime {
    cpu: "1"
    memory: "35 GB"
    tmpspace_gb: "300"
    wallclock: "02:59:00"
  }
  output {
    File genotype_flt_flt_An_pass_fltLCR_vcf = "${base_filename}_genotype_flt_flt_An_pass_fltLCR.recode.vcf"
    File genotype_flt_flt_An_pass_fltLCR_vcf_index = "${base_filename}_genotype_flt_flt_An_pass_fltLCR.recode.vcf.idx"
  }
}














workflow TrioGenotypeCalling {
  #..input parameters..
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File gvcf
  File gvcfidx
  File hapmap_vcfgz
  File hapmap_vcfgz_index
  File omni_vcfgz
  File omni_vcfgz_index
  File dbsnp_vcfgz
  File dbsnp_vcfgz_index
  File T1000G_vcfgz
  File T1000G_vcfgz_index
  File mills_vcfgz
  File mills_vcfgz_index
  File axiom_vcfgz
  File axiom_vcfgz_index
  File supporting_vcf
  File supporting_vcf_index
  File ped_file
  File regions_bed
  File intervallist
  Array[File] scattered_calling_intervals
  String vcf_exp
  String base_filename
  String tmp_dir

#File genotype_tmpSNP_VQSR_vcf
#File genotype_vcf
#File genotype_tmpSNP_VQSR_genotype_flt_vcf

#Genotype GVCF files by interval
scatter (subInterval in scattered_calling_intervals) {
  call GenotypeGVCF {
    input:
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      intervallist = subInterval,
      gvcf = gvcf,
      gvcfidx = gvcfidx,
      base_filename = base_filename
  }
 } 
  
  
# Combine by-interval VCFs into a single sample VCF file
  call MergeVCFs{
    input:
      genotype_vcf = GenotypeGVCF.genotype_vcf,
      genotype_vcf_index = GenotypeGVCF.genotype_vcf_index,
      vcf_exp = vcf_exp,
      base_filename = base_filename
  }
  
  call VariantRecalibrator_SNP {
    input:
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      merged_output_vcf = MergeVCFs.merged_output_vcf,
      merged_output_vcf_index = MergeVCFs.merged_output_vcf_index,
      hapmap_vcfgz = hapmap_vcfgz,
      hapmap_vcfgz_index = hapmap_vcfgz_index,
      omni_vcfgz = omni_vcfgz,
      omni_vcfgz_index = omni_vcfgz_index,
      dbsnp_vcfgz = dbsnp_vcfgz,
      dbsnp_vcfgz_index = dbsnp_vcfgz_index,
      T1000G_vcfgz = T1000G_vcfgz,
      T1000G_vcfgz_index = T1000G_vcfgz_index,
      intervallist = intervallist,
      base_filename = base_filename
  }
  call ApplyVQSR_SNP {
    input:
      merged_output_vcf = MergeVCFs.merged_output_vcf,
      merged_output_vcf_index = MergeVCFs.merged_output_vcf_index,
      genotype_snp_tranches_file = VariantRecalibrator_SNP.genotype_snp_tranches_file,
      genotype_recal = VariantRecalibrator_SNP.genotype_recal,
      genotype_recal_index = VariantRecalibrator_SNP.genotype_recal_index,
      intervallist = intervallist,
      base_filename = base_filename
  }
  call VariantRecalibrator_INDEL {
    input:
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      genotype_tmpSNP_vcf = ApplyVQSR_SNP.genotype_tmpSNP_vcf,
      genotype_tmpSNP_vcf_index = ApplyVQSR_SNP.genotype_tmpSNP_vcf_index,
      dbsnp_vcfgz = dbsnp_vcfgz,
      dbsnp_vcfgz_index = dbsnp_vcfgz_index,
      mills_vcfgz = mills_vcfgz,
      mills_vcfgz_index = mills_vcfgz_index,
      axiom_vcfgz = axiom_vcfgz,
      axiom_vcfgz_index = axiom_vcfgz_index,
      intervallist = intervallist,
      base_filename = base_filename
  }
  call ApplyVQSR_INDEL {
    input:
      genotype_tmpSNP_vcf = ApplyVQSR_SNP.genotype_tmpSNP_vcf,
      genotype_tmpSNP_vcf_index = ApplyVQSR_SNP.genotype_tmpSNP_vcf_index,
      genotype_indel_recal = VariantRecalibrator_INDEL.genotype_indel_recal,
      genotype_indel_tranches_file = VariantRecalibrator_INDEL.genotype_indel_tranches_file,
      genotype_indel_recal_index = VariantRecalibrator_INDEL.genotype_indel_recal_index,
      intervallist = intervallist,
      base_filename = base_filename
  }
  call CalculateGenotypePosteriors {
    input:
      supporting_vcf = supporting_vcf,
      supporting_vcf_index = supporting_vcf_index,
      ped_file = ped_file,
      genotype_tmpSNP_VQSR_vcf = ApplyVQSR_INDEL.genotype_tmpSNP_VQSR_vcf,
      genotype_tmpSNP_VQSR_vcf_index = ApplyVQSR_INDEL.genotype_tmpSNP_VQSR_vcf_index,
 #genotype_tmpSNP_VQSR_vcf = genotype_tmpSNP_VQSR_vcf,
 intervallist = intervallist,
      base_filename = base_filename
  }
  call VariantFiltration {
    input:
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      genotype_tmpSNP_VQSR_genotype_vcf = CalculateGenotypePosteriors.genotype_tmpSNP_VQSR_genotype_vcf,
      genotype_tmpSNP_VQSR_genotype_vcf_index = CalculateGenotypePosteriors.genotype_tmpSNP_VQSR_genotype_vcf_index,
      intervallist = intervallist,
      base_filename = base_filename
  }
  call VariantAnnotator {
    input:
      tmp_dir = tmp_dir,
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      ped_file = ped_file,
      genotype_tmpSNP_VQSR_genotype_flt_vcf = VariantFiltration.genotype_tmpSNP_VQSR_genotype_flt_vcf,
      genotype_tmpSNP_VQSR_genotype_flt_vcf_index = VariantFiltration.genotype_tmpSNP_VQSR_genotype_flt_vcf_index,
#genotype_tmpSNP_VQSR_genotype_flt_vcf = genotype_tmpSNP_VQSR_genotype_flt_vcf,
intervallist = intervallist,
      base_filename = base_filename
  }
  call filter_low_complexity_regions {
    input:
      genotype_flt_An_vcf = VariantAnnotator.genotype_flt_An_vcf,
      genotype_flt_An_vcf_index = VariantAnnotator.genotype_flt_An_vcf_index,
      regions_bed = regions_bed,
      base_filename = base_filename
  }


  #output {
  #  String status = "PMC GATK-GRW PIPELINE FINISHED!!"
  #}
}
