#!/bin/bash
# apply for this layout:
# |------------------|
# |                  |
# |        0         |
# |                  |
# |------------------|
# |    1    |   2    |
# |------------------|

# Check if the current pane is in zoom mode
is_zoomed=$(tmux display-message -p '#{window_zoomed_flag}')

if [ "$is_zoomed" -eq 1 ]; then
    # If already zoomed, exit zoom mode
    tmux resize-pane -Z
else
    # Get the number of panes in the current tmux window
    pane_count=$(tmux list-panes | wc -l)

    if [ "$pane_count" -gt 1 ]; then
        # If panes exist, zoom the first pane (pane index 0)
        tmux resize-pane -Z -t 0
    else
        # If no panes, create a vertical split (pane 1)
        tmux split-window -v
        # Create a horizontal split in the new pane (pane 2)
        tmux split-window -h
        # Return focus to the original pane (pane 0)
        tmux select-pane -t 0
        # Resize the original pane to be larger (adjust -U value as needed)
        tmux resize-pane -D 15
    fi
fi
