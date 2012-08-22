#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Usage: ./random.sh \$filename \$blocksize \$count"
	exit 1
fi

fname=$1
bs=$2
count=$3

dd if=/dev/urandom of=$fname bs=$bs count=$count

