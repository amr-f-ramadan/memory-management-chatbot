#!/bin/bash

echo "=== Automated GUI Testing ==="

# Use the smart display manager to configure and run the application
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SMART_DISPLAY_SCRIPT="$SCRIPT_DIR/.devcontainer/smart-display.sh"

if [ -f "$SMART_DISPLAY_SCRIPT" ]; then
    echo "Using smart display manager..."
    "$SMART_DISPLAY_SCRIPT" --run --app "/workspace/build/membot"
else
    echo "Smart display manager not found, falling back to basic method..."
    
    # Source display configuration if it exists
    if [ -f "/workspace/.display_config" ]; then
        echo "Loading saved display configuration..."
        source /workspace/.display_config
        echo "Loaded DISPLAY: $DISPLAY"
    else
        echo "No display configuration found!"
        exit 1
    fi
    
    echo "Testing display: $DISPLAY"
    if command -v xset >/dev/null 2>&1 && timeout 3 xset q >/dev/null 2>&1; then
        echo "✓ Display is working"
    else
        echo "⚠ Display test failed, but continuing anyway..."
    fi
    
    # Build and run the application
    if [ ! -f "/workspace/build/membot" ]; then
        echo "Building application..."
        cd /workspace
        cmake -B build -S .
        cmake --build build
    fi
    
    echo "Running membot..."
    cd /workspace/build
    timeout 10 ./membot || echo "Application finished or timed out"
fi

echo "=== Test Complete ==="
