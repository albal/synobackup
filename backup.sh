#!/bin/bash

# Remote Synology NAS credentials
REMOTE_USER="al"
REMOTE_HOST="192.168.0.222"

# List of backup task IDs
BACKUP_TASKS=(5 8 1)  # Replace with actual task IDs

# SSH timeout settings
SSH_TIMEOUT=30

# Function to check if the img_backup process is running using ps
is_backup_running() {
    ssh -o ConnectTimeout=$SSH_TIMEOUT $REMOTE_USER@$REMOTE_HOST "ps aux | grep '[i]mg_backup'" > /dev/null 2>&1
    return $?
}

# Function to start a backup task
start_backup_task() {
    local task_id=$1
    ssh -o ConnectTimeout=$SSH_TIMEOUT $REMOTE_USER@$REMOTE_HOST "/var/packages/HyperBackup/target/bin/dsmbackup --backup $task_id" > /dev/null 2>&1
    return $?
}

# Error handling function
handle_error() {
    local error_code=$1
    case $error_code in
        22)
            echo "SSH connection error occurred" >&2
            ;;
        1)
            echo "General error occurred" >&2
            ;;
        0)
            echo "All tasks completed successfully" >&1
            ;;
    esac
    exit $error_code
}

# Main function to process backup tasks
process_backup_tasks() {
    for task_id in "${BACKUP_TASKS[@]}"; do
        echo "Checking if img_backup process is running..." >&1
        
        while is_backup_running; do
            echo "Backup is still running, waiting..." >&1
            sleep 60  # Wait 60 seconds before checking again
        done

        echo "Starting backup task $task_id..." >&1
        start_backup_task $task_id
        if [[ $? -ne 0 ]]; then
            echo "Failed to start backup task $task_id" >&2
            handle_error 22  # SSH error or task failed
        fi

        echo "Monitoring backup task $task_id..." >&1
        sleep 15  # Give some time for the backup to initiate

        while is_backup_running; do
            echo "Backup task $task_id is running..." >&1
            sleep 60  # Check every 60 seconds
        done

        echo "Backup task $task_id completed." >&1
    done
}

# Main script execution
echo "Starting backup task processing..." >&1
process_backup_tasks
if [[ $? -eq 0 ]]; then
    handle_error 0  # All tasks processed successfully
else
    handle_error 1  # General error
fi

