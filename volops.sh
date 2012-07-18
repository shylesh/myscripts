#!/bin/bash -x

BRICK_DIR=/export/sdb
VOL_NAME=vol1
MNT_PNT=/mnt/
VOL2=vol2


gluster volume create $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b1
gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b2
gluster volume start $VOL_NAME
sleep 2
gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b3
gluster --mode=script volume stop $VOL_NAME
gluster volume add-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4
gluster volume start $VOL_NAME
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b1 `hostname`:$BRICK_DIR/$VOL_NAME-b2 
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 `hostname`:$BRICK_DIR/$VOL_NAME-b3 start
gluster volume add-brick $VOL_NAME stripe 2 `hostname`:$BRICK_DIR/str1
gluster volume add-brick $VOL_NAME stripe 2 `hostname`:$BRICK_DIR/str1 `hostname`:$BRICK_DIR/str2
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/str1 `hostname`:$BRICK_DIR/str2  
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b3 `hostname`:$BRICK_DIR/str1  
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b3 `hostname`:$BRICK_DIR/str1  
sleep 10
gluster --mode=script volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b3 `hostname`:$BRICK_DIR/str1  
gluster volume create stripe stripe 2 `hostname`:$BRICK_DIR/stripe1 `hostname`:$BRICK_DIR/stripe2
mount -t glusterfs `hostname`:/$VOL_NAME /mnt
cd /mnt
for i in {1..100}; do dd if=/dev/urandom of=$i count=1024 bs=1000; done
gluster volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 `hostname`:$BRICK_DIR/str2 
gluster volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 `hostname`:$BRICK_DIR/str2
gluster volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 `hostname`:$BRICK_DIR/str2  
gluster volume remove-brick $VOL_NAME `hostname`:$BRICK_DIR/$VOL_NAME-b4 `hostname`:$BRICK_DIR/str2  
gluster volume create $VOL2 `hostname`:$BRICK_DIR/dist-1 `hostname`:$BRICK_DIR/dist-2
gluster volume start $VOL2
cd ..
umount /mnt
mount -t glusterfs `hostname`:$VOL2 /mnt
gluster volume add-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3
cd /mnt
for i in {1..1000}; do dd if=/dev/urandom of=$i count=1024 bs=1000; done
gluster volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3  
gluster volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3  
sleep 25
gluster volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3  
gluster volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3  
gluster volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3 
gluster volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3  
sleep 10
gluster --mode=script volume remove-brick $VOL2 `hostname`:$BRICK_DIR/dist-b3 commit
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/dist-2 `hostname`:$BRICK_DIR/replace start
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/dist-2 `hostname`:$BRICK_DIR/replace status
sleep 15
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/dist-2 `hostname`:$BRICK_DIR/replace commit
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 start
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 pause
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 start
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 pause
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 status
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 start
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 abort
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 start
gluster volume replace-brick $VOL2 `hostname`:$BRICK_DIR/replace `hostname`:$BRICK_DIR/replace1 commit

