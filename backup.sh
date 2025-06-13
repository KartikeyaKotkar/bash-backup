#!/bin/bash

USERNAME=$(whoami)
HOME_DIR="/home/$USERNAME"
CONFIG_FILE="config.conf"
LOG_FILE="logs/backup.log"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "🔧 No config found. Let's set it up!"
    echo "Enter full paths to folders you want to back up (space separated):"
    read -r -a USER_INPUT

    echo "SOURCE_DIRS=(${USER_INPUT[@]})" > "$CONFIG_FILE"

    echo "Enter full path to destination folder for backups:"
    read -r DEST_DIR
    echo "DEST_DIR=\"$DEST_DIR\"" >> "$CONFIG_FILE"

    echo "✅ Config saved to $CONFIG_FILE!"
    source "$CONFIG_FILE"
fi

for dir in "${SOURCE_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "❌ Error: Source directory $dir does not exist. Exiting."
        exit 1
    fi
done

mkdir -p "$DEST_DIR" || { echo "❌ Cannot create/access destination $DEST_DIR"; exit 1; }

BACKUP_FILE="$DEST_DIR/backup_$TIMESTAMP.tar.gz"

echo "[$TIMESTAMP] 🔄 Starting backup..." | tee -a "$LOG_FILE"

tar -czf "$BACKUP_FILE" "${SOURCE_DIRS[@]}" 2>> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] ✅ Backup successful: $BACKUP_FILE" | tee -a "$LOG_FILE"
    command -v notify-send &> /dev/null && notify-send "✅ Backup Completed" "Saved as $BACKUP_FILE"
else
    echo "[$TIMESTAMP] ❌ Backup failed!" | tee -a "$LOG_FILE"
    command -v notify-send &> /dev/null && notify-send "❌ Backup Failed" "Check $LOG_FILE for errors"
fi
