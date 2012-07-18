#!/bin/bash

pgrep gluster | xargs kill -9
cd /etc/glusterd 
rm -rf *


