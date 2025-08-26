#!/bin/bash

read -p "Enter the directory to backup: " dir

if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist!"
    exit 1
fi

date=$(date +%F)
backup_name="$(basename "$dir")_$date.tar.gz"

backup_dir="$HOME/backups"
mkdir -p "$backup_dir"

tar -czf "$backup_dir/$backup_name" -C "$(dirname "$dir")" "$(basename "$dir")"

if [ $? -eq 0 ]; then
    echo "Backup successful! File created: $backup_dir/$backup_name"
else
    echo "Error: Backup failed!"
    exit 2
fi

 