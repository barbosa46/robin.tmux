#!/bin/bash

PLUGIN_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR=$(tmux display-message -p "#{pane_current_path}")

SESSION_NAME="opencode_$(basename $CURRENT_DIR)"
PANE_ID_FILE="$PLUGIN_PATH/data/opencode_$(basename $CURRENT_DIR)_pane_id"


pane_exists() {
  local pane="$1"
  tmux list-panes -a -F "#{pane_id}" | grep -qx "$pane"
}

if [ ! -f "$PANE_ID_FILE" ]; then
  # File does not exist → create
  $PLUGIN_PATH/scripts/opencode_launcher.sh
else
  # File exists → read pane_id
  PANE_ID=$(cat "$PANE_ID_FILE")
  
  # Check if the pane still exists
  if ! pane_exists "$PANE_ID"; then
    # Pane does not exist → create new
    $PLUGIN_PATH/scripts/opencode_launcher.sh
  fi
fi

# Read the pane id
PANE_ID=$(cat "$PANE_ID_FILE")

if [ -z "$PANE_ID" ]; then
  echo "Pane ID do gemini não encontrado!"
  exit 1
fi

# Current pane where the cursor is located
CURRENT_PANE=$(tmux display-message -p "#{pane_id}")


# Check if the gemini pane is already visible in the current window
VISIBLE_PANES=$(tmux list-panes -F "#{pane_id}")

if echo "$VISIBLE_PANES" | grep -q "$PANE_ID"; then
  # If already visible → move the panel to the shared session and update
  if ! tmux has-session -t "opencode_shared_session" 2>/dev/null; then
    tmux new-session -d -s "opencode_shared_session" -n "opencode"
  fi
  tmux move-pane -s "$PANE_ID" -t "opencode_shared_session:opencode" && tmux refresh-client
else
  # If not visible → join-pane in vertical split in this window
  tmux join-pane -s "$PANE_ID" -t "$CURRENT_PANE" -h 
fi
