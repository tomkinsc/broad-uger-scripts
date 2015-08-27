#!/bin/bash

USAGE=$'\nUsage: job_name.sh job_id'
USAGE=$USAGE$'\n'
if [[ "$#" == "0" ]]; then
    echo "$USAGE"
    exit 1
fi

MY_PATH="`dirname \"$0\"`"

source $MY_PATH"/use_uger.sh"

qstat -j $1 | grep job_name | cut -d:  -f2 | xargs
