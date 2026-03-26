#!/bin/bash
# Backup workspace to GitHub via SSH

REPO="git@github.com:Parns99/Jarvis-Files.git"
KEY="/root/.openclaw/workspace/github-deploy-key"
WORKSPACE="/root/.openclaw/workspace"
BRANCH="main"

cd "$WORKSPACE" || exit 1

# Configure git if needed
git config --global user.email "jarvis@parns.ai" 2>/dev/null
git config --global user.name "Jarvis Backup" 2>/dev/null

# Check if .git exists
if [ ! -d ".git" ]; then
    git init
    git remote add origin "$REPO"
    git fetch origin 2>/dev/null
    git checkout -b "$BRANCH" origin/"$BRANCH" 2>/dev/null || git checkout -b "$BRANCH"
fi

# Add all files we want to backup
git add -A . 2>/dev/null

# Check for changes
if [ -z "$(git diff --cached --name-only 2>/dev/null)" ] && [ -z "$(git diff --name-only 2>/dev/null)" ]; then
    echo "No changes to commit"
    exit 0
fi

# Commit
COMMIT_MSG="Backup $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG" 2>/dev/null || exit 0

# Push via SSH
GIT_SSH_COMMAND="ssh -i $KEY -o StrictHostKeyChecking=no" git push -f origin "$BRANCH" 2>/dev/null

echo "Backup completed: $COMMIT_MSG"