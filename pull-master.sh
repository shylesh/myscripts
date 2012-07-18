#!/bin/bash -x

GLUSTER_DIR=$1
sh /root/cleanup.sh
cd $GLUSTER_DIR

git pull
make clean && make uninstall
make && make install


