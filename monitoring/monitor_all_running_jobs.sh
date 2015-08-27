#!/bin/bash

USAGE=$'\nUsage: monitor_all_jobs.sh'
USAGE=$USAGE$'\n'
if [[ "$#" > 0 ]]; then
    echo "$USAGE"
    exit 1
fi

MY_PATH="`dirname \"$0\"`"

source $MY_PATH"/use_uger.sh"

watch -n 10 $MY_PATH/job_usage_all.sh
