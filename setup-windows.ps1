# ==============================================================================
# Salesforce MCP Server Setup Script for Windows (v2)
# ==============================================================================
# This script automates the entire setup and configuration process:
# 1. Checks for Git and Node.js.
# 2. Clones or updates the sf-mcp-server repository.
# 3. Installs dependencies and builds the project.
# 4. Automatically finds and updates the 'claude_desktop_config.json' file.
# ==============================================================================

# --- CONFIGURATION ---
$REPO_URL = "https://github.com/exon-sohan/exon-sf-mcp.git" 
$REPO_DIR = "sf-mcp-server"
$SERVER_NAME = "sf-mcp-server"
$CLAUDE_CONFIG_DIR = "$env:APPDATA\Claude"
$CLAUDE_CONFIG_PATH = Join-Path $CLAUDE_CONFIG_DIR "claude_desktop_config.json"

# --- HELPER FUNCTIONS ---
function Log-Step { param ([string]$Message) Write-Host "`n--- $Message ---" -ForegroundColor Yellow }
function Log-Success { param ([string]$Message) Write-Host "✔ $Message" -ForegroundColor Green }
function Log-Error { param ([string]$Message) Write-Host "✖ ERROR: $Message" -ForegroundColor Red; exit 1 }

# --- DEPENDENCY CHECKS ---
Log-Step "Step 1: Checking Dependencies"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Log-Error "Git not found. Please install it from https://git-scm.com/" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Log-Error "Node.js not found. Please install it from https://nodejs.org/" }
Log-Success "Git and Node.js are installed."

# --- GIT OPERATIONS ---
Log-Step "Step 2: Getting Source Code"
if (Test-Path -Path $REPO_DIR) {
    Write-Host "Directory '$REPO_DIR' found. Pulling latest changes..."
    Set-Location $REPO_DIR
    git pull
    if ($LASTEXITCODE -ne 0) { Log-Error "Git pull failed." }
} else {
    Write-Host "Cloning repository..."
    git clone $REPO_URL $REPO_DIR
    if ($LASTEXITCODE -ne 0) { Log-Error "Git clone failed." }
    Set-Location $REPO_DIR
}
Log-Success "Source code is up to date."

# --- BUILD PROJECT ---
Log-Step "Step 3: Installing Dependencies and Building"
npm install
if ($LASTEXITCODE -ne 0) { Log-Error "npm install failed." }
npm run build
if ($LASTEXITCODE -ne 0) { Log-Error "npm run build failed." }
Log-Success "Project built successfully."

# --- CONFIGURE CLAUDE DESKTOP ---
Log-Step "Step 4: Configuring Claude Desktop"
$SERVER_ENTRY_POINT = Join-Path (Get-Location).Path "build\index.js"

# Check if the entry point file exists
if (-not (Test-Path $SERVER_ENTRY_POINT)) {
    Log-Error "Build artifact not found at '$SERVER_ENTRY_POINT'. Check your build process."
}

# Ensure the directory and config file exist
if (-not (Test-Path $CLAUDE_CONFIG_DIR)) { New-Item -ItemType Directory -Path $CLAUDE_CONFIG_DIR | Out-Null }
if (-not (Test-Path $CLAUDE_CONFIG_PATH)) { Set-Content -Path $CLAUDE_CONFIG_PATH -Value "{}" }

# Read and parse the JSON config
$config = Get-Content -Path $CLAUDE_CONFIG_PATH -Raw | ConvertFrom-Json

# Add or update the server configuration
if (-not $config.mcpServers) {
    $config | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value (New-Object -TypeName PSObject)
}

$serverConfig = [PSCustomObject]@{
    command = "node"
    args    = @($SERVER_ENTRY_POINT)
}

$config.mcpServers | Add-Member -MemberType NoteProperty -Name $SERVER_NAME -Value $serverConfig -Force

# Write the updated config back to the file
$config | ConvertTo-Json -Depth 5 | Set-Content -Path $CLAUDE_CONFIG_PATH
Log-Success "Claude Desktop configuration updated successfully."

# --- FINAL INSTRUCTIONS ---
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "    SETUP COMPLETE! 🎉" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The '$SERVER_NAME' has been successfully configured for Claude Desktop."
Write-Host ""
Write-Host "Next Step: Please completely QUIT and RESTART the Claude Desktop application." -ForegroundColor Cyan
Write-Host "You should see the '$SERVER_NAME' available in the UI."
Write-Host ""
