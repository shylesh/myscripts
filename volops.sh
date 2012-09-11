#!/bin/bash 


exit_if_error() 
{
	if [ $? -ne 0 ]; then
		echo "Failed"
		exit 1
	fi
}
	
clean_and_exit() {
        cd /
        umount  $MNT_PNT
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

BRICK_DIR=/home/bricks
VOL_NAME=vol`echo $RANDOM`
MNT_PNT=/mnt/
VOL2=vol`echo $RANDOM`


umount /mnt


if [ ! -d $BRICK_DIR ];then
	echo -e "brick directory does not exists"
	exit 1
fi

gluster volume create $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b1
exit_if_error

gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b2
exit_if_error

gluster volume start $VOL_NAME
exit_if_error

sleep 8
gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b3
exit_if_error

gluster --mode=script volume stop $VOL_NAME
exit_if_error

gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4
exit_if_error

gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b5
exit_if_error

gluster volume start $VOL_NAME
exit_if_error

gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b1 
exit_if_error



sleep 10
mount -t glusterfs `hostname`:/$VOL_NAME $MNT_PNT 
exit_if_error
cd /mnt

for i in {1..100}; do dd if=/dev/urandom of=$i count=1024 bs=500; done
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 start
exit_if_error

gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 stop 
exit_if_error

sleep 8
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 start
exit_if_error

time_out=300
val=1
while [ $time_out > 0 -a $val -ne 0 ]
do

	gluster volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 status | grep 'completed'
	val=$?
	(( time_out-- ))
done

if [ $time_out -eq 0 ]; then
	echo "remove-brick failed"
	exit 1
fi

sleep 10


gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 commit 
exit_if_error


gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b5 force 
exit_if_error
clean_and_exit $VOL_NAME # End of remove-brick ops


# Replace-brick ops
gluster volume create $VOL2 `hostname`:$BRICK_DIR/$VOL2-b1 `hostname`:$BRICK_DIR/$VOL2-b2
exit_if_error


gluster volume start $VOL2
exit_if_error

mount -t glusterfs `hostname`:$VOL2 $MNT_PNT 
exit_if_error

gluster volume add-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-b3
exit_if_error

cd $MNT_PNT 
for i in {1..100}; do dd if=/dev/urandom of=$i count=1024 bs=1000; done
sleep 10
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-b2 `hostname`:$BRICK_DIR/$VOL2-replace start
exit_if_error

time_out=300
val=1
while [ $time_out > 0 -a $val -ne 0 ]
do
	gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-b2 \
			`hostname`:$BRICK_DIR/$VOL2-replace status  | grep 'complete'
	val=$?
	(( time_out-- ))
	
done
if [ $time_out -eq 0 ]; then
	echo "replace-brick failed"
	exit 1
fi

gluster --mode=script volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-b2 `hostname`:$BRICK_DIR/$VOL2-replace commit
exit_if_error

gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-replace `hostname`:$BRICK_DIR/$VOL2-replace1 start
exit_if_error

gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-replace `hostname`:$BRICK_DIR/$VOL2-replace1 pause
exit_if_error

gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-replace `hostname`:$BRICK_DIR/$VOL2-replace1 start
exit_if_error

gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-replace `hostname`:$BRICK_DIR/$VOL2-replace1 abort
exit_if_error

gluster --mode=script volume replace-brick $VOL2 `hostname`:$BRICK_DIR/$VOL2-replace \
				`hostname`:$BRICK_DIR/$VOL2-replace2 commit force

exit_if_error
echo -e "All volops pass"
VOL_NAME=$VOL2
clean_and_exit $VOL_NAME

