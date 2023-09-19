#!/bin/bash

# Retrieve the day of the week
day_of_week=$(date +%u)
zip_file="backup_day_${day_of_week}.zip"

# Get location of the script
script_dir="$(dirname "$0")"

# Create the zip file while excluding files based on the patterns
zip -q -r "/mnt/NAS/Backups/${zip_file}" docker-volumes/ -x@"${script_dir}/backup-exclude.txt"

echo "Backup completed and saved as $zip_file"
