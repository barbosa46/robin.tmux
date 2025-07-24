PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p data
tmux bind-key m run-shell "${PLUGIN_DIR}/scripts/toggle_opencode.sh"

