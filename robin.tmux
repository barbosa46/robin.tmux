PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p $PLUGIN_DIR/data

tmux bind-key m popup -E "${PLUGIN_DIR}/scripts/toggle_opencode.sh"

