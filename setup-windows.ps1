# This script automates the setup of a custom MCP server for Claude Desktop
# It performs the following steps:
# 1. Checks if Node.js and Git are installed.
# 2. Creates a directory at C:\sf-mcp.
# 3. Clones the sf-mcp-test repository from GitHub.
# 4. Installs the npm dependencies globally.
# 5. Updates the Claude Desktop configuration file with the new server path.

# --- Step 1: Check for Prerequisites ---

Write-Host "Checking for prerequisites (Node.js and Git)..." -ForegroundColor Cyan

# Check for Node.js
try {
    $nodePath = (Get-Command node.exe).Source
    Write-Host "Node.js found at: $nodePath" -ForegroundColor Green
}
catch {
    Write-Error "Node.js not found. Please install it to continue. Exiting script."
    exit 1
}

# Check for Git
try {
    $gitPath = (Get-Command git.exe).Source
    Write-Host "Git found at: $gitPath" -ForegroundColor Green
}
catch {
    Write-Error "Git not found. Please install it to continue. Exiting script."
    exit 1
}

# --- Step 2: Set up the Project Directory ---

$baseDir = "C:\sf-mcp"
$repoName = "sf-mcp-test"
$fullRepoPath = Join-Path -Path $baseDir -ChildPath $repoName

Write-Host "Creating directory: $baseDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
Set-Location -Path $baseDir

# --- Step 3: Clone the Repository ---

Write-Host "Cloning repository 'https://github.com/exon-sohan/sf-mcp-test.git'..." -ForegroundColor Cyan
try {
    git clone https://github.com/exon-sohan/sf-mcp-test.git
}
catch {
    Write-Error "Failed to clone the repository. Please check your internet connection and Git settings. Exiting script."
    exit 1
}

# --- Step 4: Install Dependencies ---

Write-Host "Installing npm dependencies globally..." -ForegroundColor Cyan
Set-Location -Path $fullRepoPath
try {
    npm install -g
}
catch {
    Write-Error "Failed to install npm dependencies. Exiting script."
    exit 1
}

# --- Step 5: Update Claude Desktop Configuration ---

Write-Host "Updating Claude Desktop configuration file..." -ForegroundColor Cyan

$userProfile = $env:USERPROFILE
$claudeConfigPath = Join-Path -Path $userProfile -ChildPath "AppData\Roaming\Claude\claude_desktop_config.json"

# Define the UTF-8 without BOM encoding for use later
$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)

# Check if the config file exists
if (-not (Test-Path $claudeConfigPath)) {
    Write-Host "Claude Desktop configuration file not found. Creating a new one." -ForegroundColor Yellow
    # Create a new file with a basic JSON structure using the correct encoding
    [System.IO.File]::WriteAllText($claudeConfigPath, '{}', $utf8WithoutBom)
}

# Read the existing JSON content
try {
    $configContent = Get-Content -Raw -Path $claudeConfigPath | ConvertFrom-Json
}
catch {
    Write-Error "Failed to read or parse the JSON configuration file. Please check its contents. Exiting script."
    exit 1
}

# Define the new server configuration
$newServerConfig = @{
    command = $nodePath;
    args    = @("C:\sf-mcp\sf-mcp-test\build\index.js");
}

# Add or update the mcpServers object
if ($null -eq $configContent.mcpServers) {
    # If mcpServers doesn't exist, create it
    $configContent | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value @{}
}

# Add the new server to the mcpServers object
$configContent.mcpServers."sf-mcp-server" = $newServerConfig

# Convert the updated object back to JSON
$finalJson = $configContent | ConvertTo-Json -Depth 10

# Save the final JSON to the file using the correct encoding (UTF-8 without BOM)
[System.IO.File]::WriteAllText($claudeConfigPath, $finalJson, $utf8WithoutBom)


Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "The sf-mcp-server has been added to your Claude Desktop configuration." -ForegroundColor Green