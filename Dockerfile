# Multi-stage Docker build for C++ Memory Management Chatbot
FROM ubuntu:22.04 as builder

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    libwxgtk3.0-gtk3-dev \
    libwxgtk3.0-gtk3-0v5 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files
COPY . .

# Create build directory and build the project
RUN mkdir -p build && cd build && \
    cmake .. && \
    make

# Runtime stage
FROM ubuntu:22.04 as runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libwxgtk3.0-gtk3-0v5 \
    libgtk-3-0 \
    libx11-6 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -s /bin/bash appuser

# Set working directory
WORKDIR /app

# Copy built executable from builder stage
COPY --from=builder /app/build/membot .
COPY --from=builder /app/src/answergraph.txt .

# Change ownership to app user
RUN chown -R appuser:appuser /app

# Switch to app user
USER appuser

# Expose display for GUI (if running with X11 forwarding)
ENV DISPLAY=:0

# Default command
CMD ["./membot"]
