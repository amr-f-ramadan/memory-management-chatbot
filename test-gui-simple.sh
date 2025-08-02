#!/bin/bash

echo "Testing X11 forwarding in container..."
echo "DISPLAY is set to: $DISPLAY"

# Function to test GUI with virtual display  
test_with_virtual_display() {
    echo "Starting virtual display with Xvfb..."
    Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
    XVFB_PID=$!
    export DISPLAY=:99
    echo "Virtual display started. DISPLAY now set to: $DISPLAY"
    
    # Test with virtual display
    echo "Testing with virtual display..."
    cd /workspace/build
    timeout 10s ./membot
    
    # Kill Xvfb
    kill $XVFB_PID 2>/dev/null
}

# Test if X11 forwarding works first
echo "Testing X11 forwarding to host..."
if command -v xeyes &> /dev/null; then
    timeout 3s xeyes 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "X11 forwarding appears to work!"
        echo "Trying to run chatbot with host display..."
        cd /workspace/build
        ./membot
    else
        echo "X11 forwarding to host failed, trying virtual display..."
        test_with_virtual_display
    fi
else
    echo "Installing x11-apps..."
    sudo apt-get update && sudo apt-get install -y x11-apps
    timeout 3s xeyes 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "X11 forwarding works!"
        cd /workspace/build  
        ./membot
    else
        echo "X11 forwarding failed, using virtual display..."
        test_with_virtual_display
    fi
fi
