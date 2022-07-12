samplelist=$1

cat ${samplelist} |while read runID sampleID method sa date f1 f2;do
if [ -s read_mapping/${sa}.bam ];then
csub -q batch -N map_add -p2 -m 2gb -w 70:00:00 -c " 

bowtie2 -x NC_045512.fasta.index -1 $f1  -2 $f2  --very-fast-local -p4|samtools view -h -bS -F4 -q20 - > read_mapping/${runID}.bam
mv read_mapping/${sa}.bam read_mapping/${sa}_1.bam
samtools merge read_mapping/${sa}.bam read_mapping/${sa}_1.bam read_mapping/${runID}.bam
samtools sort read_mapping/${sa}.bam read_mapping/${sa}.sort
samtools index read_mapping/${sa}.sort.bam
samtools mpileup -f NC_045512.fasta read_mapping/$sa.sort.bam -d 100000 -Q 20 >read_mapping/$sa.mpileup
perl mpileup2ntFreq.pl read_mapping/$sa.mpileup > read_mapping/$sa.ntfreq
perl iSNV_from_ntFreq.pl read_mapping/$sa.mpileup ref_alt > read_mapping/$sa.ra.iSNV
perl iSNV_from_ntFreq.pl read_mapping/$sa.mpileup major_minor > read_mapping/$sa.mm.iSNV
"
else 
csub -q batch -N map -p2 -m 2gb -w 70:00:00 -c " 

bowtie2 -x /newpool/bioinfo/dupc/database/2019-nCoV/NC_045512.fasta.index -1 $f1  -2 $f2  --very-fast-local -p4|samtools view -h -bS -F4 -q20 - > read_mapping/$sa.bam
samtools sort read_mapping/$sa.bam read_mapping/$sa.sort
samtools index read_mapping/$sa.sort.bam
samtools mpileup -f NC_045512.fasta read_mapping/$sa.sort.bam -d 100000 -Q 20 >read_mapping/$sa.mpileup
perl mpileup2ntFreq.pl read_mapping/$sa.mpileup > read_mapping/$sa.ntfreq
perl iSNV_from_ntFreq.pl read_mapping/$sa.mpileup ref_alt > read_mapping/$sa.ra.iSNV
perl iSNV_from_ntFreq.pl read_mapping/$sa.mpileup major_minor > read_mapping/$sa.mm.iSNV"
fi
done
