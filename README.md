# Synology Hyper Backup Task Monitor and Executor

This script allows you to remotely manage and monitor Hyper Backup tasks on a Synology NAS via SSH. The script sequentially executes specified backup tasks, monitors their progress by checking for the `img_backup` process, and only starts the next task once the current task is complete.

## Features

- Connects to a remote Synology NAS using SSH.
- Starts specified Hyper Backup tasks based on their task IDs.
- Periodically checks if the backup process (`img_backup`) is still running.
- Waits for a backup task to finish before starting the next one.
- Handles SSH and general errors and returns appropriate exit codes.

## Requirements

- **Synology NAS**: The script is designed to run Hyper Backup tasks on a Synology NAS.
- **SSH Access**: You need SSH access to your Synology NAS (passwordless login is recommended).
- **Task IDs**: The script requires the task IDs of the backup tasks you want to execute.

## Script Overview

### How It Works

1. **Check Backup Process**: The script first checks if the `img_backup` process is already running on the remote Synology NAS. It uses the `ps` command to do this.
   
2. **Start Backup Task**: If no backup is currently running, the script starts a backup task using the `dsmbackup` command with the provided task ID.

3. **Monitor Progress**: The script monitors the progress of the running backup by checking for the `img_backup` process every 60 seconds.

4. **Complete Task**: Once the backup process finishes, the script proceeds to the next task in the list.

5. **Error Handling**: The script returns specific exit codes based on the type of error encountered (e.g., SSH failure, general error).

### Exit Codes

- **0**: All backup tasks completed successfully.
- **1**: General error occurred.
- **22**: SSH connection error occurred.

### Make the Script Executable

```bash
chmod +x synology_backup.sh
```

### Run the Script

```bash
./synology_backup.sh
```

### SSH Key Setup (Recommended)

For smooth operation, you should set up passwordless SSH access from the machine running the script to the Synology NAS. This can be done by copying your public SSH key to the NAS:

```bash
ssh-copy-id your_username@your_synology_host
```

## How to Find Backup Task IDs

You can retrieve the task IDs for your Hyper Backup tasks by using the following command on your Synology NAS:

```bash
synoschedtask --get
```

This will return a list of scheduled tasks. The output will include task numbers (IDs) along with descriptions. The task ID can be found in the `taskId` field. Here’s an example of the output:

```bash
             User: [root]
               ID: [2]
             Name: [USB HDD]
            State: [disabled]
            Owner: [root]
             Type: [once]
       Start date: [2024/9/4]
         Run time: [3]:[0]
          Command: [/var/packages/HyperBackup/target/bin/dsmbackup --backup 1]
           Status: [Not Available]

             User: [root]
               ID: [7]
             Name: [Samsung SSD]
            State: [enabled]
            Owner: [root]
             Type: [daily]
       Start date: [0/0/0]
         Run time: [1]:[0]
          Command: [/var/packages/HyperBackup/target/bin/dsmbackup --backup 8]
           Status: [Not Available]

             User: [root]
               ID: [5]
             Name: [Sindbad NAS]
            State: [disabled]
            Owner: [root]
             Type: [once]
       Start date: [2024/9/11]
         Run time: [0]:[10]
          Command: [/var/packages/HyperBackup/target/bin/dsmbackup --backup 5]
           Status: [Not Available]
```

In this example, the task IDs are `1`, `8` and `5`. It is the number at the end of the `Command` line not the `ID` line.  These IDs can be used in the `BACKUP_TASKS` list in the script.

## Logging

The script outputs verbose logs to the console:

- **Information** logs, such as task initiation and completion, are printed to standard output.
- **Error** messages, like SSH connection failures, are printed to standard error.

## Extending the script

You can extend the script to carry out other operations on the Synology NAS.  For example you might want to stop AFP or SMB to prevent changes to files whilst the backup is running.

## License

This script is provided under the MIT License.
