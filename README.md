# Django Project Launcher with Celery Worker 🚀

A powerful bash script that automates launching a Django development server alongside a Celery worker in a split-terminator window. It includes environment management, port checking, and dependency validation.

## 📋 Features

- **Automated Setup** - Launches Django server and Celery worker in split Terminator windows
- **Smart Port Management** - Checks if ports are available and offers solutions if occupied
- **Environment Detection** - Automatically detects and uses project-specific conda environments
- **Dependency Validation** - Checks and installs required system packages
- **Interactive Error Handling** - Provides options when issues are encountered
- **Beautiful Colored Output** - Easy-to-read console with icons and colors
- **Flexible Configuration** - Command-line arguments for customization

## 🔧 Prerequisites

- Ubuntu/Debian-based Linux distribution
- Conda (Miniconda/Anaconda) installed
- Sudo access (for package installation)

## 📦 Required System Packages

The script automatically checks for and installs:
- `terminator` - Terminal emulator for split windows
- `xdotool` - X11 automation tool
- `net-tools` - For port checking functionality

## 🚀 Installation

### Method 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/sajankc999/developer-tools.git

# Navigate to the directory
cd developer-tools

# Make the script executable
chmod +x django-launcher.sh