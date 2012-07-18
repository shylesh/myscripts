#!/bin/bash

VER=$1
service glusterd stop

./cleanup.sh
if [ $* -ne 2 ]; then
	echo "usage: ./srcintall VERSION"
	exit 1
fi

wget http://bits.gluster.com/pub/gluster/glusterfs/src/glusterfs-$VER.tar.gz

tar xvfz glusterfs-$VER.tar.gz
cd glusterfs-$VER
./autogen.sh
./configure CFLAGS="-g -ggdb -O0"
make && make install
ldconfig

