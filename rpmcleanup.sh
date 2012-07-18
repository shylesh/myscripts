#!/bin/bash

rpm -qa | grep glusterfs
ret=$?

if [ $ret -eq 0 ]; then
        echo "RPM is present need to be removed"
        rpm -e `rpm -qa | grep glusterfs`
        ret=$?
        if [ $ret -eq 0 ]; then
                echo "RPM removed successfully"
        else   
                echo "Failed to remove RPM"
                exit 1
        fi
else   
	echo "Glusterfs rpm is not present"
fi
