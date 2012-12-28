#!/bin/bash
#
# Author: Shylesh kumar <shmohan@redhat.com>
# Date:Mon 10 Dec 2012 01:05:47 PM IST
# Script name: qeCoreAlert.sh
# Purpose: This script does the settings required
#          for generating the core alert.
#          i.e. mailx settings and core_pattern settings
#

# mail settings
MAILX=/etc/mail.rc

grep corealert $MAILX > /dev/null 2>&1

if [ $? -eq 1 ]; then
        echo "#settings for corealert" >> $MAILX
        echo "set smtp=smtp.redhat.com:587" >> $MAILX
        echo -e "set from=\"crash-reports@redhat.com (crash alert)\"" >> $MAILX
fi


# core pattern settings
# This assumes that binary will be placed in
# /usr/local/bin
echo "|/usr/local/bin/qeCoreAlert PROGRAM=%e HOST=%h sig=%s PID=%p\
UID=%u GID=%g" > /proc/sys/kernel/core_pattern

