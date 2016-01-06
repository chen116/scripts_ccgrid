#!/bin/bash
date
WORK_DIR="/root/experiment-scripts/run-data-fig2/"
PROG=$1

#declare -a Dist=("bimo-medium")
declare -a Dist=("uni-heavy" "uni-medium" "uni-light" "bimo-medium")
#declare -a Dist=("uni-light")
declare -a PDist=("uni-moderate")
#declare -a Dist=("uni-light" "uni-medium" "uni-heavy")
#declare -a Util=("1" "2" "3" "4" "5" "6" "7" "8")
#declare -a Rep=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")
#declare -a Dist=("single" "double")
#declare -a Dist=("single")
#declare -a PDist=("uni-long")
#declare -a PDist=("uni-moderate")
#declare -a PDist=("uni-longRTXen")
#declare -a Util=("125" "250" "375" "500" "625" "750" "875" "1000")
#declare -a Util=("0.2" "0.4" "0.6" "0.8" "1" "1.2" "1.4" "1.6" "1.8" "2" "2.2" "2.4" "2.6" "2.8" "3" "3.2" "3.4" "3.6" "3.8" "4" "4.2" "4.4" "4.6" "4.8" "5" "5.2" "5.4" "5.6" "5.8" "6" "6.2" "6.4" "6.6" "6.8" "7" "7.2" "7.4" "7.6" "7.8" "8" "8.2" "8.4")
#declare -a Util=("0.2" "0.4" "0.6" "0.8" "1.2" "1.4" "1.6" "1.8" "2.2" "2.4" "2.6" "2.8" "3.2" "3.4" "3.6" "3.8" "4.2" "4.4" "4.6" "4.8" "5.2" "5.4" "5.6" "5.8" "6.2" "6.4" "6.6" "6.8" "7.2" "7.4" "7.6" "7.8" "8")
#declare -a Util=("3.2" "3.6" "4.2" "4.6" "5.2" "5.6" "6.2" "6.6" "7.2" "7.6" "8")
#declare -a Util=("9.0" "10.0" "11.0" "12.0")
#declare -a Util=("8.2" "8.4" "8.6" "8.8")
#declare -a Util=("3.2" "3.4" "3.6" "3.8" "4.2" "4.4" "4.6" "4.8" "5.2" "5.4" "5.6" "5.8" "6.2" "6.4" "6.6" "6.8" "7.2" "7.4" "7.6" "7.8" "8" "8.2" "8.4")
#declare -a Util=("2.2" "2.6" "3.2" "3.6" "4.2" "4.6" "5.2" "5.6" "6.2" "6.6" "7" "7.2")
#declare -a Util=("1" "2" "3" "4" "5" "6" "7" "8")
declare -a Util=("1" "2" "3" "4")
#declare -a Util=("8.5" )
declare -a Rep=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24")
#declare -a Rep=("0" "1" "2")
cd "$WORK_DIR""/""$PROG"; date
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
      pids=(`grep -r PID all | grep "myapp" | awk '{print $4}' | grep -Eo "[[:digit:]]*"`)
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
