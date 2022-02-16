#!/bin/sh
#$ -S /bin/sh

/DDN5/sys/usr_local7/common_tools/cellranger-5.0.1/bin/cellranger count --id=run_count_hFK \
--fastqs=/home/tatsuya.shimizu/Data/out_SRR6997880/H16w_Results_3_MissingLibrary_1_HHHGGBGX2 \
--transcriptome=/home/tatsuya.shimizu/Data/refdata-gex-GRCh38-2020-A --localcores 24