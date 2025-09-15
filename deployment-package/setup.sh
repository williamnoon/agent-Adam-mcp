#!/bin/bash

# Agent Adam - Setup Script
# Initializes the development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛠️  Setting up Agent Adam development environment...${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install DFX
install_dfx() {
    echo -e "${BLUE}📦 Installing DFX (Internet Computer SDK)...${NC}"
    
    if command_exists dfx; then
        echo -e "${GREEN}✅ DFX already installed: $(dfx --version)${NC}"
        return 0
    fi
    
    # Download and install DFX
    sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
    
    # Add to PATH
    export PATH="$HOME/bin:$PATH"
    
    if command_exists dfx; then
        echo -e "${GREEN}✅ DFX installed successfully: $(dfx --version)${NC}"
    else
        echo -e "${RED}❌ Failed to install DFX${NC}"
        exit 1
    fi
}

# Function to install Node.js dependencies
install_node_deps() {
    echo -e "${BLUE}📦 Installing Node.js dependencies...${NC}"
    
    if [ ! -f "package.json" ]; then
        echo -e "${YELLOW}⚠️  No package.json found, skipping Node.js dependencies${NC}"
        return 0
    fi
    
    # Check for package manager
    if command_exists npm; then
        npm install
        echo -e "${GREEN}✅ Node.js dependencies installed with npm${NC}"
    elif command_exists yarn; then
        yarn install
        echo -e "${GREEN}✅ Node.js dependencies installed with yarn${NC}"
    else
        echo -e "${RED}❌ Neither npm nor yarn found. Please install Node.js${NC}"
        exit 1
    fi
}

# Function to install Vessel (Motoko package manager)
install_vessel() {
    echo -e "${BLUE}📦 Installing Vessel (Motoko package manager)...${NC}"
    
    if command_exists vessel; then
        echo -e "${GREEN}✅ Vessel already installed${NC}"
        return 0
    fi
    
    # Install Vessel
    if command_exists cargo; then
        cargo install vessel
    else
        echo -e "${YELLOW}⚠️  Cargo not found. Installing Vessel via GitHub...${NC}"
        
        # Download latest release
        VESSEL_VERSION="v0.6.4"
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        ARCH=$(uname -m)
        
        if [ "$ARCH" = "x86_64" ]; then
            ARCH="x86_64"
        elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
            ARCH="arm64"
        fi
        
        VESSEL_URL="https://github.com/dfinity/vessel/releases/download/$VESSEL_VERSION/vessel-$OS-$ARCH"
        
        curl -L "$VESSEL_URL" -o vessel
        chmod +x vessel
        sudo mv vessel /usr/local/bin/
    fi
    
    if command_exists vessel; then
        echo -e "${GREEN}✅ Vessel installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Failed to install Vessel, but continuing...${NC}"
    fi
}

# Function to install Vessel packages
install_vessel_packages() {
    echo -e "${BLUE}📦 Installing Vessel packages...${NC}"
    
    if [ ! -f "vessel.dhall" ]; then
        echo -e "${YELLOW}⚠️  No vessel.dhall found, skipping Vessel packages${NC}"
        return 0
    fi
    
    if command_exists vessel; then
        vessel install
        echo -e "${GREEN}✅ Vessel packages installed${NC}"
    else
        echo -e "${YELLOW}⚠️  Vessel not available, skipping package installation${NC}"
    fi
}

# Function to create environment file
create_env_file() {
    echo -e "${BLUE}📝 Creating environment configuration...${NC}"
    
    if [ -f ".env" ]; then
        echo -e "${YELLOW}⚠️  .env file already exists, backing up...${NC}"
        cp .env .env.backup
    fi
    
    cat > .env << EOF
# Agent Adam Environment Configuration
# Generated on $(date)

# Network Configuration
NETWORK=local
DFX_VERSION=0.15.0

# Canister Configuration
CANISTER_IDS_FILE=canister_ids.json

# Development Settings
NODE_ENV=development
DEBUG=true

# Frontend Configuration
HOST=127.0.0.1
PORT=8080

# ICP Configuration
IC_HOST=https://ic0.app
LOCAL_HOST=http://127.0.0.1:4943

# GoHighLevel Integration (to be configured)
GHL_API_KEY=
GHL_LOCATION_ID=
GHL_WEBHOOK_SECRET=

# Logging
LOG_LEVEL=info
EOF
    
    echo -e "${GREEN}✅ Environment file created${NC}"
}

# Function to initialize git repository
init_git() {
    echo -e "${BLUE}📚 Initializing git repository...${NC}"
    
    if [ -d ".git" ]; then
        echo -e "${GREEN}✅ Git repository already initialized${NC}"
        return 0
    fi
    
    git init
    
    # Create .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << EOF
# Dependencies
node_modules/
.pnp
.pnp.js

# Production builds
/dist
/build
/.next

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# DFX
.dfx/
canister_ids.json

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
*.log

# Coverage reports
coverage/
*.lcov

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary files
*.tmp
*.temp
.cache/

# Vessel
.vessel/

# Build artifacts
*.wasm
*.did
EOF
    fi
    
    git add .
    git commit -m "Initial commit - Agent Adam project setup"
    
    echo -e "${GREEN}✅ Git repository initialized${NC}"
}

# Function to create development directories
create_directories() {
    echo -e "${BLUE}📁 Creating project directories...${NC}"
    
    # Create directories if they don't exist
    mkdir -p src/AgentAdam
    mkdir -p src/frontend/components
    mkdir -p src/frontend/services
    mkdir -p tests/unit
    mkdir -p tests/integration
    mkdir -p docs
    mkdir -p scripts
    mkdir -p .dfx
    
    echo -e "${GREEN}✅ Project directories created${NC}"
}

# Function to check system requirements
check_requirements() {
    echo -e "${BLUE}🔍 Checking system requirements...${NC}"
    
    # Check operating system
    OS=$(uname -s)
    echo -e "${BLUE}Operating System: ${YELLOW}$OS${NC}"
    
    # Check architecture
    ARCH=$(uname -m)
    echo -e "${BLUE}Architecture: ${YELLOW}$ARCH${NC}"
    
    # Check Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"
    else
        echo -e "${RED}❌ Node.js not found${NC}"
        echo -e "${YELLOW}Please install Node.js (recommended: v18 or higher)${NC}"
    fi
    
    # Check curl
    if command_exists curl; then
        echo -e "${GREEN}✅ curl available${NC}"
    else
        echo -e "${RED}❌ curl not found (required for DFX installation)${NC}"
    fi
    
    # Check git
    if command_exists git; then
        echo -e "${GREEN}✅ git available${NC}"
    else
        echo -e "${YELLOW}⚠️  git not found (recommended for version control)${NC}"
    fi
}

# Function to display next steps
show_next_steps() {
    echo ""
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo -e "1. Review and update the ${YELLOW}.env${NC} file with your configuration"
    echo -e "2. Install DFX extensions: ${YELLOW}dfx extension install nns${NC}"
    echo -e "3. Start local development: ${YELLOW}dfx start${NC}"
    echo -e "4. Deploy the project: ${YELLOW}./scripts/deploy.sh${NC}"
    echo -e "5. Run tests: ${YELLOW}./scripts/test.sh${NC}"
    echo ""
    echo -e "${BLUE}📖 Useful Commands:${NC}"
    echo -e "• ${YELLOW}dfx start --clean${NC} - Start local replica"
    echo -e "• ${YELLOW}dfx build${NC} - Build canisters"
    echo -e "• ${YELLOW}dfx deploy${NC} - Deploy canisters"
    echo -e "• ${YELLOW}dfx canister call AgentAdam getCanisterStatus${NC} - Test canister"
    echo ""
    echo -e "${BLUE}📚 Documentation:${NC}"
    echo -e "• Project: ${YELLOW}README.md${NC}"
    echo -e "• ICP SDK: ${YELLOW}https://internetcomputer.org/docs${NC}"
    echo -e "• Motoko: ${YELLOW}https://internetcomputer.org/docs/motoko${NC}"
    echo ""
}

# Main setup function
main() {
    echo -e "${BLUE}Agent Adam - Development Environment Setup${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    # Check system requirements
    check_requirements
    
    # Create project structure
    create_directories
    
    # Install dependencies
    install_dfx
    install_node_deps
    install_vessel
    install_vessel_packages
    
    # Setup configuration
    create_env_file
    
    # Initialize version control
    if command_exists git; then
        init_git
    fi
    
    # Show next steps
    show_next_steps
}

# Help function
show_help() {
    echo "Agent Adam Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --skip-dfx       Skip DFX installation"
    echo "  --skip-node      Skip Node.js dependencies"
    echo "  --skip-vessel    Skip Vessel installation"
    echo "  --skip-git       Skip git initialization"
    echo "  -h, --help       Show this help message"
    echo ""
}

# Handle command line arguments
SKIP_DFX=false
SKIP_NODE=false
SKIP_VESSEL=false
SKIP_GIT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-dfx)
            SKIP_DFX=true
            shift
            ;;
        --skip-node)
            SKIP_NODE=true
            shift
            ;;
        --skip-vessel)
            SKIP_VESSEL=true
            shift
            ;;
        --skip-git)
            SKIP_GIT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main setup
main