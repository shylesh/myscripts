#!/bin/bash

BRICK_DIR=/export/sda

gluster volume create test `hostname`:$BRICK_DIR/b1-test
gluster volume start test
sleep 4 
mount -t glusterfs `hostname`:/test /mnt
sleep 5
cd /mnt
for i in {1..100} ; do dd if=/dev/urandom of=$i bs=1024 count=1000; done
gluster volume add-brick test `hostname`:$BRICK_DIR/b2-test
gluster volume rebalance test fix-layout start
gluster volume rebalance test fix-layout status
gluster volume rebalance test migrate-data start
gluster volume rebalance test migrate-data status
gluster volume rebalance test migrate-data start force
gluster volume rebalance test migrate-data status
gluster volume rebalance test migrate-data stop
du -h .
dd if=/dev/urandom of=here bs=1024 count=500000
for i in {101..200}; do mkdir $i; cd $i; touch $i;done

gluster volume add-brick test `hostname`:$BRICK_DIR/b4-test `hostname`:$BRICK_DIR/b5-test
gluster volume rebalance test fix-layout start 
gluster volume rebalance test fix-layout status
gluster volume rebalance test migrate-data start

gluster volume rebalance test migrate-data status
gluster volume rebalance test migrate-data stop

