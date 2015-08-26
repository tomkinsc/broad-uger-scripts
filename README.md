# broad-uger-scripts
Scripts related to using the Broad's UGER system

## setup_env_run_cmd.sh

**Usage**

This script runs the command specified, after including the dotkits specified via the `-d` option.

    Usage: setup_env_run_cmd.sh [-d ".dotkit1 .dotkit2"] myCommand [myArgs]
  
      Ex. setup_env_run_cmd.sh -d ".python-3.4.3" python -V

**Execution path**

    +----------------+ Dispatch job:                                                                  
    |   Login node   | qsub -q short                                                     
    | (pt, au, etc.) | setup_env_run_cmd.sh [-d ".mydotkit"]                             
    |                | myCommand [myArgs]                                                
    +--------+-------+                                                                   
             ++                                                                          
              |                                                                          
    +---------v------+ Within job, helper script gets called:                                                                  
    |  UGER Compute  | setup_env_run_cmd.sh -d ".mydotkit" myCommand myArgs              
    |      Node      |                                                                   
    +---------+------+                                                                   
              |                                                                          
      + - - - v - - - -                                                                  
          myCommand    | Command is run on compute node with dotkits.                                                             
      + - - - - - - - -                                                                                                                          
      
## setup_env_run_cmd_as_tasks.sh

**Usage**

This script runs the command specified, after including the dotkits specified via the `-d` option.
It is intended to be used with UGER task queues, where each task will process a filepath listed in `mySampleFiles.txt`.
Within the specified `myCommand`, it performs a find/replace on `SAMPLE_FILENAME`, inserting the task-specific
filepath listed in `mySampleFiles.txt`, such that task 1 inserts the first line in place of `SAMPLE_FILENAME`, task 2 the second line, and so on.

    Usage: setup_env_run_cmd_as_tasks.sh [-d ".dotkit1 .dotkit2"] ./mySampleFiles.txt myCommand [myArgs]

     In the command you specify as myCommand, the string "SAMPLE_FILENAME" is replaced with the filename
     given on line N of mySampleFiles.txt, where N is the number of the task.

     Ex. setup_env_run_cmd_as_tasks.sh -d ".python-3.4.3" ./mySampleFiles.txt "python -c "import platform; print('Python: %s' % platform.python_version()); print('SAMPLE_FILENAME')""

    Note: This is meant to be called with a UGER command supporting task queues

     Ex. qsub -cwd -q short -t 1-10 setup_env_run_cmd_as_tasks.sh -d ".python-3.4.3" ./mySampleFiles.txt echo SAMPLE_FILENAME

**Execution path**

    +----------------+ Dispatch job with multiple tasks:                                                                    
    |   Login node   | qsub -q short -t 1-3                                               
    | (pt, au, etc.) | setup_env_run_cmd.sh [-d ".mydotkit"] mySampleFiles.txt            
    |                | myCommand [myArgs]                                                 
    +--------+-------+                                                                    
             ++                                                                           
              |                                                                           
    +---------v------+ Within job, helper script gets called:                                                                   
    |  UGER Compute  | setup_env_run_cmd_as_tasks.sh [-d ".mydotkit"] mySampleFiles.txt   
    |      Node      | myCommand [myArgs]                                                 
    +----+-----+----++                                                                    
         |     |    |                                                                     
         |     |    |          The helper script creates multiple tasks within its job:                                                      
         |     | + -v- - - - - - -                                                        
         |     |   myCommandTask  | Command is run on compute node with dotkits and task-specific substitution
         |     | + - - - - - - - -                                                        
         |  + -v- - - - - - -                                                             
         |    myCommandTask  | Command is run on compute node with dotkits and task-specific substitution
         |  + - - - - - - - -                                                             
       + v - - - - - - -                                                                  
         myCommandTask  | Command is run on compute node with dotkits and task-specific substitution
       + - - - - - - - -                                                                                                                       
