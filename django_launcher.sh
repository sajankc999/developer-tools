#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Icons
INFO_ICON="ℹ️"
SUCCESS_ICON="✅"
WARNING_ICON="⚠️"
ERROR_ICON="❌"
ROCKET_ICON="🚀"
GEAR_ICON="⚙️"
PACKAGE_ICON="📦"
PORT_ICON="🔌"
FOLDER_ICON="📁"

# Default variables
PROJECT_DIR=""
PORT=8000
CONDA_ENV="base"
NO_RELOAD=""

# --- Function to check and install required packages ---
check_required_packages() {
    echo -e "\n${BOLD}${PURPLE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}${PACKAGE_ICON} Checking Required Packages${NC}"
    echo -e "${PURPLE}────────────────────────────────────────────────${NC}"
    
    local missing_packages=()
    
    # Check for terminator
    if ! command -v terminator &> /dev/null; then
        missing_packages+=("terminator")
        echo -e "${YELLOW}${WARNING_ICON} Missing: terminator${NC}"
    else
        echo -e "${GREEN}${SUCCESS_ICON} Found: terminator${NC}"
    fi
    
    # Check for xdotool
    if ! command -v xdotool &> /dev/null; then
        missing_packages+=("xdotool")
        echo -e "${YELLOW}${WARNING_ICON} Missing: xdotool${NC}"
    else
        echo -e "${GREEN}${SUCCESS_ICON} Found: xdotool${NC}"
    fi
    
    # Check for netstat (used for port checking)
    if ! command -v netstat &> /dev/null; then
        echo -e "${BLUE}${INFO_ICON} Installing net-tools for port checking...${NC}"
        missing_packages+=("net-tools")
    fi
    
    # Install missing packages if any
    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo -e "\n${YELLOW}${WARNING_ICON} Installing missing packages: ${missing_packages[*]}${NC}"
        echo -e "${BLUE}${INFO_ICON} This may require sudo password${NC}\n"
        
        sudo apt update
        sudo apt install -y "${missing_packages[@]}"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}${SUCCESS_ICON} Packages installed successfully${NC}"
        else
            echo -e "${RED}${ERROR_ICON} Failed to install packages${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}${SUCCESS_ICON} All required packages are installed${NC}"
    fi
}

# --- Function to check if port is available ---
check_port() {
    local port=$1
    echo -e "\n${BOLD}${PURPLE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}${PORT_ICON} Checking Port Availability${NC}"
    echo -e "${PURPLE}────────────────────────────────────────────────${NC}"
    
    # Check if port is in use
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        # Find the process using the port
        local pid=$(sudo lsof -t -i:$port 2>/dev/null)
        local process_info=""
        
        if [ -n "$pid" ]; then
            process_info=$(ps -p $pid -o comm= 2>/dev/null)
        fi
        
        echo -e "${RED}${ERROR_ICON} Port $port is already in use!${NC}"
        
        if [ -n "$process_info" ]; then
            echo -e "${YELLOW}${WARNING_ICON} Process using port $port: $process_info (PID: $pid)${NC}"
        else
            echo -e "${YELLOW}${WARNING_ICON} Another application is using port $port${NC}"
        fi
        
        # Ask user what to do
        echo -e "\n${BOLD}${YELLOW}Options:${NC}"
        echo -e "  ${CYAN}1${NC} - Kill the process and continue"
        echo -e "  ${CYAN}2${NC} - Use a different port"
        echo -e "  ${CYAN}3${NC} - Exit script"
        echo -e "${BOLD}${YELLOW}────────────────────────────────────────────────${NC}"
        
        read -p "$(echo -e ${CYAN}${INFO_ICON} Choose an option [1-3]: ${NC})" choice
        
        case $choice in
            1)
                echo -e "${YELLOW}${WARNING_ICON} Attempting to kill process on port $port...${NC}"
                if [ -n "$pid" ]; then
                    sudo kill -9 $pid 2>/dev/null
                    sleep 2
                    # Verify port is now free
                    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
                        echo -e "${RED}${ERROR_ICON} Failed to free port $port${NC}"
                        exit 1
                    else
                        echo -e "${GREEN}${SUCCESS_ICON} Port $port has been freed${NC}"
                    fi
                else
                    echo -e "${RED}${ERROR_ICON} Could not identify process to kill${NC}"
                    exit 1
                fi
                ;;
            2)
                local new_port=""
                while true; do
                    read -p "$(echo -e ${CYAN}${INFO_ICON} Enter new port number: ${NC})" new_port
                    if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1024 ] && [ "$new_port" -le 65535 ]; then
                        if netstat -tuln 2>/dev/null | grep -q ":$new_port "; then
                            echo -e "${RED}${ERROR_ICON} Port $new_port is also in use. Try another.${NC}"
                        else
                            PORT=$new_port
                            echo -e "${GREEN}${SUCCESS_ICON} Using port $PORT instead${NC}"
                            break
                        fi
                    else
                        echo -e "${RED}${ERROR_ICON} Please enter a valid port number (1024-65535)${NC}"
                    fi
                done
                ;;
            3)
                echo -e "${RED}${ERROR_ICON} Exiting script${NC}"
                exit 1
                ;;
            *)
                echo -e "${RED}${ERROR_ICON} Invalid option. Exiting.${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}${SUCCESS_ICON} Port $port is available${NC}"
    fi
}

# --- Function to validate project directory ---
validate_project_dir() {
    local dir=$1
    
    echo -e "\n${BOLD}${PURPLE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}${FOLDER_ICON} Validating Project Directory${NC}"
    echo -e "${PURPLE}────────────────────────────────────────────────${NC}"
    
    # Expand tilde if present
    dir="${dir/#\~/$HOME}"
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo -e "${RED}${ERROR_ICON} Directory does not exist: $dir${NC}"
        
        exit 1
    else
        echo -e "${GREEN}${SUCCESS_ICON} Directory exists: $dir${NC}"
    fi
    
    # Check for manage.py file
    if [ ! -f "$dir/manage.py" ]; then
        echo -e "${YELLOW}${WARNING_ICON} No manage.py found in directory${NC}"
        echo -e "${BLUE}${INFO_ICON} This doesn't appear to be a Django project root${NC}"
        
        # Ask user if they want to continue anyway
        read -p "$(echo -e ${YELLOW}${WARNING_ICON} Continue anyway? [y/N]: ${NC})" continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            echo -e "${RED}${ERROR_ICON} Exiting script${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}${SUCCESS_ICON} Found Django project (manage.py)${NC}"
    fi
    
    PROJECT_DIR="$dir"
}

# --- print help with colors ---
function usage() {
    echo -e "${BOLD}${CYAN}Usage:${NC} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}${YELLOW}Options:${NC}"
    echo -e "  ${GREEN}--path DIR${NC}          Specify the Django project directory ${WHITE}(required)${NC}"
    echo -e "  ${GREEN}--port PORT${NC}         Specify the Django server port ${WHITE}(default: $PORT)${NC}"
    echo -e "  ${GREEN}--noreload${NC}          Start Django without autoreload"
    echo -e "  ${GREEN}--env ENV${NC}           Use specific conda env"
    echo -e "  ${GREEN}-h, --help${NC}          Show this help message"
    echo
    echo -e "${BOLD}${WHITE}Example:${NC}"
    echo -e "  $0 --path ~/projects/my-django-project --port 8080 --env myenv"
    exit 0
}

# Print banner
echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     🚀  Django Project Launcher with Celery Worker       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for required packages first
check_required_packages

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            if [ -z "$2" ]; then
                echo -e "${RED}${ERROR_ICON} --path requires a directory argument${NC}"
                exit 1
            fi
            PROJECT_DIR="$2"
            echo -e "${BLUE}${FOLDER_ICON} Project path set to: ${CYAN}$PROJECT_DIR${NC}"
            shift 2
            ;;
        --port)
            PORT="$2"
            echo -e "${BLUE}${GEAR_ICON} Custom port set to: ${CYAN}$PORT${NC}"
            shift 2
            ;;
        --noreload)
            NO_RELOAD="--noreload"
            echo -e "${BLUE}${GEAR_ICON} Auto-reload disabled${NC}"
            shift
            ;;
        --env)
            CONDA_ENV="$2"
            echo -e "${BLUE}${GEAR_ICON} Using specified conda environment: ${CYAN}$CONDA_ENV${NC}"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}${ERROR_ICON} Unknown argument: $1${NC}"
            usage
            ;;
    esac
done

# Check if project directory was provided
if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}${ERROR_ICON} Project directory (--path) is required${NC}"
    usage
fi

# Validate project directory
validate_project_dir "$PROJECT_DIR"

# Change to project directory
cd "$PROJECT_DIR" || {
    echo -e "${RED}${ERROR_ICON} Error: Cannot change to directory $PROJECT_DIR${NC}"
    exit 1
}

# Get Django project name from manage.py
if [ -f "manage.py" ]; then
    PROJECT_NAME=$(grep DJANGO_SETTINGS_MODULE manage.py | sed -E 's/.*["'"'"']([^.]+)\..*/\1/' 2>/dev/null)
    if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME=$(basename "$PROJECT_DIR")
        echo -e "${YELLOW}${WARNING_ICON} Could not detect project name from manage.py, using directory name: ${CYAN}$PROJECT_NAME${NC}"
    else
        echo -e "${GREEN}${SUCCESS_ICON} Django project name detected${NC} ${BOLD}-->${NC} ${CYAN}$PROJECT_NAME${NC}"
    fi
else
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    echo -e "${YELLOW}${WARNING_ICON} No manage.py found, using directory name: ${CYAN}$PROJECT_NAME${NC}"
fi

# Check for project-specific conda env
CONDA_ENV_CHECK=$(conda env list | grep -i "$PROJECT_NAME" || echo "")

if [ -n "$CONDA_ENV_CHECK" ]; then
    CONDA_ENV="$PROJECT_NAME"
    echo -e "${GREEN}${SUCCESS_ICON} Found matching conda environment${NC} ${BOLD}-->${NC} ${CYAN}$CONDA_ENV${NC}"
else
    echo -e "${YELLOW}${WARNING_ICON} Conda environment '$PROJECT_NAME' does not exist. Using: ${CYAN}$CONDA_ENV${NC}"
fi

# Check if port is available
check_port "$PORT"

echo -e "\n${BOLD}${PURPLE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}${INFO_ICON} Configuration Summary${NC}"
echo -e "${PURPLE}────────────────────────────────────────────────${NC}"
echo -e "${WHITE}Project Directory:${NC}  ${YELLOW}$PROJECT_DIR${NC}"
echo -e "${WHITE}Project Name:${NC}       ${YELLOW}$PROJECT_NAME${NC}"
echo -e "${WHITE}Conda Environment:${NC}  ${YELLOW}$CONDA_ENV${NC}"
echo -e "${WHITE}Port:${NC}               ${YELLOW}$PORT${NC}"
echo -e "${WHITE}No Reload:${NC}          ${YELLOW}${NO_RELOAD:-False}${NC}"
echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════${NC}\n"

echo -e "${BOLD}${GREEN}${ROCKET_ICON} Launching Terminator...${NC}"

terminator &

sleep 2

# split vertically
echo -e "${BLUE}${GEAR_ICON} Creating vertical split...${NC}"
xdotool key Ctrl+Shift+E
sleep 0.5

# move to right pane
xdotool key Alt+Right
sleep 0.5

# run celery with colored output indicator
echo -e "${BOLD}${PURPLE}Celery Worker${NC} ${WHITE}→ Starting in right pane...${NC}"
xdotool type "echo -e '${CYAN}Starting Celery Worker...${NC}' && conda activate $CONDA_ENV && cd $PROJECT_DIR && celery -A $PROJECT_NAME worker -l info"
xdotool key Return

# move back to left pane
xdotool key Alt+Left
sleep 0.5

# run django with colored output indicator
echo -e "${BOLD}${GREEN}Django Server${NC} ${WHITE}→ Starting in left pane...${NC}"
xdotool type "echo -e '${GREEN}Starting Django Development Server...${NC}' && conda activate $CONDA_ENV && cd $PROJECT_DIR && python manage.py runserver 0:'$PORT' $NO_RELOAD"
xdotool key Return

echo -e "\n${BOLD}${GREEN}${SUCCESS_ICON} Both services started successfully!${NC}"
echo -e "${CYAN}${INFO_ICON} Django:${NC} http://localhost:$PORT"
echo -e "${CYAN}${INFO_ICON} Celery:${NC} Running in right pane\n"