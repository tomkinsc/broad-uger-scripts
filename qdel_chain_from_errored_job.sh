#!/bin/bash

MY_PATH="`dirname \"$0\"`"
source $MY_PATH"/monitoring/use_uger.sh"

USAGE=$'\nUsage: qdel_chain_from_errored_job.sh target_job_id'
USAGE=$USAGE$'\n'
USAGE=$USAGE$'\n   This script is intended to be used to qdel (kill) UGER jobs that have errored, as well'
USAGE=$USAGE$'\n   as their dependent jobs, up to the point where a dependent job has preceeding jobs of its own.'
USAGE=$USAGE$'\n'

if [[ "$#" == "0" ]]; then
    echo "$USAGE"
    echo "  These are the jobs currently in an Eqw state:"
    qstat | grep "Eqw"
    exit 1
fi

JOBS=($(echo $(qstat | grep -Ev "(job\-ID|----)" | awk '{print $1}') | tr " " "\n"))

TO_KILL=() #("$1")
TARGET_JOB=$1

declare -A JM # job to successors
declare -A PM # job to predecessors

echo "Jobs:"
echo "${JOBS[@]}"
echo "Job count: ${#JOBS[@]}"

echo "Building job graph..."
idx=0
for id in ${JOBS[@]}; do
    JOB=$(echo $(qstat -r -j $(echo "${id}") | grep -E "(job_number|jid_predecessor_list\ \(req\))") | sed "s/jid_predecessor_list (req):/_/" | sed "s/job_number://" | cut -d_ -f1)
    PREDECESSORS=$(echo $(qstat -r -j $(echo "${id}") | grep -E "(job_number|jid_predecessor_list\ \(req\))") | sed "s/jid_predecessor_list (req):/_/" | sed "s/job_number://" | cut -d_ -f2)

    ((idx=$idx+1))

    DIGRAPH_PAIRS=()

    #echo "Job: $JOB"
    #echo "Predecessors: $PREDECESSORS"
    echo "$(bc -l <<< "scale=2; (($idx / ${#JOBS[@]}) * 100)")% complete"


    PREDECESSOR_ARRAY=$(echo $PREDECESSORS | tr "," "\n")
    #echo $PREDECESSOR_ARRAY

    for predecessor in ${PREDECESSOR_ARRAY[@]}; do
        if [[ ${predecessor} -ne ${id} ]];then
            PAIR="${predecessor}|->|${id},"
            DIGRAPH_PAIRS+=($PAIR)
            JM["${predecessor}"]="${JM["$predecessor"]},${id}"
        fi
    done

    PM["${id}"]="$PREDECESSORS"

    # This is helpful for printing the digraph
    #for pair in ${DIGRAPH_PAIRS[@]}; do
    #    echo "${pair}"
    #    echo ""
    #done

done

#for parentNode in "${!JM[@]}"; do
#    echo "$parentNode"
#    echo "  ${JM["$parentNode"]}"
#    echo ""
#done

function step_fw(){
    PREDS=($(  echo ${PM["$1"]} | tr "," "\n" ))

    #echo "current node: $1"
    #echo "PREDS: $PREDS count: ${#PREDS[@]}"
    #echo "Children: $( echo ${JM["$1"]} | tr "," "\n" )"

    if [[ ${#PREDS[@]} -eq 1 ]] || [[ "$1" -eq "$TARGET_JOB" ]]; then
        #echo "${JM["$1"]}"
        #echo "To examine next:"
        for child in $( echo "${JM["$1"]}" | tr "," "\n" ); do
            #echo "child: $child"
            if [[ "${child}" -ne "$1" ]]; then
                step_fw "$child"
            else
                echo ""
            fi
        done
        #echo ""
        TO_KILL+=("$1")
        #echo "To qdel: $1"
    fi
}

# Find root node
#NEXTKEY=$1
#while [[ ${JM[$NEXTKEY]+_} ]]; do
#    NEXTKEY=$(echo ${JM["$NEXTKEY"]} | cut -d, -f2 )
#done
#echo "Root node: $NEXTKEY"

step_fw $1

MY_PATH="`dirname \"$0\"`"

echo ""
echo "==========="
echo ""
echo "Target job: $1"
echo ""
echo "Successor jobs to kill for which the target is the only dependency:"
for ((idx=${#TO_KILL[@]}-1 ; idx >=0 ; idx-- )); do
    if [[ "${TO_KILL[idx]}" -eq "$TARGET_JOB" ]] ; then
        echo "${TO_KILL[idx]} ($( echo $($MY_PATH/monitoring/job_name.sh ${TO_KILL[idx]}) )) **TARGET**"
    else
        echo "${TO_KILL[idx]} ($( echo $($MY_PATH/monitoring/job_name.sh ${TO_KILL[idx]}) ))"
    fi
    echo ""
done

read -p "Kill these jobs [y/N]? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]] ; then
    for id in ${TO_KILL[@]}; do
        echo "qdel ${id}"
        qdel "${id}"
    done
else
    echo "Aborted"
fi
echo "Done!"
