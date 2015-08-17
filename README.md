# broad-uger-scripts
Scripts related to using the Broad's UGER system

####./setup_env_run_cmd.sh

This script runs the command specified, after including the dotkits specified via the `-d` option.

    Usage: setup_env_run_cmd.sh [-d ".dotkit1 .dotkit2"] myCommand [myArgs]
  
      Ex. /setup_env_run_cmd.sh -d ".python-3.4.3" python -V
      
####./setup_env_run_cmd_as_tasks.sh

This script runs the command specified, after including the dotkits specified via the `-d` option.
It is intended to be used with UGER task queues, where each task will process a filepath listed in `mySampleFiles`.
Within the specified `myCommand`, it performs a find/replace on `SAMPLE_FILENAME`, inserting the task-specific
filepath listed in `mySampleFiles`, such that task 1 inserts the first line in place of `SAMPLE_FILENAME`, task 2 the second line, and so on.

    Usage: ./setup_env_run_cmd_as_tasks.sh [-d ".dotkit1 .dotkit2"] mySampleFiles.txt myCommand [myArgs]

     In the command you specify as myCommand, the string "SAMPLE_FILENAME" is replaced with the filename
     given on line N of mySampleFiles.txt, where N is the number of the task.

     Ex. ./setup_env_run_cmd_as_tasks.sh -d ".python-3.4.3" ./mySampleFiles.txt "python -c "import platform; print('Python: %s' % platform.python_version()); print('SAMPLE_FILENAME')""

    Note: This is meant to be called with a UGER command supporting task queues

     Ex. qsub -q long -t 1-10 ./setup_env_run_cmd_as_tasks.sh -d ".python-3.4.3" ./mySampleFiles.txt echo SAMPLE_FILENAME
