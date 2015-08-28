#!/bin/bash

USAGE=$'\nUsage: job_usage_all.sh job_id'
USAGE=$USAGE$'\n'
if [[ "$#" > 0 ]]; then
    echo "$USAGE"
    exit 1
fi

MY_PATH="`dirname \"$0\"`"

source $MY_PATH"/use_uger.sh"

for id in $($MY_PATH/list_running_jobs.sh); do
    echo ""
	$MY_PATH/job_usage.sh ${id}
done
