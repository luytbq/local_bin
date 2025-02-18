#!/bin/bash
# apply for this layout:
# |------------------|
# |                  |
# |        0         |
# |                  |
# |------------------|
# |        1         |
# |------------------|

# Check if the current pane is in zoom mode
is_zoomed=$(tmux display-message -p '#{window_zoomed_flag}')

if [ "$is_zoomed" -eq 1 ]; then
    # If already zoomed, exit zoom mode and select bottom pane
    tmux resize-pane -Z
    tmux select-pane -t 1
else
    # Get the number of panes in the current tmux window
    pane_count=$(tmux list-panes | wc -l)

    if [ "$pane_count" -gt 1 ]; then
        # If panes exist, zoom the first pane (pane index 0)
        tmux resize-pane -Z -t 0
    else
        # If no panes, create a vertical split (pane 1)
        tmux split-window -v
        # Return focus to the original pane (pane 0)
        tmux select-pane -t 0
        # Resize the original pane to be larger (adjust -U value as needed)
        tmux resize-pane -D 15
        # Select bottom pane
        tmux select-pane -t 1
    fi
fi
