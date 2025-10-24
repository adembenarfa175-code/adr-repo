#!/bin/bash
#
# APM (ADR Package Manager) Build Script
# Mode: Empty Database Creation (Final Solution)
#
# This script creates a valid, empty adr-stable.db.tar.gz file, 
# resolving the persistent 404 error on GitHub Pages.
#
# Copyright (C) YEAR adembenarfa175-code <adembenarfa175@Gmail.com>
# Licensed under GPLv2
#

# --- Configuration ---
REPO_NAME="adr-stable"
REPO_DIR="repo" 
DB_FILE="$REPO_NAME.db.tar.gz"

echo "--- ADR Empty Database Creator Started ---"

# --- 1. Detect Architecture (For Git Message) ---
ARCH=$(uname -m)
echo "✅ Detected Architecture: $ARCH"

# --- 2. Check for the repo directory ---
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ ERROR: Repository directory '$REPO_DIR' not found. Please run 'mkdir $REPO_DIR'."
    exit 1
fi

# --- 3. Manually Create the Empty Database File ---
echo "3. Manually creating empty database file: $DB_FILE..."

# Create a temporary empty directory for the archive content
mkdir -p "$REPO_DIR/temp_db"

# Create the compressed tarball containing nothing (or just the directory structure)
# This results in a valid, empty compressed file that Pacman can read without error.
tar -czf "$DB_FILE" -C "$REPO_DIR/temp_db" .

# Clean up the temporary directory
rm -rf "$REPO_DIR/temp_db"

# Also create the .files archive which Pacman also expects
touch "$REPO_NAME.files.tar.gz"

if [ ! -f "$DB_FILE" ]; then
    echo "❌ ERROR: Database file $DB_FILE was not created."
    exit 1
fi
echo "✅ Empty database created successfully."

# --- 4. Final Instructions ---
echo "--- ADR Database Creation Complete. ---"
echo "
⭐ MANUAL GIT STEP REQUIRED (Final Deployment):
1. Add files: git add .
2. Commit: git commit -m \"ADR Initial Release: Valid empty DB deployed for $ARCH.\"
3. Push: git push origin main
"

