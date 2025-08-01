#!/bin/bash

# Smart Display Manager - Automatically detects and configures display for any environment
# This script works on macOS, Linux, and in Docker containers without hardcoding anything

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$WORKSPACE_ROOT/.display_config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect the operating system and environment
detect_environment() {
    local env_type="unknown"
    
    if [ -f "/.dockerenv" ]; then
        env_type="docker"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        env_type="macos"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        env_type="linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        env_type="windows"
    fi
    
    log_info "Detected environment: $env_type"
    echo "$env_type"
}

# Function to test if a display is working
test_display_connection() {
    local display_var="$1"
    local timeout_seconds="${2:-3}"
    
    if [ -z "$display_var" ]; then
        return 1
    fi
    
    export DISPLAY="$display_var"
    
    # Test 1: Try xdpyinfo (most reliable)
    if command -v xdpyinfo >/dev/null 2>&1; then
        if timeout "$timeout_seconds" xdpyinfo >/dev/null 2>&1; then
            return 0
        fi
    fi
    
    # Test 2: Try xset (lightweight)
    if command -v xset >/dev/null 2>&1; then
        if timeout "$timeout_seconds" xset q >/dev/null 2>&1; then
            return 0
        fi
    fi
    
    # Test 3: Check for X11 socket
    local display_num="${display_var##*:}"
    if [ -S "/tmp/.X11-unix/X${display_num}" ]; then
        return 0
    fi
    
    return 1
}

# Function to install required packages
install_dependencies() {
    local env_type="$1"
    
    log_info "Installing X11 dependencies..."
    
    case "$env_type" in
        "docker"|"linux")
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update -qq
                sudo apt-get install -y x11-utils x11-xserver-utils xvfb
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y xorg-x11-utils xorg-x11-server-Xvfb
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm xorg-utils xorg-server-xvfb
            fi
            ;;
        "macos")
            log_info "On macOS, ensure XQuartz is installed and running"
            if ! command -v xquartz >/dev/null 2>&1; then
                log_warning "XQuartz not found. Please install it from https://www.xquartz.org/"
            fi
            ;;
    esac
}

# Function to find host IP dynamically
find_host_ip() {
    local host_ip=""
    
    # Method 1: Default gateway
    if command -v ip >/dev/null 2>&1; then
        host_ip=$(ip route show default | awk '/default/ {print $3}' | head -1)
    fi
    
    # Method 2: DNS resolver
    if [ -z "$host_ip" ]; then
        host_ip=$(awk '/nameserver/ {print $2; exit}' /etc/resolv.conf 2>/dev/null)
        if [ "$host_ip" = "127.0.0.1" ]; then
            host_ip=""
        fi
    fi
    
    # Method 3: Docker host
    if [ -z "$host_ip" ] && [ -n "$DOCKER_HOST" ]; then
        host_ip=$(echo "$DOCKER_HOST" | sed 's/.*\/\/\([^:]*\).*/\1/')
    fi
    
    # Method 4: Container gateway
    if [ -z "$host_ip" ] && [ -f "/.dockerenv" ]; then
        host_ip=$(getent hosts host.docker.internal | awk '{print $1}' 2>/dev/null)
    fi
    
    echo "$host_ip"
}

# Function to generate display candidates
generate_display_candidates() {
    local env_type="$1"
    local host_display="$2"
    declare -a candidates=()
    
    # Add host display if provided
    if [ -n "$host_display" ]; then
        candidates+=("$host_display")
        
        # If it's a network display, try with detected host IP
        if [[ ! "$host_display" =~ ^/ ]]; then
            local host_ip
            host_ip=$(find_host_ip)
            if [ -n "$host_ip" ]; then
                local display_num="${host_display##*:}"
                candidates+=("$host_ip:$display_num")
            fi
        fi
    fi
    
    # Environment-specific candidates
    case "$env_type" in
        "docker")
            local host_ip
            host_ip=$(find_host_ip)
            if [ -n "$host_ip" ]; then
                candidates+=("$host_ip:0" "$host_ip:1" "$host_ip:10")
            fi
            candidates+=(":0" ":1" ":10" "localhost:0" "127.0.0.1:0")
            ;;
        "macos")
            candidates+=(":0" "localhost:0" "127.0.0.1:0")
            ;;
        "linux")
            candidates+=(":0" ":1" "localhost:0")
            ;;
    esac
    
    # Remove duplicates and print
    printf '%s\n' "${candidates[@]}" | sort -u
}

# Function to start virtual display
start_virtual_display() {
    log_info "Starting virtual display with Xvfb..."
    
    # Install Xvfb if not available
    if ! command -v Xvfb >/dev/null 2>&1; then
        log_info "Installing Xvfb..."
        sudo apt-get update -qq
        sudo apt-get install -y xvfb x11-utils x11-xserver-utils
    fi
    
    # Find available display number
    local display_num=99
    while [ -f "/tmp/.X${display_num}-lock" ] || [ -S "/tmp/.X11-unix/X${display_num}" ]; do
        display_num=$((display_num + 1))
    done
    
    log_info "Attempting to start Xvfb on display :$display_num"
    
    # Start Xvfb with simpler options first
    Xvfb ":$display_num" -screen 0 1024x768x24 -ac >/dev/null 2>&1 &
    local xvfb_pid=$!
    
    # Wait for startup
    sleep 3
    
    # Verify it started
    if kill -0 "$xvfb_pid" 2>/dev/null; then
        export DISPLAY=":$display_num"
        
        # Test the display
        if command -v xset >/dev/null 2>&1 && timeout 3 xset q >/dev/null 2>&1; then
            # Save configuration
            cat > "$CONFIG_FILE" << EOF
export DISPLAY=:$display_num
XVFB_PID=$xvfb_pid
DISPLAY_TYPE=virtual
DISPLAY_SIZE=1024x768x24
EOF
            
            log_success "Virtual display started on :$display_num"
            return 0
        else
            log_warning "Xvfb started but display test failed"
            kill "$xvfb_pid" 2>/dev/null
        fi
    else
        log_error "Xvfb process died after startup"
    fi
    
    log_error "Failed to start virtual display"
    return 1
}

# Function to save display configuration
save_display_config() {
    local display_val="$1"
    local display_type="${2:-forwarded}"
    
    cat > "$CONFIG_FILE" << EOF
export DISPLAY='$display_val'
DISPLAY_TYPE=$display_type
CONFIGURED_AT=$(date)
EOF
    
    log_success "Display configuration saved: $display_val"
}

# Function to load existing configuration
load_display_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Loaded existing configuration: $DISPLAY (type: ${DISPLAY_TYPE:-unknown})"
        
        # Test if the loaded configuration still works
        if test_display_connection "$DISPLAY"; then
            log_success "Existing configuration is working"
            return 0
        else
            log_warning "Existing configuration is not working, will reconfigure"
            rm -f "$CONFIG_FILE"
            return 1
        fi
    fi
    return 1
}

# Function to run application with display
run_application() {
    local app_path="$1"
    
    if [ ! -f "$app_path" ]; then
        log_error "Application not found: $app_path"
        return 1
    fi
    
    log_info "Running application: $app_path"
    log_info "Using DISPLAY: $DISPLAY"
    
    # Run with timeout to prevent hanging
    timeout 30 "$app_path" || {
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_warning "Application timed out after 30 seconds"
        else
            log_warning "Application exited with code: $exit_code"
        fi
    }
}

# Main function
main() {
    echo "=== Smart Display Manager ==="
    
    local force_reconfigure=false
    local run_app=false
    local app_path="/workspace/build/membot"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force|-f)
                force_reconfigure=true
                shift
                ;;
            --run|-r)
                run_app=true
                shift
                ;;
            --app|-a)
                app_path="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --force, -f    Force reconfiguration even if display is working"
                echo "  --run, -r      Run the application after configuring display"
                echo "  --app, -a      Specify application path (default: /workspace/build/membot)"
                echo "  --help, -h     Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Detect environment
    local env_type
    env_type=$(detect_environment)
    
    # Install dependencies
    install_dependencies "$env_type"
    
    # Try to load existing configuration
    if [ "$force_reconfigure" = false ] && load_display_config; then
        if [ "$run_app" = true ]; then
            run_application "$app_path"
        fi
        return 0
    fi
    
    # Get host display from environment
    local host_display="${HOST_DISPLAY:-$DISPLAY}"
    
    # Generate and test display candidates
    local candidates
    candidates=$(generate_display_candidates "$env_type" "$host_display")
    
    log_info "Testing display candidates..."
    
    while IFS= read -r candidate; do
        [ -z "$candidate" ] && continue
        
        log_info "Testing: $candidate"
        if test_display_connection "$candidate"; then
            export DISPLAY="$candidate"
            save_display_config "$candidate" "forwarded"
            log_success "Found working display: $candidate"
            
            if [ "$run_app" = true ]; then
                run_application "$app_path"
            fi
            return 0
        fi
    done <<< "$candidates"
    
    # If no display works, try virtual display
    log_warning "No working display found, setting up virtual display"
    if start_virtual_display; then
        if [ "$run_app" = true ]; then
            run_application "$app_path"
        fi
        return 0
    fi
    
    log_error "Failed to configure any display option"
    return 1
}

# Run main function with all arguments
main "$@"
