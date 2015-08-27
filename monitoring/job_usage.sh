#!/bin/bash

USAGE=$'\nUsage: job_usage.sh job_id'
USAGE=$USAGE$'\n'
if [[ "$#" == "0" ]]; then
    echo "$USAGE"
    exit 1
fi

MY_PATH="`dirname \"$0\"`"

source $MY_PATH"/use_uger.sh"

echo "Job #:                "$(echo $1)
echo "Job name:             "$($MY_PATH/job_name.sh $1)
echo "CPU Time:             "$($MY_PATH/job_cpu_time.sh $1)
echo "Wallclock time:       "$($MY_PATH/job_wallclock_time.sh $1)
echo "Max mem usage so far: "$($MY_PATH/job_max_memory_usage.sh $1)
echo "Current memory usage: "$($MY_PATH/job_memory_usage.sh $1)
