#!/bin/bash

function usage() {
	echo "Usage: $0 { type ('s'/'w') } {tmux session/window name} [commands and arguments]"
}

# Check if the required arguments are provided
if [ "$#" -lt 2 ]; then
	usage
	exit 1
fi

# Ensure the script is run inside a tmux session
if [ -z "$TMUX" ]; then
	echo "Error: This script must be run inside a tmux session."
	exit 1
fi

# Extract the window name (first argument) and command (remaining arguments)
TYPE="$1"
NAME="$2"
shift 2 # Remove TYPE and NAME from the arguments


if [[ "$TYPE" == "w" ]]; then
	# Rename the tmux window
	tmux rename-window "$NAME"
elif [[ "$TYPE" == "s" ]]; then
	# Rename the tmux session
	tmux rename-session "$NAME"
else
	echo "Type must be 's' or 'w'"
	usage
	exit 1
fi

# Execute the command
if [ "$#" -gt 0 ]; then
	eval "$@"
fi

