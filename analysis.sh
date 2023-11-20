conda activate bio

dir=/Users/arturo/Documents/PhD/Teaching/Bioinfo/datasets/outbreak

bam=$dir/bam
vcf=$dir/vcf
aln=$dir/aln

out_dir=$dir/results

mkdir -p $out_dir
mkdir -p $bam
mkdir -p $vcf
mkdir -p $aln

ref=$dir/reference.fa
bwa index $ref

for n in {1..20}; do
    bwa mem -R "@RG\tID:sample${n}\tSM:sample${n}" $ref $dir/fastq/sample${n}.fq | samtools view -bS - | samtools sort -@ 4 -T $bam/sample${n}.temp -O bam -o $bam/sample${n}.bam;
done;

for n in {1..20}; do
    bcftools mpileup -a AD,ADF,ADR,DP,SP -f $ref $bam/sample${n}.bam | bcftools call -A -mv -Oz -o $vcf/sample${n}.vcf.gz
    tabix -p vcf $vcf/sample${n}.vcf.gz
done

for n in {1..20}; do
    bcftools consensus -f $ref $vcf/sample${n}.vcf.gz | sed 's/>Chromosome/>sample'"${n}"'/' > $aln/sample${n}.fa
done


cat $aln/* > $out_dir/samples_aln.fa
snp-sites -o $out_dir/samples_aln.fa $out_dir/samples_aln.fa



