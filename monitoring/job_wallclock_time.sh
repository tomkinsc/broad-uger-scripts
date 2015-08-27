#!/bin/bash

USAGE=$'\nUsage: job_wallclock_time.sh job_id'
USAGE=$USAGE$'\n'
if [[ "$#" == "0" ]]; then
    echo "$USAGE"
    exit 1
fi

MY_PATH="`dirname \"$0\"`"

source $MY_PATH"/use_uger.sh"

qstat -j $1 | grep usage | cut -f1 -d, | cut -d= -f2
