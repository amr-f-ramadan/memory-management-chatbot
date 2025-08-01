# Docker Setup for Memory Management Chatbot

This document provides instructions for building and running the Memory Management Chatbot using Docker.

## Prerequisites

- Docker and Docker Compose installed on your system
- X11 forwarding setup for GUI applications (Linux/macOS)

## Docker Images

### 1. Production Image (`Dockerfile`)
A multi-stage build that creates a minimal runtime image with just the compiled application.

### 2. Development Image (`Dockerfile.dev`)
A comprehensive development environment with all tools needed for C++ development, debugging, and testing.

## Quick Start

### Using Docker Compose (Recommended)

#### For Development
```bash
# Build and run development container
docker-compose run --rm chatbot-dev

# Or use the VS Code task: Ctrl+Shift+P -> "Tasks: Run Task" -> "docker-run-dev"
```

#### For Production
```bash
# Build and run application container
docker-compose run --rm chatbot-app

# Or use the VS Code task: Ctrl+Shift+P -> "Tasks: Run Task" -> "docker-run"
```

### Using Docker Directly

#### Development Container
```bash
# Build development image
docker build -f Dockerfile.dev -t membot-dev .

# Run development container with volume mount
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -e DISPLAY=$DISPLAY \
  --network host \
  membot-dev
```

#### Production Container
```bash
# Build production image
docker build -t membot .

# Run application
docker run -it --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -e DISPLAY=$DISPLAY \
  --network host \
  membot
```

## Development Workflow

### 1. VS Code with Dev Containers
The project includes a complete dev container configuration in `.devcontainer/`:

1. Open the project in VS Code
2. Install the "Remote - Containers" extension
3. Press `Ctrl+Shift+P` and select "Remote-Containers: Reopen in Container"
4. VS Code will build and connect to the development container automatically

### 2. Building the Project in Container
```bash
# Inside the development container
mkdir -p build && cd build
cmake ..
make

# Or use VS Code tasks (Ctrl+Shift+P -> "Tasks: Run Task")
# - "cmake-configure": Configure CMake
# - "build": Build the project
# - "run": Run the application
```

### 3. Debugging
The development container includes GDB for debugging:
- Use VS Code's built-in debugger with the "Debug Membot (Docker)" configuration
- Set breakpoints and debug as usual

## X11 Forwarding Setup

### Linux
```bash
# Allow X11 forwarding
xhost +local:docker
```

### macOS
1. Install XQuartz: `brew install --cask xquartz`
2. Start XQuartz and enable "Allow connections from network clients"
3. Set DISPLAY variable: `export DISPLAY=:0`
4. Allow connections: `xhost +localhost`

### Windows
Use an X11 server like VcXsrv or Xming with appropriate DISPLAY configuration.

## Development Tools Included

The development container includes:
- **Build Tools**: GCC, Clang, CMake, Make
- **Debugging**: GDB, Valgrind
- **Code Quality**: Clang-format, Clang-tidy, Cppcheck
- **Documentation**: Doxygen, Graphviz
- **Editors**: Vim, Nano

## Container Architecture

```
Production Container (ubuntu:22.04)
├── Runtime dependencies only
├── Compiled application
└── Minimal footprint

Development Container (ubuntu:22.04)
├── Full development toolchain
├── Debugging tools
├── Code analysis tools
├── Documentation tools
└── Source code mounted as volume
```

## Troubleshooting

### GUI Not Displaying
1. Ensure X11 forwarding is properly configured
2. Check DISPLAY environment variable
3. Verify xhost permissions
4. On macOS, ensure XQuartz is running

### Permission Issues
```bash
# Fix ownership in development container
sudo chown -R developer:developer /workspace
```

### Build Failures
1. Clean build directory: `rm -rf build`
2. Reconfigure: `cmake -B build`
3. Check dependencies in Dockerfile

## VS Code Integration

The project includes complete VS Code integration:

### Tasks Available
- `build`: Build the project
- `cmake-configure`: Configure CMake
- `clean`: Clean build directory
- `run`: Run the application
- `docker-build-dev`: Build development Docker image
- `docker-run-dev`: Run in development container
- `docker-build`: Build production Docker image
- `docker-run`: Run in production container

### Extensions Recommended
- C/C++ Extension Pack
- CMake Tools
- Remote - Containers
- Code Runner

### Debug Configurations
- Local debugging with GDB
- Docker container debugging
- Automatic build before debug
