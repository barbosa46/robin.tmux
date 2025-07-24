#!/bin/bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR=$(tmux display-message -p "#{pane_current_path}")
PANE_COMMAND="bash -ic 'cd $CURRENT_DIR; opencode'"
SESSION_NAME="opencode_shared_session"
WINDOW="opencode"

PANE_ID_FILE="$PLUGIN_DIR/data/opencode_$(basename $CURRENT_DIR)_pane_id"

# Search for a pane running "opencode"
OPENCODE_PANE=$(tmux list-panes -t "$SESSION_NAME:$WINDOW" -F "#{pane_id} #{pane_current_command} #{pane_current_path}" | grep " $CURRENT_DIR" | grep "$PANE_COMMAND$" | head -n1 | awk '{print $1}')

if [ -z "$OPENCODE_PANE" ]; then
  # Create new session
  if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux new-session -d -s $SESSION_NAME -n $WINDOW "$PANE_COMMAND"
    sleep 0.5
  fi
  OPENCODE_PANE=$(tmux list-panes -t "$SESSION_NAME:$WINDOW" -F "#{pane_id}" | head -n1)
fi

echo "$OPENCODE_PANE" > "$PANE_ID_FILE"
