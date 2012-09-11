#!/bin/bash 

exit_if_error() {
	
 	if [ $? -ne 0 ]; then
		clean_and_exit	
		
	fi
}

exit_if_no_error() {
	if [ $? -eq 0 ];then
		echo "-ve case failed"
		exit 1
	fi
}

clean_and_exit() {
	cd /
	umount -fl $MNT_PT
	gluster --mode=script volume stop $VOL_NAME
	if [ $? -ne 0 ]; then
		echo "stopping volume failed"
		exit 1
	fi
	gluster --mode=script volume delete $VOL_NAME
	if [ $? -ne 0 ]; then
		echo "Deleteing volume failed"
		exit 1
	fi
	
}
	 


BRICK_DIR=/home/bricks/
VOL_NAME=test15
HOSTNAME=`hostname`
MNT_PT=/mnt

if [ ! -d "$BRICK_DIR" ]; then
	echo -e "Brick directory does not exists\n"
	exit 1
fi

gluster volume create $VOL_NAME $HOSTNAME:$BRICK_DIR/b1-$VOL_NAME
exit_if_error

gluster volume start $VOL_NAME
exit_if_error
sleep 4 

val=`mount -t glusterfs $HOSTNAME:/$VOL_NAME $MNT_PT|  grep  'already' | wc -l`
if [ $val -ne 0 ]; then
	echo "mount failed\n"
	exit 1 
fi
sleep 5

cd /mnt
for i in {1..100} ; do dd if=/dev/urandom of=$i bs=1024 count=1000; done

gluster volume add-brick $VOL_NAME $HOSTNAME:$BRICK_DIR/b2-$VOL_NAME
exit_if_error

gluster volume rebalance $VOL_NAME fix-layout start
exit_if_error
gluster volume rebalance $VOL_NAME status 
exit_if_error
gluster volume rebalance $VOL_NAME stop
exit_if_error
sleep 10 
gluster volume rebalance $VOL_NAME start
exit_if_error
gluster volume rebalance $VOL_NAME status
exit_if_error
gluster volume rebalance $VOL_NAME stop
sleep 10 
exit_if_error
gluster volume rebalance $VOL_NAME start force
exit_if_error
gluster volume rebalance $VOL_NAME status
exit_if_error
gluster volume rebalance $VOL_NAME stop
exit_if_error

du -h .
dd if=/dev/urandom of=here bs=1024 count=500000
for i in {101..200}; do mkdir $i; cd $i; touch $i;done

gluster volume add-brick $VOL_NAME $HOSTNAME:$BRICK_DIR/b4-$VOL_NAME $HOSTNAME:$BRICK_DIR/b5-$VOL_NAME
exit_if_error
gluster volume rebalance $VOL_NAME fix-layout start 
exit_if_error
gluster volume rebalance $VOL_NAME status
exit_if_error
gluster volume rebalance $VOL_NAME stop
sleep 10
gluster volume rebalance $VOL_NAME start
exit_if_error

gluster volume rebalance $VOL_NAME status
exit_if_error
gluster volume rebalance $VOL_NAME stop
exit_if_error
sleep 10
gluster volume rebalance $VOL_NAME start force
exit_if_error

gluster volume rebalance $VOL_NAME status
exit_if_error
gluster volume rebalance $VOL_NAME stop
exit_if_error
sleep 10
echo "REBALANCE:All tests are pass"
clean_and_exit
