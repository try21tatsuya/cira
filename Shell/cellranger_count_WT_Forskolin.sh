#!/bin/sh
#$ -S /bin/sh

/DDN5/sys/usr_local7/common_tools/cellranger-5.0.1/bin/cellranger count --id=run_count_Forskolin \
--fastqs=/home/tatsuya.shimizu/Data/DrOsafune_5sc \
--sample=WT_Forskolin \
--transcriptome=/home/tatsuya.shimizu/Data/refdata-gex-GRCh38-2020-A