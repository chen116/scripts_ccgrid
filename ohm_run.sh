

#date && echo "start uni light uni moderate" && \
#./run_bench_Array_granular.sh myapp uni-light 10 uni-moderate && \
#date && echo "start uni medium uni moderate" && \
#./run_bench_Array_granular.sh myapp uni-medium 10 uni-moderate && \
#date && echo "start uni heavy uni moderate" && \
#./run_bench_Array_granular.sh myapp uni-heavy 10 uni-moderate && \

./ohm.sh myapp bimo-medium 10 uni-longRTXen && \
date && echo "start bimo-medium uni moderate" && \
./ohm_bimo_moderate.sh myapp bimo-medium 10 uni-moderate && \
echo "all done"


#date && echo "start uni light uni moderate" && \
#./run_bench_Array.sh myapp uni-light 10 uni-moderate && \
#date && echo "start uni medium uni moderate" && \
#./run_bench_Array.sh myapp uni-medium 10 uni-moderate && \
#date && echo "start uni heavy uni moderate" && \
#./run_bench_Array.sh myapp uni-heavy 10 uni-moderate && \#
#date && echo "start bimo-medium uni long" && \
#./run_bench_Array.sh myapp bimo-medium 10 uni-long && \
#date && echo "done all rerun"
