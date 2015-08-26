#! /bin/bash

USAGE=$'\nUsage: setup_env_run_cmd.sh [-d ".dotkit1 .dotkit2"] "myCommand [myArgs]"'
USAGE=$USAGE$'\n'
USAGE=$USAGE$'\n    Ex. setup_env_run_cmd.sh -d ".python-3.4.3" python -V'
USAGE=$USAGE$'\n'

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

eval $@ && exit 0 || exit 100

