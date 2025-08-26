#!/bin/bash

# This script automates the setup of a custom MCP server for Claude Desktop on macOS/Linux
# It performs the following steps:
# 1. Checks if Node.js, Git, and jq are installed.
# 2. Creates a directory at ~/sf-mcp.
# 3. Clones the sf-mcp-test repository from GitHub.
# 4. Installs the npm dependencies globally.
# 5. Updates the Claude Desktop configuration file with the new server path.

# --- Define Colors for Output ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Step 1: Check for Prerequisites ---

echo -e "${CYAN}Checking for prerequisites (Node.js, Git, and jq)...${NC}"

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js not found. Please install it to continue. Exiting script.${NC}" >&2
    exit 1
fi
node_path=$(command -v node)
echo -e "${GREEN}Node.js found at: $node_path${NC}"

# Check for Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git not found. Please install it to continue. Exiting script.${NC}" >&2
    exit 1
fi
echo -e "${GREEN}Git found.${NC}"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: 'jq' is not found. It is required for JSON manipulation.${NC}" >&2
    echo -e "${YELLOW}Please install it using your package manager (e.g., 'brew install jq' on macOS or 'sudo apt-get install jq' on Debian/Ubuntu).${NC}" >&2
    exit 1
fi
echo -e "${GREEN}jq found.${NC}"

# --- Step 2: Set up the Project Directory ---

base_dir="$HOME/sf-mcp"
repo_name="sf-mcp-test"
full_repo_path="$base_dir/$repo_name"

echo -e "${CYAN}Creating directory: $base_dir${NC}"
mkdir -p "$base_dir"
cd "$base_dir" || { echo -e "${RED}Error: Could not change to directory $base_dir. Exiting.${NC}" >&2; exit 1; }

# --- Step 3: Clone the Repository ---

if [ ! -d "$full_repo_path" ]; then
    echo -e "${CYAN}Cloning repository 'https://github.com/exon-sohan/sf-mcp-test.git'...${NC}"
    if ! git clone https://github.com/exon-sohan/sf-mcp-test.git; then
        echo -e "${RED}Error: Failed to clone the repository. Please check your internet connection and Git settings. Exiting script.${NC}" >&2
        exit 1
    fi
else
    echo -e "${YELLOW}Repository directory '$repo_name' already exists. Skipping clone.${NC}"
fi


# --- Step 4: Install Dependencies ---

echo -e "${CYAN}Changing to repository directory and installing npm dependencies globally...${NC}"
cd "$full_repo_path" || { echo -e "${RED}Error: Could not change to directory $full_repo_path. Exiting.${NC}" >&2; exit 1; }

if ! npm install -g; then
    echo -e "${RED}Error: Failed to install npm dependencies. Exiting script.${NC}" >&2
    exit 1
fi

# --- Step 5: Update Claude Desktop Configuration ---

echo -e "${CYAN}Updating Claude Desktop configuration file...${NC}"

claude_config_path="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
claude_config_dir=$(dirname "$claude_config_path")

# Ensure the config directory exists
mkdir -p "$claude_config_dir"

# Check if the config file exists; if not, create it
if [ ! -f "$claude_config_path" ]; then
    echo -e "${YELLOW}Claude Desktop configuration file not found. Creating a new one.${NC}"
    echo "{}" > "$claude_config_path"
fi

# Path to the server's main script
server_script_path="$full_repo_path/build/index.js"

# Use jq to safely update the JSON file
# This command adds/updates .mcpServers."sf-mcp-server" with the new configuration
# It saves to a temporary file first to prevent corruption on error
temp_file=$(mktemp)
if jq \
  --arg cmd "$node_path" \
  --argjson args "[\"$server_script_path\"]" \
  '.mcpServers."sf-mcp-server" = {command: $cmd, args: $args}' \
  "$claude_config_path" > "$temp_file"; then
    mv "$temp_file" "$claude_config_path"
else
    echo -e "${RED}Error: Failed to update the JSON configuration file with jq. Please check the file's contents. Exiting script.${NC}" >&2
    rm "$temp_file"
    exit 1
fi

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${GREEN}The sf-mcp-server has been added to your Claude Desktop configuration.${NC}"