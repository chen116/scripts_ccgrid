#/bin/bash

RTSPIN="/root/liblitmus/rtspin"
BASE_TASK="/root/liblitmus/mytools/myapp"
RELEASETS="/root/liblitmus/release_ts"
ST_TRACE="/root/ft_tools/st_trace"
RTLAUNCH="/root/liblitmus/rt_launch"
SPIN_PIDS=""
#RAW_DATA="/root/task_sets_raw/"
RAW_DATA="/root/task_sets_raw/"
# NEW_DATA="/root/experiment-scripts/task_sets_icloud_granular"
NEW_DATA="/root/experiment-scripts/task_sets_icloud_bimo_moderate"
#NEW_DATA="/root/experiment-scripts/task_sets_VaryUtil/"
#NEW_DATA="/root/experiment-scripts/task_sets_VaryUtil/"
#PDist="uni-long"
#PDist="uni-moderate"
#PDist="uni-short"
PROG=$1
Dist=$2
Duration=$3
PDist=$4
declare -a NEW_SPIN_PIDS

#Util=`echo $Dist | cut -d'_' -f 2`
#Rep=`echo $Dist | cut -d'_' -f 3`
#SchedNames="GSN-EDF
#C-EDF"
SchedNames="GSN-EDF"

for sched in $SchedNames
do
  #for util in 8.5
  #for util in 3.0 4.0 5.0 6.0 7.0 8.0 8.2
#  for util in 2.2 2.6 3.2 3.6 4.2 4.6 5.2 5.6 6.2 6.6 7 7.2
#  for util in 3.2 3.6 4.2 4.6 5.2 5.6 6.2 6.6 7.2 7.6 8
#  for util in 3.2 3.4 3.6 3.8 4.2 4.4 4.6 4.8 5.2 5.4 5.6 5.8 6.2 6.4 6.6 6.8 7.2 7.4 7.6 7.8 8 8.2 8.4
#  for util in 9.0 10.0 11.0 12.0
#   for util in 8.2 8.4 8.6 8.8
#  for util in 0.2 0.4 0.6 0.8 1.2 1.4 1.6 1.8 2.2 2.4 2.6 2.8 3.2 3.4 3.6 3.8 4.2 4.4 4.6 4.8 5.2 5.4 5.6 5.8 6.2 6.4 6.6 6.8 7.2 7.4 7.6 7.8 8
 #for util in 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0 5.2 5.4 5.6 5.8 6.0 6.2 6.4 6.6 6.8 7.0 7.2 7.4 7.6 7.8 8.0 8.2 8.4
  for util in 1.0 2.0 3.0 4.0
  do
    #for rep in 0
    for rep in 0 1 2
    # for rep in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
    do

echo "Starting st_trace"
${ST_TRACE} -s mk &
ST_TRACE_PID="$!"
echo "st_trace pid: ${ST_TRACE_PID}"
sleep 1

echo "Switching to $sched plugin"
echo "$sched" > /proc/litmus/active_plugin
sleep 1

#read wcet and period from the dist file
filename="$NEW_DATA""/""$Dist""_""$PDist""_""$util""_""$rep"
data=$(cat $filename)
num_tasks=$(cat $filename | wc -l)
#echo $data
#echo $num_tasks
c=0
n=0
for task in ${data[@]};
do
  let "rem= $c % 2"
  if [ "$rem" -eq 0 ]
  then
    #wcet[$n]=$task
    wcet[$n]=$(echo "scale=3; $task * 0.001" | bc)
  else
    #period[$n]=$task
    period[$n]=$(echo "scale=3; $task * 0.001" | bc)
    n=`expr $n + 1`
  fi
  c=`expr $c + 1`
done

echo "Setting up rtspin processes"
for nt in `seq 1 $num_tasks`;
do
  #$PROG ${wcet[`expr $nt - 1`]} ${period[`expr $nt - 1`]} $Duration -w &
  $BASE_TASK ${wcet[`expr $nt - 1`]} ${period[`expr $nt - 1`]} $Duration &
  #$RTSPIN ${wcet[`expr $nt - 1`]} ${period[`expr $nt - 1`]} $Duration &
  #numactl --physcpubind=8-15 --membind=0 --cpunodebind=0 $PROG ${wcet[`expr $nt - 1`]} ${period[`expr $nt - 1`]} $Duration -w &
  #numactl --physcpubind=8-15 $PROG ${wcet[`expr $nt - 1`]} ${period[`expr $nt - 1`]} $Duration -w &
  SPIN_PIDS="$SPIN_PIDS $!"
  NEW_SPIN_PIDS[`expr $nt - 1`]="$!"
done
sleep 1

#echo "catting log"
#cat /dev/litmus/log > log.txt &
#LOG_PID="$!"
#sleep 1
echo "Doing release..."
$RELEASETS

echo "Waiting for rtspin processes..."
# wait ${SPIN_PIDS}

for i in "${NEW_SPIN_PIDS[@]}"
do
  wait $i
done
unset NEW_SPIN_PIDS

echo "Done wait, sleeping"
sleep 1
echo "Killing log"
kill ${LOG_PID}
sleep 1
echo "Sending SIGUSR1 to st_trace"
kill -USR1 ${ST_TRACE_PID}
echo "Waiting for st_trace..."
wait ${ST_TRACE_PID}
sleep 1

mkdir -p run-data-fig2/"$PROG"/
mkdir run-data-fig2/"$PROG"/"$Dist""_""$PDist""_""$util""_""$rep"/
mv /dev/shm/*.bin run-data-fig2/"$PROG"/"$Dist""_""$PDist""_""$util""_""$rep"/
#mv log.txt run-data/"$sched"_$rep/
sleep 1
echo "Done! Collect your logs."

    done
  done
done
echo "DONE!"

