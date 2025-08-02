#!/bin/bash

# Enhanced wrapper for the smart display manager
# This is called by devcontainer postCreateCommand

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== DevContainer Display Setup ==="
echo "This may take a few minutes during first setup..."

# Run the smart display manager with timeout protection
if [ -f "$SCRIPT_DIR/smart-display.sh" ]; then
    # Use timeout to prevent infinite hanging during container creation
    timeout 300 "$SCRIPT_DIR/smart-display.sh" --force || {
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo "Warning: Display setup timed out after 5 minutes"
            echo "You can complete the setup later by running:"
            echo "  /workspace/.devcontainer/smart-display.sh"
        else
            echo "Display setup failed with exit code: $exit_code"
        fi
        exit 0  # Don't fail the container creation
    }
else
    echo "Error: smart-display.sh not found"
    exit 1
fi

echo "=== Setup Complete ==="
