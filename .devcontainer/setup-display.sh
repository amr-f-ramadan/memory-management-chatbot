#!/bin/bash

# Simple wrapper for the smart display manager
# This is called by devcontainer postCreateCommand

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== DevContainer Display Setup ==="

# Run the smart display manager
if [ -f "$SCRIPT_DIR/smart-display.sh" ]; then
    "$SCRIPT_DIR/smart-display.sh" --force
else
    echo "Error: smart-display.sh not found"
    exit 1
fi

echo "=== Setup Complete ==="
