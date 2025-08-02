#!/bin/bash

# Quick Display Setup for DevContainer
# This is a simplified version that runs faster during container creation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$WORKSPACE_ROOT/.display_config"

echo "=== Quick DevContainer Display Setup ==="

# Check if we already have a working configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    if [ -n "$DISPLAY" ]; then
        echo "Found existing display configuration: $DISPLAY"
        # Quick test
        if command -v xset >/dev/null 2>&1 && timeout 2 xset q >/dev/null 2>&1; then
            echo "Display is working!"
            exit 0
        fi
    fi
fi

# Install minimal X11 packages if not already installed
if ! command -v xvfb >/dev/null 2>&1; then
    echo "Installing minimal X11 packages..."
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y --no-install-recommends xvfb x11-utils 2>/dev/null || {
        echo "Warning: Failed to install X11 packages. Display setup will be skipped."
        echo "You can run the full setup later with: /workspace/.devcontainer/smart-display.sh"
        exit 0
    }
fi

# Start a simple virtual display
echo "Setting up virtual display..."
export DISPLAY=:99

# Kill any existing Xvfb on display 99
pkill -f "Xvfb :99" 2>/dev/null || true
sleep 1

# Start Xvfb
Xvfb :99 -screen 0 1024x768x24 -ac >/dev/null 2>&1 &
XVFB_PID=$!

# Give it a moment to start
sleep 2

# Test if it's working
if timeout 3 xset q >/dev/null 2>&1; then
    # Save configuration
    cat > "$CONFIG_FILE" << EOF
export DISPLAY=:99
XVFB_PID=$XVFB_PID
DISPLAY_TYPE=virtual
DISPLAY_SIZE=1024x768x24
CONFIGURED_AT=$(date)
EOF
    echo "Virtual display configured successfully on :99"
else
    echo "Warning: Virtual display setup failed"
    kill $XVFB_PID 2>/dev/null || true
fi

echo "=== Quick Setup Complete ==="
echo "For advanced display configuration, run: /workspace/.devcontainer/smart-display.sh"
