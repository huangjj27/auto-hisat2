# Authored by huangjj27(huangjj.27@qq.com, SYSU Student No.13331087)
# To know more about the author, see https://huangjj27.gitlab.ios/about

# unify the files as follow:
# current_dir
#   |-- data
#         |-- genome.fna    # the genome file
#         |-- samples       # all the RNA samples, sperated into directories
#               |-- one_of_your_sample
#                     |-- R1.fastq.gz
#                     |-- R2.fastq.gz
#   |-- results     # separated by your sample

#!/bin/sh
hisat2_dir=${HISAT2_DIR:-"./hisat2"}
threads=${THREADS:-1}
picard_jar=${PICARD_JAR:-"./picar.jar"}
cufflinks=${CUFFLINKS:-"./cufflinks"}
echo "using ${threads} thread(s) to run the commmands..."

echo "geting fna file."
data_dir=${DATA:-"./data"}

if [ -z ${GENOME} ]; then
    echo "ERR: genome file(.fna) is not set"
    echo "HINT: rerun the script will a param \"GENOME=your_genome_file_basename\""
    echo "EXAMPLE: GENOME=genome ./auto-hisat2.sh"

    exit 1
fi

fna="${data_dir}/${GENOME}.fna"
echo "using genome file ${fna}"

rm -rf results
mkdir results

for sample in `ls ${data_dir}/samples`
do
    echo "dealing with sample #${sample}"
    mkdir ./results/${sample}

    echo "indexing sample #${sample}"
    current_indices="./results/${sample}/indices"
    mkdir ${current_indices}
    ${hisat2_dir}/hisat2-build -p ${threads} \
        -f ${fna} \
        "${current_indices}/sample_${sample}" \
        1> "./results/${sample}/index.log" \
        2> "./results/${sample}/index.err" \
    echo "indexing sample #${sample} done!"
    
    echo "aligning sample #${sample}"
    ${hisat2_dir}/hisat2-align-s -p ${threads} \
        -x "${current_indices}/sample_${sample}" \
        -1 "${data_dir}/samples/${sample}/R1.fastq.gz" \
        -2 "${data_dir}/samples/${sample}/R2.fastq.gz" \
        -S "./results/${sample}/align.sam" \
        1> "./results/${sample}/align.log" \
        2> "./results/${sample}/align.err"
    echo "aligning sample #${sample} done!"

    echo "using picard and sortSam"
    java -jar ${picard_jar} SortSam \
        INPUT="./results/${sample}/align.sam" \
        OUTPUT="./results/${sample}/picard.sorted.bam" \
        CREATE_INDEX=true \
        SORT_ORDER=coordinate \
        1> "./results/${sample}/picard.log" \
        2> "./results/${sample}/picard.err"
    echo "picard #${sample} done!"

    echo "cufflinking #${sample}"
    ${cufflinks} -p ${threads} \
        --library-type fr-firststrand \
        -o "./results/${sample}/cufflinks-${sample}" \
        "./results/${sample}/picard.sorted.bam" \
        1> "./results/${sample}/cufflinks.log" \
        2> "./results/${sample}/cufflinks.err"
    echo "cufflinking #${sample} done!"
done
