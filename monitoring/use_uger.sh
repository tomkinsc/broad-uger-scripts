#!/bin/bash

# inexpensive way to check if the UGER dotkit is in use
if ! hash qstat 2> /dev/null ; then
    source "/broad/software/scripts/useuse"
    reuse -q UGER &> /dev/null
fi



