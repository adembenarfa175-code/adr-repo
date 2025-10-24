#!/bin/bash
#
# APM (ADR Package Manager) Build Script - FINAL VERSION
# Mode: Multi-Architecture Database Creation (Guaranteed Success)
#
# هذا السكريبت يتجاوز عناد 'repo-add' لضمان إنشاء قواعد بيانات فارغة.
#
# Copyright (C) YEAR adembenarfa175-code <adembenarfa175@Gmail.com>
# Licensed under GPLv2
#

# --- Configuration ---
REPO_NAME="adr-stable"
REPO_ROOT="repo"

# --- 1. اكتشاف المعمارية (من المتغير) ---
TARGET_ARCH="$1"
if [ -z "$TARGET_ARCH" ]; then
    echo "❌ ERROR: Architecture not specified. Usage: ./adr-sync-and-build.sh <arch>"
    exit 1
fi
ARCH="$TARGET_ARCH"
echo "✅ Target Architecture: $ARCH"

# تعريف المسارات الجديدة
REPO_ARCH_DIR="$REPO_ROOT/$ARCH"
DB_FILE="${REPO_NAME}.db.tar.gz"
FILES_FILE="${REPO_NAME}.files.tar.gz"

# --- 2. التحقق من وجود مجلد المعمارية والتهيئ ---
if [ ! -d "$REPO_ARCH_DIR" ]; then
    echo ":: Creating architecture directory: $REPO_ARCH_DIR"
    mkdir -p "$REPO_ARCH_DIR"
fi

# المسار الكامل لقاعدة البيانات داخل مجلد المعمارية
FULL_DB_PATH="$REPO_ARCH_DIR/$DB_FILE"
FULL_FILES_PATH="$REPO_ARCH_DIR/$FILES_FILE"

# --- 3. بناء قاعدة بيانات Pacman يدوياً (Bypass repo-add) ---
echo "3. Manually ensuring database files exist for $ARCH..."

# 3a. إنشاء قاعدة البيانات الرئيسية (ملف مضغوط فارغ وصالح)
# هذا هو الحل الذي نجح سابقاً: إنشاء أرشيف tar/gz فارغ.
tar -czf "$FULL_DB_PATH" -C /dev/null . 
echo ":: Created empty database file: $FULL_DB_PATH"

# 3b. إنشاء ملف الفهرس (files) (ملف وهمي يكفي هنا)
touch "$FULL_FILES_PATH"
echo ":: Created empty files index: $FULL_FILES_PATH"

if [ ! -f "$FULL_DB_PATH" ]; then
    echo "❌ ERROR: Database file $FULL_DB_PATH was not created."
    exit 1
fi
echo "✅ Database files created successfully for $ARCH."

# --- 4. الانتهاء وإصدار التعليمات اليدوية ---

echo "--- ADR DB Build Complete for $ARCH. Files are ready for Git commit. ---"
echo "
⭐ GIT STATUS: Files in $REPO_ARCH_DIR are ready for push.
"
