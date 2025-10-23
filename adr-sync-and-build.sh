#!/bin/bash
#
# Arch Developers Repositories (ADR) Synchronization and Build Script
#
# Copyright (C) YEAR adembenarfa175-code <adembenarfa175@Gmail.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# --- Configuration ---
# Set the repository name for pacman (must match [adr-stable] in pacman.conf)
REPO_NAME="adr-stable"
# Directory to store the actual packages (binaries)
REPO_DIR="packages"
# Arch architecture (using aarch64 as per your Trch efforts)
ARCH="aarch64"
# Official mirror to sync from
ARCH_MIRROR="rsync://mirror.archlinuxarm.org/armv8/core/"
# ARCH_MIRROR="rsync://mirror.archlinux.org/community/" # Example if syncing x86_64 community

echo "--- ADR Repository Builder Started ---"

# --- 1. Setup Environment ---
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# --- 2. Synchronize Packages from Official Mirror (rsync) ---
echo "1. Syncing packages from $ARCH_MIRROR..."
# Pulling only the package files (.pkg.tar.zst) that are newer than local files.
# We're using the "core" repository as a starting point.
rsync -aLv "$ARCH_MIRROR" ./ --include '**.pkg.tar.zst' --exclude '*'

if [ $? -ne 0 ]; then
    echo "❌ ERROR: rsync failed. Check network connection or mirror URL."
    exit 1
fi

# --- 3. Build Pacman Database (repo-add) ---
echo "2. Building Pacman database: $REPO_NAME.db.tar.gz..."

# The 'repo-add' command creates/updates the repository database file,
# indexing all package files (*.pkg.tar.zst) in the current directory.
repo-add "../$REPO_NAME.db.tar.gz" *.pkg.tar.zst

# repo-add outputs the database file one level up (../)
DB_FILE="../$REPO_NAME.db.tar.gz"

if [ ! -f "$DB_FILE" ]; then
    echo "❌ ERROR: Database file $DB_FILE was not created."
    exit 1
fi
echo "✅ Database created successfully."

# --- 4. Git Operations & Deployment ---
cd .. # Go back to the root of the adr-repo directory

echo "3. Committing and pushing changes to GitHub..."

# Add all changes: new packages, database files (.db, .files), etc.
git add "$REPO_DIR" "$REPO_NAME.db.tar.gz" "$REPO_NAME.files.tar.gz"
git commit -m "ADR Build: Automated update with latest packages for $ARCH ($(date +%Y-%m-%d))"

# Push using the configured SSH key
git push origin main 

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Git push failed. Check your SSH key configuration or permissions on the repo."
    exit 1
fi

echo "--- ADR Build Complete. Repository deployed to GitHub Pages! ---"

