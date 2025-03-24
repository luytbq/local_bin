#!/bin/bash

function usage() {
    echo "Usage: rename_and_ssh [user] <host> <port>"
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
    exit 1
fi

if [ -z "$TMUX" ]; then
    echo "Error: this script must be run inside a tmux session"
    exit 1
fi

if [ "$#" -eq 3 ]; then
    USER="$1"
    HOST="$2"
    PORT="$3"
else
    USER="root"
    HOST="$1"
    PORT="$2"
fi

echo "rename-window $USER@$HOST:$PORT && ssh $USER@$HOST -p $PORT"
tmux rename-window "$USER@$HOST:$PORT" && ssh "$USER@$HOST" -p "$PORT"
