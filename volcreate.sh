#!/bin/bash

if [ $# -ne 5 ]; then
	echo "usage: ./volcreate volname nbricks scount rcount brickdir"
	exit 1
fi

 
volname=$1
nbricks=$2
scount=$3
rcount=$4
brickdir=$5
i=1

cmd_prefix="gluster volume"
brick_list=" "

echo "$volname,$nbricks,$scount,$rcount,$brickdir"

if [ $nbricks -eq 0 ]; then
	echo "brick count can't be zero"
	exit 1;
fi

#check if brick dir exists
if [ ! -d $brickdir ]; then
	echo "brick directory doesn't exists"
	exit 1
fi


while [ $i -le $nbricks ] 
do
	brick_list="$brick_list	`hostname`:/$brickdir/$volname$i "
	i=`expr $i + 1`
done

echo $brick_list

if [ "$scount" -eq "0" ] && [ "$rcount" -eq "0" ]; then
		#this volume is distribute
	$cmd_prefix create $volname $brick_list 	
	exit 0
fi


#find out what type of volume to be created
if [ "$rcount" -eq 0 ]; then
	#volume is either plain stripe or dist-stripe
	$cmd_prefix create $volname stripe $scount $brick_list
	

elif [ "$scount" -eq 0 ] ; then
	#this is plain replica or distributed-replicate
	$cmd_prefix create $volname replica $rcount $brick_list

else
	#this is stripe-replicate or distributed-stripe-replicate
	$cmd_prefix create $volname stripe $scount replica $rcount $brick_list

fi



