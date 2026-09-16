#!/bin/bash

# Kilo workspace-mcp wrapper
# Reads mode from Kilo config lock file and invokes workspace-mcp accordingly.
# Breaks dependency on .roo/ directory.

KILO_CONFIG_DIR="$HOME/.config/kilo"
LOCK_FILE="$KILO_CONFIG_DIR/google-mcp-mode.lock"
CREDENTIALS_FILE="$KILO_CONFIG_DIR/google-oauth.env"

# Load credentials
if [ -f "$CREDENTIALS_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CREDENTIALS_FILE"
fi

# Export required env vars
export GOOGLE_OAUTH_CLIENT_ID
export GOOGLE_OAUTH_CLIENT_SECRET

# Determine mode from lock file
READ_ONLY="true"

if [ -f "$LOCK_FILE" ]; then
    # shellcheck disable=SC1090
    source "$LOCK_FILE"
    if [ "$GMAIL_READ_ONLY" = "false" ] || [ "$GOOGLE_DRIVE_READ_ONLY" = "false" ]; then
        READ_ONLY="false"
    fi
fi

# Invoke workspace-mcp
if [ "$READ_ONLY" = "true" ]; then
    exec ~/.local/bin/workspace-mcp --read-only
else
    exec ~/.local/bin/workspace-mcp
fi
