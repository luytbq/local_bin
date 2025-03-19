#!/bin/bash

# Define the remote server details
REMOTE_USER="root"
REMOTE_HOST="dev21"
REMOTE_PORT="17440"
REMOTE_DIR="/opt/msp/classes"
LOCAL_DIR="./target/classes"

# Ensure the local directory exists
if [[ ! -d "$LOCAL_DIR" ]]; then
    echo "Error: Local directory $LOCAL_DIR not found!"
    exit 1
fi

# Use fzf to select multiple .class files
selected_files=$(find "$LOCAL_DIR" -type f -name "*.class" | fzf --multi)

# Check if any files were selected
if [[ -z "$selected_files" ]]; then
    echo "No files selected."
    exit 1
fi

# Print the list of files that will be synced
echo "The following files will be synchronized:"
while IFS= read -r file; do
    relative_path="${file#$LOCAL_DIR/}"
    remote_path="$REMOTE_DIR/$relative_path"
    echo "  \"$file\" --> \"$REMOTE_USER@$REMOTE_HOST:$REMOTE_PORT$remote_path\""
done <<< "$selected_files"

# Ask for confirmation
read -p "Proceed with file sync? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Set up SSH control master connection
SSH_CTRL_SOCKET="/tmp/ssh-multiplex-$REMOTE_USER-$REMOTE_HOST-$REMOTE_PORT"
# ssh -nNf -o ControlMaster=yes -o ControlPath="$SSH_CTRL_SOCKET" "$REMOTE_USER@$REMOTE_HOST" -p "$REMOTE_PORT"
ssh -nNf -M -S "$SSH_CTRL_SOCKET" "$REMOTE_USER@$REMOTE_HOST" -p "$REMOTE_PORT"

# Define rsync command with the established SSH connection
RSYNC_CMD=(rsync -avz --progress -e "ssh -p $REMOTE_PORT -o ControlPath=$SSH_CTRL_SOCKET")

# Execute rsync for each selected file
while IFS= read -r file; do
    relative_path="${file#$LOCAL_DIR/}"
    remote_path="$REMOTE_DIR/$relative_path"
    # Debug print
    echo "rsync -avz --progress -e \"ssh -p $REMOTE_PORT -o ControlPath=$SSH_CTRL_SOCKET\" \"$file\" \"$REMOTE_USER@$REMOTE_HOST:$remote_path\""
    rsync -avz --progress -e "ssh -p $REMOTE_PORT -o ControlPath=$SSH_CTRL_SOCKET" "$file" "$REMOTE_USER@$REMOTE_HOST:$remote_path"
done <<< "$selected_files"

echo "Selected class files synced successfully!"

# setown && restart
ssh -S "$SSH_CTRL_SOCKET" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST" systemctl restart msp
echo "Restart service"

# Close the SSH multiplex connection
ssh -S "$SSH_CTRL_SOCKET" -O exit "$REMOTE_USER@$REMOTE_HOST"

echo "Close ssh connection"
