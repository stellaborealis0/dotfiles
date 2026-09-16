#!/bin/bash

# Kilo Google MCP Setup Script
# Configures workspace-mcp with read-only access by default,
# requiring a master key for write access.
# Breaks dependency on .roo/ directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KILO_CONFIG_DIR="$HOME/.config/kilo"
MASTER_KEY_FILE="$KILO_CONFIG_DIR/google-master-key.env"
LOCK_FILE="$KILO_CONFIG_DIR/google-mcp-mode.lock"
CREDENTIALS_FILE="$KILO_CONFIG_DIR/google-oauth.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Kilo Google MCP Setup Script${NC}"
echo "================================"

# Check if we're running on MB machine (based on hostname or IP)
IS_MB_MACHINE=false
if [[ $(hostname) == *"MB"* ]] || [[ $(hostname) == *"mb"* ]]; then
    IS_MB_MACHINE=true
elif [[ $(ip addr show | grep -c "100.68.1.93") -gt 0 ]]; then
    IS_MB_MACHINE=true
fi

if [ "$IS_MB_MACHINE" = true ]; then
    echo -e "${YELLOW}Detected MB machine - enforcing read-only mode${NC}"
    echo "MB machines cannot enable write mode without explicit master key authorization."
fi

# Load credentials
if [ -f "$CREDENTIALS_FILE" ]; then
    echo "Loading Google OAuth credentials from $CREDENTIALS_FILE..."
    source "$CREDENTIALS_FILE"
else
    echo -e "${YELLOW}Warning: Google OAuth credentials not found at $CREDENTIALS_FILE${NC}"
    echo "Please create it from the template or run the Kilo Google MCP setup."
fi

# Function to check if master key is valid
check_master_key() {
    local provided_key="$1"
    
    if [ ! -f "$MASTER_KEY_FILE" ]; then
        echo -e "${RED}Error: Master key file not found at $MASTER_KEY_FILE${NC}"
        return 1
    fi
    
    # Source the master key file
    source "$MASTER_KEY_FILE"
    
    if [ -z "$GOOGLE_MCP_MASTER_KEY" ]; then
        echo -e "${RED}Error: Master key not configured${NC}"
        return 1
    fi
    
    # Compare keys
    if [ "$provided_key" = "$GOOGLE_MCP_MASTER_KEY" ]; then
        return 0
    else
        echo -e "${RED}Error: Invalid master key${NC}"
        return 1
    fi
}

# Default to read-only mode
GMAIL_READ_ONLY="true"
GOOGLE_DRIVE_READ_ONLY="true"

# Check if user wants to enable write mode
if [ "$IS_MB_MACHINE" = false ]; then
    echo ""
    echo "Do you want to enable WRITE access? (y/N)"
    read -r enable_write
    
    if [[ $enable_write =~ ^[Yy]$ ]]; then
        echo "Enter master key to enable write access:"
        read -s master_key
        
        if check_master_key "$master_key"; then
            GMAIL_READ_ONLY="false"
            GOOGLE_DRIVE_READ_ONLY="false"
            echo -e "${GREEN}Write access enabled successfully${NC}"
        else
            echo -e "${RED}Failed to enable write access - keeping read-only mode${NC}"
        fi
    else
        echo "Keeping read-only mode (default)"
    fi
else
    # For MB machines, only allow write mode with explicit master key
    echo ""
    echo "MB machine detected. Write access requires explicit master key."
    echo "Do you have the master key to enable write access? (y/N)"
    read -r has_master_key
    
    if [[ $has_master_key =~ ^[Yy]$ ]]; then
        echo "Enter master key:"
        read -s master_key
        
        if check_master_key "$master_key"; then
            GMAIL_READ_ONLY="false"
            GOOGLE_DRIVE_READ_ONLY="false"
            echo -e "${GREEN}Write access enabled for MB machine${NC}"
        else
            echo -e "${RED}Invalid master key - keeping read-only mode${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}Kilo Google MCP configuration complete${NC}"
echo "Gmail read-only: $GMAIL_READ_ONLY"
echo "Google Drive read-only: $GOOGLE_DRIVE_READ_ONLY"

# Create a lock file to indicate current mode
{
    echo "# Kilo Google MCP Mode Lock File"
    echo "# Generated on $(date)"
    echo "GMAIL_READ_ONLY=$GMAIL_READ_ONLY"
    echo "GOOGLE_DRIVE_READ_ONLY=$GOOGLE_DRIVE_READ_ONLY"
    echo "MACHINE_TYPE=$(if [ "$IS_MB_MACHINE" = true ]; then echo "MB"; else echo "OTHER"; fi)"
} > "$LOCK_FILE"

chmod 600 "$LOCK_FILE"
echo "Mode lock file created: $LOCK_FILE"
