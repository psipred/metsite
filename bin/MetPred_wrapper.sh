#!/bin/sh
#
# MetPred_wrapper.sh /opt/Code/metsite CU 1 1IAR.pdb.DATA 1IAR_MetPred.pdb A
#
path=$1
metal=$2
fpr_choice=$3
seedsitedata=$4
pdb=$5
chain=$6
output=`java -cp $path/src/org/ucl/conf/:$path/src returnNetCut $metal $fpr_choice`
value=${output##*' '}
lc=${metal,,}
echo `$path/bin/MetPred $seedsitedata $lc $value $pdb.MetPred $chain $path/data/`
