#!/bin/bash

# 自动检测CPU核心数
THREADS=$(grep -c ^processor /proc/cpuinfo)

# 带进度监控的并行执行
parallel -j ${THREADS} --progress --eta --bar \
    'mkdir -p ./prodigal/{/.} && \
    prodigal -i {} \
             -a ./prodigal/{/.}/{/.}.faa \
             -d ./prodigal/{/.}/{/.}.fna \
             -f gff -g 11 \
             -o ./prodigal/{/.}/{/.}.gff \
             -s ./prodigal/{/.}/{/.}.stat \
             -p meta -q 2>&1 | tee ./prodigal/{/.}.log || \
    echo "{} failed" >> ./prodigal/error.log' ::: *.fasta

# 结果统计
printf "\n=== 执行结果统计 ===\n"
find ./prodigal -name "*.faa" | wc -l | xargs echo "成功预测文件:"
grep -c "failed" ./prodigal/error.log 2>/dev/null | xargs echo "失败文件:"

# 生成MD5校验文件
find ./prodigal -type f -exec md5sum {} + > ./prodigal/results.md5
