#!/bin/bash

WORK_DIR="/root/experiment-scripts/run-data-fig3/"
PROG=$1
date
#declare -a Dist=("uni-inc1")
declare -a Dist=("uni-inc1" "uni-inc2" "uni-inc3" "uni-inc4" "uni-inc5" "uni-inc6" "uni-inc7" "uni-inc8" "uni-inc9")
#declare -a Dist=("uni-heavy" "uni-medium" "uni-light")
#declare -a Dist=("uni-heavy")
#declare -a PDist=("uni-moderate")
#declare -a Dist=("uni-light" "uni-medium" "uni-heavy")
#declare -a Util=("1" "2" "3" "4" "5" "6" "7" "8")
#declare -a Rep=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")
#declare -a Dist=("single" "double")
#declare -a Dist=("single")
#declare -a PDist=("uni-long")
declare -a PDist=("uni-moderate")
#declare -a Util=("125" "250" "375" "500" "625" "750" "875" "1000")
declare -a Util=("2.0" "3.0" "4.0" "6.0" "6.2")
#declare -a Util=("1" "2" "3" "4" )
#declare -a Util=("5" "6" "7"  )
declare -a Rep=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24")
#declare -a Rep=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

cd "$WORK_DIR""/""$PROG"; rm -f *ratio*

for pdist in "${PDist[@]}"
do
for dist in "${Dist[@]}"
do
  for util in "${Util[@]}"
  do
    for rep in "${Rep[@]}"
    do
      dtdir="$dist""_""$pdist""_""$util"_"$rep"
      cd $dtdir; rm -f all; rm -f wcl;
      st_job_stats *.bin > all
      sum=0
      success=0
      fail=0
      pids=(`grep -r PID all | grep $1 | awk '{print $4}' | grep -Eo "[[:digit:]]*"`)
      pLen=${#pids[@]}
      for ((i=0; i<${pLen}; i++))
      do
        lines=`grep "${pids[$i]}" all | grep 000000 | grep -v "task" | wc -l`
        lines_s=`grep "${pids[$i]}" all | grep 000000 | grep " 0, " | wc -l`
        lines_f=`grep "${pids[$i]}" all | grep 000000 | grep " 1, " | wc -l`
        echo $lines $lines_s $lines_f >> ./wcl
        sum=`expr $sum + $lines`
        success=`expr $success + $lines_s`
        fail=`expr $fail + $lines_f`
	if [ $fail -gt 0 ]
	then
		ratio=0
	else
		ratio=1
	fi
      done

      #ratio=$(echo "scale=2; $success/$sum" | bc)
      echo $dist $util $rep
      echo $success $sum $ratio >> ../"$dist""_""$pdist""_ratio"
      cd ..;
    done
    echo " " >> ./"$dist""_""$pdist""_ratio"
  done
  echo "===" >> ./"$dist""_""$pdist""_ratio"
done
done
date
