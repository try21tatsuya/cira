#!/bin/sh
#$ -S /bin/sh

/DDN5/sys/usr_local7/common_tools/cellranger-5.0.1/bin/cellranger bamtofastq --nthreads=24 \
SRR5930492_H_16w_Cortex_sorted.bam.1 \
/home/tatsuya.shimizu/yard/out_SRR5930492