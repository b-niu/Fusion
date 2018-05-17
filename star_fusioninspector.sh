#!/usr/bin/bash
# STAR_FUSION_HOME=/thinker/storage/udata/bing/biosoft/STAR-Fusion-v1.4.0
cd /thinker/storage/udata/bing/FUSION/GRCh37_v19_CTAT_lib_Feb092018
# $STAR_FUSION_HOME/FusionFilter/prep_genome_lib.pl \
#     --genome_fa ref_genome.fa \
#     --gtf ref_annot.gtf \
#     --fusion_annot_lib CTAT_HumanFusionLib.v0.1.0.dat.gz \
#     --annot_filter_rule AnnotFilterRule.pm \
#     --pfam_db PFAM.domtblout.dat.gz 
# 安装STAR和STAR-FUSION
conda install star star-fusion
prep_genome_lib.pl \
    --genome_fa ref_genome.fa \
    --gtf ref_annot.gtf \
    --fusion_annot_lib CTAT_HumanFusionLib.v0.1.0.dat.gz \
    --annot_filter_rule AnnotFilterRule.pm \
    --pfam_db PFAM.domtblout.dat.gz

STAR-Fusion --genome_lib_dir /path/to/your/CTAT_resource_lib \
             --left_fq reads_1.fq \
             --right_fq reads_2.fq \
             --output_dir star_fusion_outdir

STAR-Fusion --genome_lib_dir /thinker/storage/udata/bing/FUSION/GRCh37_v19_CTAT_lib_Feb092018 \
             --left_fq reads_1.fq \           --output_dir star_fusion_outdir

# bedtools bamtofastq [OPTIONS] -i <BAM> -fq <FASTQ>
# http://bedtools.readthedocs.io/en/latest/content/tools/bamtofastq.html

for i in *.bam
do
bamToFastq -i $i -fq ${i%.bam}.fq
done



# 二步法
star_index_dir=/thinker/storage/udata/bing/FUSION/GRCh37_v19_CTAT_lib_Feb092018/ctat_genome_lib_build_dir
STAR \
    --genomeDir $star_index_dir/ref_genome.fa.star.idx \
    --readFilesIn IonXpress_023_R_2018_04_24_23_14_51_user_BBDefault-140-20180425_Auto_user_BBDefault-140-20180425_227.fq \
    --twopassMode Basic \
    --outReadsUnmapped None \
    --chimSegmentMin 12 \
    --chimJunctionOverhangMin 12 \
    --alignSJDBoverhangMin 10 \
    --alignMatesGapMax 100000 \
    --alignIntronMax 100000 \
    --chimSegmentReadGapMax 3 \
    --alignSJstitchMismatchNmax 5 -1 5 5 \
    --runThreadN 56 \
    --outSAMstrandField intronMotif

/thinker/storage/udata/bing/biosoft/STAR-Fusion-v1.4.0/STAR-Fusion \
--genome_lib_dir $star_index_dir \
-J Chimeric.out.junction \
--output_dir star_fusion_outdir


# 一步法
/thinker/storage/udata/bing/biosoft/STAR-Fusion-v1.4.0/STAR-Fusion \
    --genome_lib_dir /thinker/storage/udata/bing/FUSION/GRCh37_v19_CTAT_lib_Feb092018/ctat_genome_lib_build_dir \
    --left_fq IonXpress_033_R_2018_04_24_23_14_51_user_BBDefault-140-20180425_Auto_user_BBDefault-140-20180425_227.fq \
    --output_dir star_fusion_033 \
    --CPU 56 \
    --STAR_SortedByCoordinate \
    --STAR_limitBAMsortRAM 240G

# 查错的结果是：conda给的star-fusion有bug。从源代码编译的可用。

for i in *.fq; do
short_name="$(echo $i | cut -d _ -f 1,2)"
mv $i $short_name
mkdir $short_name.star_fusion
done

for i in *.fq; do
short_name="$(echo $i | cut -d _ -f 1,2)"
echo $short_name
mv $i $short_name.fq
mkdir $short_name.star_fusion
done

for i in *.fq; do
/thinker/storage/udata/bing/biosoft/STAR-Fusion-v1.4.0/STAR-Fusion \
    --genome_lib_dir /thinker/storage/udata/bing/FUSION/GRCh37_v19_CTAT_lib_Feb092018/ctat_genome_lib_build_dir \
    --left_fq $i \
    --output_dir ${i%.fq}.star_fusion \
    --CPU 56 \
    --STAR_SortedByCoordinate \
    --STAR_limitBAMsortRAM 240G
done

# 参考 https://github.com/STAR-Fusion/STAR-Fusion/wiki


# https://github.com/FusionInspector/FusionInspector/wiki
conda install -y fusion-inspector trinity


cat star-fusion.fusion_predictions.abridged.tsv | cut -f 1 | sed -n '2,$p' > fusions.listA.txt
CTAT_genome_lib=/thinker/storage/udata/bing/FUSION/GRCh37_v19_CTAT_lib_Feb092018/ctat_genome_lib_build_dir

FusionInspector --fusions ./fusions.listA.txt \
                --genome_lib $CTAT_genome_lib \
                --left_fq IonXpress_026.fq \
                --out_dir my_FusionInspector_outdir \
                --out_prefix finspector \
                --prep_for_IGV \
                --CPU 56

igv.sh -g `pwd`/finspector.fa \
`pwd`/finspector.gtf,`pwd`/finspector.spanning_reads.bam,`pwd`/finspector.junction_reads.bam
