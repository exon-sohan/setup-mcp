#!/bin/bash

# ==============================================================================
# Salesforce MCP Server Setup Script for macOS & Linux (v2)
# ==============================================================================
# This script automates the entire setup and configuration process:
# 1. Checks for Git and Node.js.
# 2. Clones or updates the sf-mcp-server repository.
# 3. Installs dependencies and builds the project.
# 4. Automatically finds and updates the 'claude_desktop_config.json' file.
# ==============================================================================

# --- CONFIGURATION ---
REPO_URL="https://github.com/exon-sohan/exon-sf-mcp.git" # <-- IMPORTANT: CHANGE THIS
REPO_DIR="sf-mcp-server"
SERVER_NAME="sf-mcp-server"
CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# --- STYLING ---
bold=$(tput bold)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
reset=$(tput sgr0)

log_step() { echo ""; echo "${bold}${yellow}--- $1 ---${reset}"; }
log_success() { echo "${bold}${green}✔ $1${reset}"; }
log_error() { echo "${bold}${red}✖ ERROR: $1${reset}"; }

# --- DEPENDENCY CHECKS ---
log_step "Step 1: Checking Dependencies"
command -v git &> /dev/null || { log_error "Git not found. Please install it from https://git-scm.com/"; exit 1; }
command -v node &> /dev/null || { log_error "Node.js not found. Please install it from https://nodejs.org/"; exit 1; }
log_success "Git and Node.js are installed."

# --- GIT OPERATIONS ---
log_step "Step 2: Getting Source Code"
if [ -d "$REPO_DIR" ]; then
  echo "Directory '$REPO_DIR' found. Pulling latest changes..."
  cd "$REPO_DIR" || exit
  git pull || { log_error "Git pull failed."; exit 1; }
else
  echo "Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR" || { log_error "Git clone failed."; exit 1; }
  cd "$REPO_DIR" || exit
fi
log_success "Source code is up to date."

# --- BUILD PROJECT ---
log_step "Step 3: Installing Dependencies and Building"
npm install || { log_error "npm install failed."; exit 1; }
npm run build || { log_error "npm run build failed."; exit 1; }
log_success "Project built successfully."

# --- CONFIGURE CLAUDE DESKTOP ---
log_step "Step 4: Configuring Claude Desktop"
SERVER_ENTRY_POINT="$(pwd)/build/index.js"

# Check if the entry point file exists
if [ ! -f "$SERVER_ENTRY_POINT" ]; then
    log_error "Build artifact not found at '$SERVER_ENTRY_POINT'. Check your build process."
    exit 1
fi

# Create Claude directory if it doesn't exist
mkdir -p "$(dirname "$CLAUDE_CONFIG_PATH")"
# Create config file if it doesn't exist
touch "$CLAUDE_CONFIG_PATH"

# Use Node.js to safely parse and update the JSON file. This is more reliable than sed/awk.
node -e "
const fs = require('fs');
const path = require('path');

const configFile = '$CLAUDE_CONFIG_PATH';
const serverName = '$SERVER_NAME';
const serverEntryPoint = '$SERVER_ENTRY_POINT';

let config = {};
try {
    const rawData = fs.readFileSync(configFile, 'utf8');
    if (rawData) {
        config = JSON.parse(rawData);
    }
} catch (e) {
    console.error('Could not parse existing config file. Starting fresh.');
    config = {};
}

if (!config.mcpServers) {
    config.mcpServers = {};
}

config.mcpServers[serverName] = {
    command: 'node',
    args: [serverEntryPoint]
};

try {
    fs.writeFileSync(configFile, JSON.stringify(config, null, 2));
    console.log('SUCCESS'); // Signal success to the shell script
} catch (e) {
    console.error('Failed to write updated config file:', e);
    process.exit(1);
}
" > update_result.log 2>&1

if grep -q "SUCCESS" update_result.log; then
    log_success "Claude Desktop configuration updated successfully."
    rm update_result.log
else
    log_error "Failed to update Claude Desktop configuration. See details below:"
    cat update_result.log
    rm update_result.log
    exit 1
fi

# --- FINAL INSTRUCTIONS ---
echo ""
echo "${bold}${green}=========================================${reset}"
echo "${bold}${green}    SETUP COMPLETE! 🎉${reset}"
echo "${bold}${green}=========================================${reset}"
echo ""
echo "The '$SERVER_NAME' has been successfully configured for Claude Desktop."
echo ""
echo "${bold}Next Step: Please completely QUIT and RESTART the Claude Desktop application.${reset}"
echo "You should see the '${SERVER_NAME}' available in the UI."
echo ""
