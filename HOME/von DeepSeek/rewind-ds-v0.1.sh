#!/usr/bin/env zsh

# rewind.sh - Restore files to a specific date from backup_most.sh backups

# Check if date argument is provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 YYYY-MM-DD [subdirectory]"
    echo "Example: $0 2023-11-15 Documents/Projects"
    exit 1
fi

# Load configuration
CONFIG_FILE="${0:A:h}/backup_most.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file backup_most.conf not found!"
    exit 1
fi

target_date=$1
subdir=${2:-}  # Optional subdirectory
restore_root="${backupdir}/${target_date}"

# Check if backup directory exists
if [[ ! -d "$restore_root" ]]; then
    echo "Error: No backup found for date $target_date"
    echo "Available backup dates:"
    ls -1 "$backupdir" | grep '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$' | sort -r
    exit 1
fi

# Confirm restoration
echo "This will restore files from backup dated $target_date"
if [[ -n "$subdir" ]]; then
    echo "Only restoring subdirectory: $subdir"
fi
echo "Restore location: $ziel"
echo -n "Are you sure you want to continue? (y/N) "
read -r answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Restoration cancelled."
    exit 0
fi

# Restore files
if [[ -n "$subdir" ]]; then
    # Restore only a subdirectory
    source_path="${restore_root}/${ziel##*/}/${subdir}"
    dest_path="${ziel}/${subdir}"
    
    if [[ ! -d "$source_path" ]]; then
        echo "Error: Subdirectory $subdir not found in backup"
        exit 1
    fi
    
    echo "Restoring $subdir from $target_date backup..."
    rsync -a --delete "$source_path/" "$dest_path"
else
    # Restore everything
    source_path="${restore_root}/${ziel##*/}"
    echo "Restoring entire directory from $target_date backup..."
    rsync -a --delete "$source_path/" "$ziel"
fi

echo "Restoration complete."