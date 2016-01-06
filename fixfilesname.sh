SUFF=.0
suff=_
X=".0"
for i in $(ls ./task_sets_icloud_bimo_moderate/*$SUFF*)
do
  #sed -i 's/\.out//g' i
  #echo ${i%.0*}
  mv $i ${i/.0_/_}
  #mv -f $i ${i#$X}
  #  Leave unchanged everything *except* the shortest pattern match
  #+ starting from the right-hand-side of the variable $i . . .
done ### This could be condensed into a "one-liner" if desired.


