#! /bin/bash

USAGE=$'\nUsage: ./setup_env_run_cmd_as_tasks.sh [-d ".dotkit1 .dotkit2"] mySampleFiles.txt myCommand [myArgs]'
USAGE=$USAGE$'\n'
USAGE=$USAGE$'\n   In the command you specify as myCommand, the string \"SAMPLE_FILENAME\" is replaced with the filename'
USAGE=$USAGE$'\n   given on line N of mySampleFiles.txt, where N is the number of the task.'
USAGE=$USAGE$'\n'
USAGE=$USAGE$'\n   Ex. ./setup_env_run_cmd_as_tasks.sh -d ".python-3.4.3" ./mySampleFiles.txt "python -c \"import platform; print(\'Python: %s\' % platform.python_version()); print(\'SAMPLE_FILENAME\')\"" '
USAGE=$USAGE$'\n'
USAGE=$USAGE$'\n   Note: This is meant to be called with a UGER command supporting task queues'
USAGE=$USAGE$'\n   '
USAGE=$USAGE$'\n   Ex. qsub -q long -t 1-10 ./setup_env_run_cmd_as_tasks.sh -d ".python-3.4.3" ./mySampleFiles.txt echo SAMPLE_FILENAME'

if [[ "$#" == "0" ]]; then
    echo "$USAGE"
    exit 1
fi
 
while getopts ":d:" opt; do
  case $opt in
    d)
        source /broad/software/scripts/useuse
        reuse -q $OPTARG #>&2 #2>/dev/null 
        shift
        shift
        break
    ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
    ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
    ;;
  esac
done

MYFILE=$1

shift # shift args to remove sample names file from command executed

if [[ -z "$SGE_TASK_ID" ]]; then
    echo "SGE_TASK_ID not defined. Did you specify a task range with '-t 1-N'?"
else
    SAMPLE=$(awk "NR==$SGE_TASK_ID" "$MYFILE")    
    for var in $@
    do
        VAR_REPLACED="${var/SAMPLE_FILENAME/$SAMPLE}"
        COMMAND_TO_RUN="$COMMAND_TO_RUN $VAR_REPLACED"
    done
    eval $COMMAND_TO_RUN
fi
