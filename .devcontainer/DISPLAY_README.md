# Display Setup for DevContainer

This project includes several display setup scripts to handle X11 forwarding and virtual displays in the development container.

## Scripts Overview

### 1. `quick-setup-display.sh` (Default)
- **Purpose**: Fast setup during container creation
- **Features**: 
  - Minimal package installation
  - Quick virtual display setup
  - Prevents container creation hangs
  - Runs in under 30 seconds
- **Used by**: DevContainer `postCreateCommand`

### 2. `smart-display.sh` (Advanced)
- **Purpose**: Comprehensive display detection and configuration
- **Features**:
  - Auto-detects host display forwarding
  - Tries multiple display connection methods
  - Fallback to virtual display
  - Supports macOS, Linux, and Docker environments
- **Usage**: Run manually for advanced configuration

### 3. `setup-display.sh` (Legacy)
- **Purpose**: Wrapper for smart-display.sh with timeout protection
- **Features**: Prevents infinite hangs during container setup

## Troubleshooting

### Container Setup Hangs on "Configuring Dev Container"

**Problem**: The devcontainer setup appears to hang during creation.

**Cause**: X11 package installation can take several minutes, especially on slower networks.

**Solutions**:

1. **Wait it out**: The setup should complete in 2-5 minutes
2. **Use quick setup** (already configured): The default setup now uses `quick-setup-display.sh`
3. **Skip display setup**: Comment out `postCreateCommand` in `devcontainer.json`
4. **Manual setup**: Set up display after container creation

### Manual Display Setup

If you need to set up or reconfigure the display after container creation:

```bash
# Quick setup (fast)
/workspace/.devcontainer/quick-setup-display.sh

# Advanced setup (comprehensive)
/workspace/.devcontainer/smart-display.sh

# Force reconfiguration
/workspace/.devcontainer/smart-display.sh --force

# Run application with display
/workspace/.devcontainer/smart-display.sh --run
```

### Check Display Status

```bash
# Check if display is configured
cat /workspace/.display_config

# Test display connection
echo $DISPLAY
xset q

# List running Xvfb processes
ps aux | grep Xvfb
```

### Common Issues

1. **No display configured**: Run quick setup script
2. **Display test fails**: Try force reconfiguration  
3. **Xvfb not starting**: Check for port conflicts on display :99
4. **Package installation fails**: Check internet connection and apt sources

## Configuration Files

- `/workspace/.display_config`: Contains current display configuration
- `/workspace/.devcontainer/devcontainer.json`: Container configuration with display mounts
- `/tmp/.X11-unix/`: X11 socket directory (mounted from host)

## Environment Variables

- `DISPLAY`: Current display setting (e.g., `:99`, `host.docker.internal:0`)
- `HOST_DISPLAY`: Display from host environment (automatically passed)
- `XVFB_PID`: Process ID of virtual display server

## Tips

1. **For GUI testing**: Use the virtual display (default setup)
2. **For host display forwarding**: Run smart-display.sh manually
3. **For debugging**: Check VS Code devcontainer logs
4. **For performance**: Quick setup is sufficient for most use cases
