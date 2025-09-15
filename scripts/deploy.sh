#!/bin/bash

# Agent Adam - Deployment Script
# Builds and deploys the ICP canister and frontend

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="agent-adam"
NETWORK=${1:-local}  # Default to local network
BUILD_DIR="dist"

echo -e "${BLUE}🚀 Starting Agent Adam deployment...${NC}"

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ Error: $1 is not installed${NC}"
        echo -e "${YELLOW}Please install $1 to continue${NC}"
        exit 1
    fi
}

# Function to check DFX installation
check_dfx() {
    if ! command -v dfx &> /dev/null; then
        echo -e "${YELLOW}⚠️  DFX not found. Installing DFX...${NC}"
        sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
        export PATH="$HOME/bin:$PATH"
        
        if ! command -v dfx &> /dev/null; then
            echo -e "${RED}❌ Failed to install DFX${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ DFX version: $(dfx --version)${NC}"
}

# Function to setup environment
setup_environment() {
    echo -e "${BLUE}🔧 Setting up environment...${NC}"
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}📝 Creating .env file...${NC}"
        cat > .env << EOF
# Agent Adam Environment Configuration
NETWORK=$NETWORK
DFX_VERSION=0.15.0
CANISTER_IDS_FILE=canister_ids.json
EOF
    fi
    
    # Load environment variables
    if [ -f ".env" ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    
    # Install Node.js dependencies
    if [ -f "package.json" ]; then
        if command -v npm &> /dev/null; then
            npm install
        elif command -v yarn &> /dev/null; then
            yarn install
        else
            echo -e "${RED}❌ Neither npm nor yarn found${NC}"
            exit 1
        fi
    fi
    
    # Install Vessel dependencies (Motoko package manager)
    if [ -f "vessel.dhall" ] && command -v vessel &> /dev/null; then
        vessel install
    fi
}

# Function to build Motoko canister
build_motoko() {
    echo -e "${BLUE}🏗️  Building Motoko canister...${NC}"
    
    # Check if dfx.json exists
    if [ ! -f "dfx.json" ]; then
        echo -e "${RED}❌ dfx.json not found${NC}"
        exit 1
    fi
    
    # Start DFX if deploying to local network
    if [ "$NETWORK" = "local" ]; then
        echo -e "${YELLOW}🔄 Starting local DFX replica...${NC}"
        dfx start --background --clean
    fi
    
    # Build the project
    dfx build --network $NETWORK
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Motoko canister built successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build Motoko canister${NC}"
        exit 1
    fi
}

# Function to build frontend
build_frontend() {
    echo -e "${BLUE}🎨 Building frontend...${NC}"
    
    # Create build directory
    mkdir -p $BUILD_DIR
    
    # Copy frontend files
    cp -r src/frontend/* $BUILD_DIR/
    
    # If webpack is available, use it
    if command -v webpack &> /dev/null && [ -f "webpack.config.js" ]; then
        webpack --mode production
    else
        echo -e "${YELLOW}⚠️  Webpack not found, using simple file copy${NC}"
    fi
    
    echo -e "${GREEN}✅ Frontend built successfully${NC}"
}

# Function to deploy canisters
deploy_canisters() {
    echo -e "${BLUE}🚀 Deploying canisters to $NETWORK network...${NC}"
    
    # Deploy all canisters
    dfx deploy --network $NETWORK
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Canisters deployed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to deploy canisters${NC}"
        exit 1
    fi
}

# Function to generate canister URLs
generate_urls() {
    echo -e "${BLUE}🔗 Generating access URLs...${NC}"
    
    # Get canister IDs
    AGENT_ADAM_ID=$(dfx canister id AgentAdam --network $NETWORK 2>/dev/null || echo "not-deployed")
    FRONTEND_ID=$(dfx canister id frontend --network $NETWORK 2>/dev/null || echo "not-deployed")
    
    # Generate URLs based on network
    if [ "$NETWORK" = "local" ]; then
        LOCAL_PORT=$(dfx info replica-port 2>/dev/null || echo "4943")
        AGENT_ADAM_URL="http://127.0.0.1:$LOCAL_PORT/?canisterId=$AGENT_ADAM_ID"
        FRONTEND_URL="http://127.0.0.1:$LOCAL_PORT/?canisterId=$FRONTEND_ID"
    else
        AGENT_ADAM_URL="https://$AGENT_ADAM_ID.ic0.app"
        FRONTEND_URL="https://$FRONTEND_ID.ic0.app"
    fi
    
    # Save URLs to file
    cat > deployment_info.json << EOF
{
  "network": "$NETWORK",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "canisters": {
    "AgentAdam": {
      "id": "$AGENT_ADAM_ID",
      "url": "$AGENT_ADAM_URL"
    },
    "frontend": {
      "id": "$FRONTEND_ID",
      "url": "$FRONTEND_URL"
    }
  }
}
EOF
    
    echo -e "${GREEN}📄 Deployment info saved to deployment_info.json${NC}"
}

# Function to display results
display_results() {
    echo ""
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📊 Deployment Summary:${NC}"
    echo -e "Network: ${YELLOW}$NETWORK${NC}"
    echo -e "Agent Adam Canister ID: ${YELLOW}$AGENT_ADAM_ID${NC}"
    echo -e "Frontend Canister ID: ${YELLOW}$FRONTEND_ID${NC}"
    echo ""
    echo -e "${BLUE}🔗 Access URLs:${NC}"
    echo -e "Agent Adam: ${YELLOW}$AGENT_ADAM_URL${NC}"
    echo -e "Frontend: ${YELLOW}$FRONTEND_URL${NC}"
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo -e "1. Test the frontend interface"
    echo -e "2. Configure GoHighLevel webhooks"
    echo -e "3. Set up monitoring and alerts"
    echo ""
}

# Function to cleanup on exit
cleanup() {
    if [ "$NETWORK" = "local" ] && [ "$1" != "keep-running" ]; then
        echo -e "${YELLOW}🧹 Cleaning up...${NC}"
        # Note: Not stopping DFX by default to allow testing
        # Uncomment the next line if you want to stop DFX after deployment
        # dfx stop
    fi
}

# Main execution
main() {
    echo -e "${BLUE}Agent Adam - ICP Deployment Script${NC}"
    echo -e "${BLUE}====================================${NC}"
    
    # Check requirements
    check_dfx
    check_command "node"
    
    # Setup
    setup_environment
    install_dependencies
    
    # Build
    build_motoko
    build_frontend
    
    # Deploy
    deploy_canisters
    generate_urls
    
    # Display results
    display_results
    
    # Setup cleanup trap
    trap cleanup EXIT
}

# Help function
show_help() {
    echo "Agent Adam Deployment Script"
    echo ""
    echo "Usage: $0 [NETWORK]"
    echo ""
    echo "Networks:"
    echo "  local    Deploy to local DFX replica (default)"
    echo "  ic       Deploy to Internet Computer mainnet"
    echo ""
    echo "Examples:"
    echo "  $0           # Deploy to local network"
    echo "  $0 local     # Deploy to local network"
    echo "  $0 ic        # Deploy to IC mainnet"
    echo ""
    echo "Environment Variables:"
    echo "  DFX_NETWORK  Override network selection"
    echo ""
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Run main function
main "$@"