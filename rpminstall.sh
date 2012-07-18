#!/bin/bash

# Wget the RPMs and install 
# 
RpmGetInstall()
{

	echo "Installing RPMs"
	#get the rpm from repo
	wget http://bits.gluster.com/pub/gluster/glusterfs/$VERSION/x86_64/glusterfs-core-$VERSION-1.x86_64.rpm
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "wget on core rpm succeeded"
	else
		echo "wget on core rpm failed"
		exit 1
	fi

	wget http://bits.gluster.com/pub/gluster/glusterfs/$VERSION/x86_64/glusterfs-fuse-$VERSION-1.x86_64.rpm
	ret=$?
        if [ $ret -eq 0 ]; then
                echo "wget on fuse rpm succeeded"
        else   
                echo "wget on fuse rpm failed"
                exit 1
	fi
	#install the RPMS
	rpm -ivh glusterfs-*-$VERSION-1.x86_64.rpm --nodeps
	ret=$?
	if [ $ret -eq 0 ]; then
                echo "RPM install succeede"
        else
                echo "RPM install failed"
                exit 1
	fi
}

# 
#Main starts here
#

if [ $# -ne 1 ]; then 
	echo "Usage: ./rpminstall \$VERSION"
	exit 1
fi

VERSION=$1
rpm -qa | grep glusterfs
ret=$?

if [ $ret -eq 0 ]; then
	echo "RPM is present need to be removed"
	rpm -e `rpm -qa | grep glusterfs`
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "RPM removed successfully"
		RpmGetInstall
	else
		echo "Failed to remove RPM"
		exit 1
	fi
else
	RpmGetInstall
fi
	
	





