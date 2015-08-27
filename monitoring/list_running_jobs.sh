#!/bin/bash

USAGE=$'\nUsage: list_running_jobs.sh'
USAGE=$USAGE$'\n'
if [[ "$#" > 0 ]]; then
    echo "$USAGE"
    exit 1
fi

MY_PATH="`dirname \"$0\"`"

source $MY_PATH"/use_uger.sh"

qstat | grep "  r  " | grep -v QRLOGIN | awk '{print $1}'
