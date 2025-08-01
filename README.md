# CPPND: Memory Management Chatbot - **COMPLETED PROJECT**

✅ **Completed C++ Nanodegree Project** - Third Course: Memory Management

This is my completed implementation of the Memory Management project from the [Udacity C++ Nanodegree Program](https://www.udacity.com/course/c-plus-plus-nanodegree--nd213). This project demonstrates mastery of modern C++ memory management concepts including smart pointers, move semantics, and the Rule of Five.

<img src="images/chatbot_demo.gif"/>

## 🚀 Project Overview

The ChatBot application creates an interactive dialogue where users can ask questions about C++ memory management concepts. The system uses a knowledge graph representation where chatbot answers are graph nodes and user queries are graph edges. The Levenshtein distance algorithm identifies the most probable answers to user queries.

## 🎯 My Contributions & Achievements

This project showcases **modern C++ best practices** that I implemented to transform a basic application using raw pointers into a memory-safe, efficient system:

### ✅ **Completed All 5 Core Tasks:**

1. **Smart Pointer Implementation** - Converted raw pointers to appropriate smart pointers
2. **Rule of Five Compliance** - Implemented proper copy/move constructors and assignment operators
3. **Exclusive Ownership Design** - Established clear ownership semantics using `std::unique_ptr`
4. **Move Semantics Optimization** - Eliminated unnecessary copying with move operations
5. **Memory Safety** - Resolved all memory leaks and dangling pointer issues

### 🔧 **Additional Enhancements:**

- **🐳 Docker Integration**: Complete containerization for development and production
- **🖥️ Automated Display Setup**: Cross-platform X11/GUI automation without hardcoding
- **⚙️ VS Code Integration**: Full development environment with CMake Tools
- **🐛 Debugging Support**: GDB integration for both local and Docker environments
- **📦 Development Container**: One-click development setup with dev containers
- **🔍 Code Quality Tools**: Static analysis, formatting, and documentation generation

### 💡 **Technical Skills Demonstrated:**

- **Memory Management**: Smart pointers (`unique_ptr`, `shared_ptr`), RAII principles
- **Modern C++**: Move semantics, Rule of Five, perfect forwarding
- **Design Patterns**: Ownership patterns, resource management
- **DevOps**: Docker multi-stage builds, containerized development
- **Tooling**: CMake, GDB debugging, static analysis

## Dependencies for Running Locally
**Note**: Docker setup eliminates the need for local dependencies!

* cmake >= 3.11
  * All OSes: [click here for installation instructions](https://cmake.org/install/)
* make >= 4.1 (Linux, Mac), 3.81 (Windows)
  * Linux: make is installed by default on most Linux distros
  * Mac: [install Xcode command line tools to get make](https://developer.apple.com/xcode/features/)
  * Windows: [Click here for installation instructions](http://gnuwin32.sourceforge.net/packages/make.htm)
* gcc/g++ >= 5.4
  * Linux: gcc / g++ is installed by default on most Linux distros
  * Mac: same deal as make - [install Xcode command line tools](https://developer.apple.com/xcode/features/)
  * Windows: recommend using [MinGW](http://www.mingw.org/)
* wxWidgets >= 3.0
  * Linux: `sudo apt-get install libwxgtk3.0-dev libwxgtk3.0-0v5`. If you are facing unmet dependency issues, refer to the [official page](https://wiki.codelite.org/pmwiki.php/Main/WxWidgets30Binaries#toc2) for installing the unmet dependencies.
  * Mac: There is a [homebrew installation available](https://formulae.brew.sh/formula/wxmac).
  * Installation instructions can be found [here](https://wiki.wxwidgets.org/Install). Some version numbers may need to be changed in instructions to install v3.0 or greater.

## 🛠️ Build & Run Options

### 🚀 **Quick Start - Automated GUI Setup**
The project includes intelligent display configuration that works automatically across all platforms:

```bash
# Automated test with GUI setup (recommended)
./test-gui.sh

# Manual display setup and run
./.devcontainer/smart-display.sh --run

# Force reconfigure display if needed
./.devcontainer/smart-display.sh --force --run
```

**✨ Features:**
- **🔄 Auto-Detection**: Automatically detects macOS, Linux, Docker environments
- **🎯 Smart Fallbacks**: X11 forwarding → Virtual display → Error handling  
- **💾 Persistent Config**: Saves working setup for reuse
- **🚫 No Hardcoding**: No machine-specific variables required

### Option 1: Docker (Recommended)
**No local dependencies required!**

```bash
# Quick start - Production version
docker-compose run --rm chatbot-app

# Development environment with full toolchain
docker-compose run --rm chatbot-dev

# VS Code with dev containers (one-click setup)
# Install "Remote - Containers" extension, then:
# Ctrl+Shift+P -> "Remote-Containers: Reopen in Container"
```

### Option 2: Local Build

1. Clone this repo.
2. Make a build directory in the top level directory: `mkdir build && cd build`
3. Compile: `cmake .. && make`
4. Run it: `./membot`.

📋 **See [DOCKER.md](DOCKER.md) for comprehensive Docker setup and [DISPLAY_SETUP.md](DISPLAY_SETUP.md) for automated display configuration details.**

## 🏆 Project Implementation Details

### ✅ **Bug Fix**: Window Close Crash
**RESOLVED** - Fixed memory management issue causing crashes when closing the application window.

### 📋 **Core Memory Management Tasks Completed:**

### ✅ **Task 1: Exclusive Ownership 1** - COMPLETED
**Implementation**: Converted `_chatLogic` in `ChatbotPanelDialog` to use `std::unique_ptr` for exclusive ownership. Updated all related data structures and function parameters to reflect the new ownership model.

### ✅ **Task 2: The Rule Of Five** - COMPLETED  
**Implementation**: Modified `ChatBot` class to fully comply with the Rule of Five:
- ✅ Copy Constructor with console logging
- ✅ Copy Assignment Operator with console logging  
- ✅ Move Constructor with console logging
- ✅ Move Assignment Operator with console logging
- ✅ Destructor with proper resource cleanup

### ✅ **Task 3: Exclusive Ownership 2** - COMPLETED
**Implementation**: Refactored `_nodes` vector in `ChatLogic` to use `std::unique_ptr<GraphNode>` for exclusive ownership. Ensured non-transferring access patterns and contained changes within `ChatLogic` class.

### ✅ **Task 4: Moving Smart Pointers** - COMPLETED
**Implementation**: Redesigned `GraphEdge` ownership model:
- ✅ `GraphNode` instances exclusively own outgoing edges via `std::unique_ptr`
- ✅ Non-owning raw pointer references for incoming edges  
- ✅ Move semantics for ownership transfer from `ChatLogic` to `GraphNode`

### ✅ **Task 5: Moving the ChatBot** - COMPLETED
**Implementation**: Created stack-based `ChatBot` instance in `LoadAnswerGraphFromFile`:
- ✅ Local `ChatBot` creation on stack
- ✅ Move semantics to transfer into root node
- ✅ Eliminated `ChatLogic` ownership of `ChatBot`
- ✅ Maintained communication handle via `_chatBot` member
- ✅ Console output verification of Rule of Five method calls

## 🎓 **Project Completion Status**

| Task | Status | Key Concepts Demonstrated |
|------|--------|---------------------------|
| Bug Fix | ✅ **COMPLETED** | Memory leak debugging, RAII |
| Task 1 | ✅ **COMPLETED** | `std::unique_ptr`, exclusive ownership |
| Task 2 | ✅ **COMPLETED** | Rule of Five, copy/move semantics |
| Task 3 | ✅ **COMPLETED** | Smart pointer containers, ownership design |
| Task 4 | ✅ **COMPLETED** | Move semantics, ownership transfer |
| Task 5 | ✅ **COMPLETED** | Stack vs heap allocation, move optimization |

## 🚀 **Expected Console Output**
When running the completed application, the Rule of Five implementation produces:
```
ChatBot Constructor
ChatBot Move Constructor
ChatBot Move Assignment Operator
ChatBot Destructor
ChatBot Destructor 
```

## 📁 **Project Structure**
```
memory-management-chatbot/
├── src/                    # Source code with implemented solutions
├── images/                 # Demo screenshots and assets
├── .vscode/               # VS Code configuration
├── .devcontainer/         # Development container and display automation
│   ├── devcontainer.json  # VS Code dev container configuration
│   ├── smart-display.sh   # Intelligent display configuration system
│   └── setup-display.sh   # Automated setup wrapper
├── test-gui.sh            # Automated GUI testing script
├── Dockerfile             # Production container
├── Dockerfile.dev         # Development container  
├── docker-compose.yml     # Multi-container orchestration
├── DOCKER.md             # Comprehensive Docker documentation
├── DISPLAY_SETUP.md      # Automated display configuration guide
└── CMakeLists.txt        # Build configuration
```

---

**🎯 This project demonstrates mastery of modern C++ memory management and represents a significant milestone in my C++ development journey through the Udacity Nanodegree program.**
