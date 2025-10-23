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
REPO_NAME="adr-stable"
# المجلد الذي يحتوي على الحزم وقواعد البيانات
REPO_DIR="repo" 

echo "--- ADR Repository Builder Started ---"

# --- 1. اكتشاف معمارية الجهاز وتحديد الرابط ---
ARCH=$(uname -m)

if [ "$ARCH" == "aarch64" ]; then
    ARCH_MIRROR="rsync://mirror.archlinuxarm.org/armv8/core/"
elif [ "$ARCH" == "x86_64" ]; then
    ARCH_MIRROR="rsync://mirror.archlinux.org/core/"
else
    echo "❌ ERROR: Architecture $ARCH not officially supported by this script."
    exit 1
fi

echo "✅ Detected Architecture: $ARCH"
echo "✅ Syncing packages from Mirror: $ARCH_MIRROR"

# --- 2. التحقق من وجود مجلد الحزم والانتقال إليه ---
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ ERROR: Repository directory '$REPO_DIR' not found. Please run 'mkdir $REPO_DIR' in the root."
    exit 1
fi
cd "$REPO_DIR"

# --- 3. مزامنة الحزم من الميرور الرسمي (rsync) ---
echo "3. Syncing packages from official Arch core repository..."
# نسحب ملفات الحزم الثنائية فقط (.pkg.tar.zst)
rsync -rtlDv "$ARCH_MIRROR" ./ --include '**.pkg.tar.zst' --exclude '*'

if [ $? -ne 0 ]; then
    echo "❌ ERROR: rsync failed. Check network connection or mirror URL."
    exit 1
fi

# --- 4. بناء قاعدة بيانات Pacman (repo-add) ---
echo "4. Building Pacman database: $REPO_NAME.db.tar.gz..."

# العودة للخلف لاستخدام مسار صحيح لملف قاعدة البيانات
# إنشاء/تحديث قاعدة بيانات المستودع
repo-add "../$REPO_NAME.db.tar.gz" *.pkg.tar.zst

DB_FILE="../$REPO_NAME.db.tar.gz"

if [ ! -f "$DB_FILE" ]; then
    echo "❌ ERROR: Database file $DB_FILE was not created."
    cd ..
    exit 1
fi
echo "✅ Database created successfully for $ARCH."

# --- 5. الانتهاء وإصدار التعليمات اليدوية ---
cd .. # العودة إلى جذر adr-repo

echo "--- ADR Build Complete. Files are ready for Git commit. ---"
echo "
⭐ MANUAL GIT STEP REQUIRED:
1. Check changes: git status
2. Add files: git add repo/ $REPO_NAME.db.tar.gz $REPO_NAME.files.tar.gz
3. Commit: git commit -m \"ADR Sync: $(date +%Y-%m-%d)\"
4. Push: git push origin main
"

