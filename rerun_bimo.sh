
date && echo "start bimo-medium uni long" && \
./run_bench_Array_granular.sh myapp bimo-medium 10 uni-moderate && \
date && echo "starting ratio" && \
./run_ratio_fig2_bimo.sh myapp && date && echo "all done"
