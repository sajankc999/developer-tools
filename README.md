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
- `net-tools` - For port checking functionality# Django Project Launcher with Celery Worker 🚀

A powerful bash script that automates launching a Django development server alongside a Celery worker in a split Terminator window. It includes environment management, port checking, and dependency validation.

## 📋 Features

- **Automated Setup** - Launches Django server and Celery worker in split Terminator windows
- **Smart Port Management** - Checks if ports are available and offers solutions if occupied
- **Environment Detection** - Automatically detects and uses project-specific Conda environments
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
```

### Method 2: Direct Download

```bash
# Download the script directly
wget https://raw.githubusercontent.com/sajankc999/developer-tools/main/django-launcher.sh

# Make it executable
chmod +x django-launcher.sh
```

### Optional: Add to PATH

```bash
# Move to system PATH for easy access
sudo mv django-launcher.sh /usr/local/bin/django-launch

# Now you can run from anywhere
django-launch --path ~/projects/your-django-project
```

## 📖 Usage Examples

### Basic Examples

```bash
# Launch with default settings
./django-launcher.sh --path ~/projects/Student-Portal-Server

# Launch with custom port
./django-launcher.sh --path ~/projects/ecommerce-site --port 8080

# Launch with specific conda environment
./django-launcher.sh --path ~/projects/blog-project --env blogenv

# Disable auto-reload for production-like testing
./django-launcher.sh --path ~/projects/api-service --noreload
```

### Real-World Scenarios

```bash
# Starting a new Django project
./django-launcher.sh --path ~/projects/my-new-blog --port 9000

# Working on an existing project with custom environment
./django-launcher.sh \
  --path ~/projects/Student-Portal-Server \
  --port 8080 \
  --env studentportal \
  --noreload

# Quick launch with auto-detected environment
./django-launcher.sh --path ~/projects/legacy-project
```

### Command Line Arguments

| Argument      | Description                | Default               | Required |
| ------------- | -------------------------- | --------------------- | -------- |
| `--path DIR`  | Django project directory   | -                     | ✅ Yes   |
| `--port PORT` | Django server port         | 8000                  | ❌ No    |
| `--env ENV`   | Conda environment name     | Auto-detected or base | ❌ No    |
| `--noreload`  | Disable Django auto-reload | Disabled              | ❌ No    |
| `-h, --help`  | Show help message          | -                     | ❌ No    |

## 🎯 How It Works

### Package Verification

```bash
# Script checks for required tools
✅ Found: terminator
✅ Found: xdotool
✅ Found: netstat
```

### Project Validation

```bash
📁 Validating Project Directory
✅ Directory exists: /home/user/projects/Student-Portal-Server
✅ Found Django project (manage.py)
✅ Project name detected: student_portal
```

### Environment Detection

```bash
# Auto-detects conda environment matching project name
✅ Found matching conda environment --> student_portal
```

### Port Check

```bash
🔌 Checking Port Availability
✅ Port 8000 is available
```

### Launch Sequence

```bash
🚀 Launching Terminator...
⚙️ Creating vertical split...
📦 Starting Celery Worker in right pane...
🚀 Starting Django Server in left pane...

✅ Both services started successfully!
ℹ️ Django: http://localhost:8000
ℹ️ Celery: Running in right pane
```

## 🔧 Advanced Configuration

### Adding to Ubuntu Startup Applications

1. Open Startup Applications:

```bash
gnome-session-properties
```

2. Click "Add" and configure:

- **Name**: Django Student Portal
- **Command**: `/bin/bash /home/sajan/developer-tools/django-launcher.sh --path /home/sajan/projects/Student-Portal-Server`
- **Comment**: Auto-start Django development environment

### Creating a Desktop Launcher

Create `~/.local/share/applications/django-launcher.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=Django Launcher
Comment=Launch Django project with Celery
Exec=/bin/bash /home/sajan/developer-tools/django-launcher.sh --path /home/sajan/projects/Student-Portal-Server
Icon=python
Terminal=false
Categories=Development;
```

### Creating an Alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Django launcher alias
alias django-dev='~/developer-tools/django-launcher.sh'

# Usage:
# django-dev --path ~/projects/myapp --port 9000
```

## 🐛 Troubleshooting

### Common Issues and Solutions

**Conda not found**

```bash
# Add to ~/.bashrc
eval "$(conda shell.bash hook)"
```

**xdotool key combinations not working**

```bash
# Increase delays in script (modify sleep values)
sleep 3  # Instead of sleep 2
```

**Port 8000 already in use**

Script will prompt:

```
❌ Port 8000 is already in use!
Options:
1 - Kill the process and continue
2 - Use a different port
3 - Exit script
```

Choose option 2 and enter a new port (e.g., 8080)

**Permission denied**

```bash
# Fix permissions
chmod +x django-launcher.sh

# If installing packages, script will ask for sudo
```

## 📝 Example Output

```bash
$ ./django-launcher.sh --path ~/projects/Student-Portal-Server --port 9000

╔══════════════════════════════════════════════════════════╗
║     🚀  Django Project Launcher with Celery Worker       ║
╚══════════════════════════════════════════════════════════╝

📦 Checking Required Packages
✅ Found: terminator
✅ Found: xdotool
✅ Found: netstat

📁 Validating Project Directory
✅ Directory exists: /home/sajan/projects/Student-Portal-Server
✅ Found Django project (manage.py)
✅ Django project name detected --> student_portal

🔌 Checking Port Availability
✅ Port 9000 is available

ℹ️ Configuration Summary
Project Directory:  /home/sajan/projects/Student-Portal-Server
Project Name:       student_portal
Conda Environment:  student_portal
Port:               9000
No Reload:          False

🚀 Launching Terminator...
⚙️ Creating vertical split...
📦 Celery Worker → Starting in right pane...
🚀 Django Server → Starting in left pane...

✅ Both services started successfully!
ℹ️ Django: http://localhost:9000
ℹ️ Celery: Running in right pane
```

## 🚀 Installation

### Method 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/sajankc999/developer-tools.git

# Navigate to the directory
cd developer-tools

# Make the script executable
chmod +x django-launcher.sh
```
