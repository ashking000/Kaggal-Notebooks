#!/bin/bash

################################################################################
# 🔐 COMPREHENSIVE SECRET PURGE SCRIPT
# This script completely removes all tokens, API keys, and secrets from git history
# using git-filter-repo
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔐 SECRET PURGE AUTOMATION SCRIPT${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Step 1: Verify we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ ERROR: Not in a git repository!${NC}"
    echo "Please navigate to your repository root directory first."
    exit 1
fi

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
REPO_PATH=$(git rev-parse --show-toplevel)

echo -e "${GREEN}✅ Repository detected: ${REPO_NAME}${NC}"
echo -e "${BLUE}📂 Path: ${REPO_PATH}${NC}\n"

# Step 2: Check if git-filter-repo is installed
echo -e "${YELLOW}📦 Checking for git-filter-repo...${NC}"
if ! command -v git-filter-repo &> /dev/null; then
    echo -e "${YELLOW}⚠️  git-filter-repo not found. Installing...${NC}"
    pip install git-filter-repo
    echo -e "${GREEN}✅ Installed git-filter-repo${NC}\n"
else
    echo -e "${GREEN}✅ git-filter-repo is installed${NC}\n"
fi

# Step 3: Create backup
echo -e "${YELLOW}📦 Creating backup...${NC}"
BACKUP_DIR="${REPO_PATH}-backup-$(date +%Y%m%d-%H%M%S)"
cp -r "${REPO_PATH}" "${BACKUP_DIR}"
echo -e "${GREEN}✅ Backup created at: ${BACKUP_DIR}${NC}\n"

# Step 4: Create patterns file
echo -e "${YELLOW}📋 Creating secret patterns file...${NC}"
PATTERNS_FILE="${REPO_PATH}/patterns.txt"

cat > "${PATTERNS_FILE}" << 'PATTERNS_EOF'
# API Keys and Tokens (Generic)
(?i)(api[_-]?key|apikey)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?
(?i)(access[_-]?token|accesstoken)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?
(?i)(secret[_-]?key|secretkey)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?
(?i)(auth[_-]?token|authtoken)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?

# Kaggle Credentials
(?i)(kaggle[_-]?key|kaggle_key)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?
(?i)(kaggle[_-]?username|kaggle_username)\s*[:=]\s*['""]?[\w\-\.]+['""]?
ash17king0==>REDACTED

# HuggingFace Tokens
(?i)(hf[_-]?token|hf_token)\s*[:=]\s*['""]?hf_[A-Za-z0-9\-._~+/]+=*['""]?
hf_[A-Za-z0-9]{34,}==>REDACTED

# Zrok Tokens
(?i)(zrok[_-]?token|zrok_token)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?
zrok_[A-Za-z0-9]{20,}==>REDACTED

# Docker Tokens
(?i)(docker[_-]?token|docker_token)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?
dckr_[A-Za-z0-9]{20,}==>REDACTED

# OpenAI/LLM API Keys
(?i)(openai[_-]?key|openai_key)\s*[:=]\s*['""]?sk-[A-Za-z0-9]{20,}['""]?
sk-[A-Za-z0-9]{20,}==>REDACTED

# Generic Secrets
(?i)(password|pwd|passwd)\s*[:=]\s*['""][^'""\n]+['""]
(?i)(secret)\s*[:=]\s*['""][^'""\n]+['""]
(?i)(token)\s*[:=]\s*['""]?[A-Za-z0-9\-._~+/]+=*['""]?

# AWS/Cloud Keys
AKIA[0-9A-Z]{16}==>REDACTED
aws_[a-z_]*_key==>REDACTED

# Environmental variables with sensitive values
os\.environ\[['""]KAGGLE_KEY['""\]\s*===>REDACTED
os\.environ\[['""]KAGGLE_USERNAME['""\]\s*===>REDACTED
PATTERNS_EOF

echo -e "${GREEN}✅ Patterns file created${NC}\n"

# Step 5: Scan for secrets
echo -e "${YELLOW}🔍 Scanning repository for secrets...${NC}"
SECRETS_FOUND=0

if git log --all -p | grep -iE "(kaggle_key|hf_token|zrok|docker|openai|password|secret|KAGGLE_USERNAME|ash17king0)" > /dev/null 2>&1; then
    SECRETS_FOUND=1
    echo -e "${RED}⚠️  Potential secrets detected in history!${NC}\n"
else
    echo -e "${YELLOW}ℹ️  No obvious secrets found (but proceeding with purge anyway)${NC}\n"
fi

# Step 6: Confirmation
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo -e "${RED}⚠️  IMPORTANT WARNINGS:${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo -e "1. This will REWRITE git history for the entire repository"
echo -e "2. All collaborators must re-clone the repository"
echo -e "3. Local clones will need to be reset"
echo -e "4. You MUST have write access to push to the repository"
echo -e "5. If the repo is forked, those forks will retain old history"
echo -e "6. GitHub may cache old commits (eventual consistency)"
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}\n"

read -p "Do you want to proceed with secret purge? (yes/no): " -r CONFIRM
if [[ ! $CONFIRM =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}❌ Operation cancelled${NC}"
    exit 1
fi

echo -e "${BLUE}Proceeding with purge...${NC}\n"

# Step 7: Run git-filter-repo
echo -e "${YELLOW}🧹 Running git-filter-repo...${NC}"
echo -e "${BLUE}This may take a moment...${NC}\n"

cd "${REPO_PATH}"
git filter-repo --replace-text "${PATTERNS_FILE}" --force 2>&1 | tee filter-repo.log

echo -e "${GREEN}✅ git-filter-repo completed${NC}\n"

# Step 8: Verify cleaning
echo -e "${YELLOW}🔍 Verifying secrets removal...${NC}"

VERIFICATION_FAILED=0

# Check downlaod-models.ipynb
if git show HEAD:downlaod-models.ipynb 2>/dev/null | grep -iE "(ash17king0|KAGGLE_KEY|KAGGLE_USERNAME)" > /dev/null 2>&1; then
    echo -e "${RED}❌ Still found secrets in downlaod-models.ipynb${NC}"
    VERIFICATION_FAILED=1
else
    echo -e "${GREEN}✅ downlaod-models.ipynb is clean${NC}"
fi

# Check qwen3api.ipynb
if git show HEAD:qwen3api.ipynb 2>/dev/null | grep -iE "(hf_token|KAGGLE)" > /dev/null 2>&1; then
    echo -e "${RED}❌ Still found secrets in qwen3api.ipynb${NC}"
    VERIFICATION_FAILED=1
else
    echo -e "${GREEN}✅ qwen3api.ipynb is clean${NC}"
fi

# General check
if git log --all -p | grep -iE "(kaggle_key|hf_token|zrok|KAGGLE_USERNAME|ash17king0)" > /dev/null 2>&1; then
    echo -e "${RED}❌ Potential secrets still found in history${NC}"
    VERIFICATION_FAILED=1
else
    echo -e "${GREEN}✅ No obvious secrets in git history${NC}"
fi

echo ""

if [ $VERIFICATION_FAILED -eq 1 ]; then
    echo -e "${YELLOW}⚠️  Some secrets may still exist. Running additional cleanup...${NC}"
    
    # Create a more aggressive replacement script
    cat > "${REPO_PATH}/additional-replacements.txt" << 'EXTRA_EOF'
kaggle_key==>REDACTED
KAGGLE_KEY==>REDACTED
KAGGLE_USERNAME==>REDACTED
hf_token==>REDACTED
ash17king0==>REDACTED
EXTRA_EOF
    
    git filter-repo --replace-text "${REPO_PATH}/additional-replacements.txt" --force 2>&1 | tail -20
    echo -e "${GREEN}✅ Additional cleanup completed${NC}\n"
fi

# Step 9: Create .gitignore
echo -e "${YELLOW}📝 Creating .gitignore...${NC}"

cat > "${REPO_PATH}/.gitignore" << 'GITIGNORE_EOF'
# Credentials and Secrets
.env
.env.local
.env.*.local
.env.secret
secrets.json
credentials.json
config.json
.kaggle/
.huggingface/
.aws/
.ssh/

# API Keys in notebooks
*_keys.ipynb
*_tokens.ipynb
*_secrets.ipynb
*_credentials.ipynb

# Jupyter checkpoints and cache
.ipynb_checkpoints/
*.ipynb_checkpoints/
.jupyter/

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
ENV/
env/
.venv

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
*.sublime-project
*.sublime-workspace

# Git
.git-credentials

# OS
.DS_Store
Thumbs.db
GITIGNORE_EOF

git add .gitignore
git commit -m "chore: add .gitignore to prevent future credential leaks" || echo "⚠️  .gitignore may already be in place"

echo -e "${GREEN}✅ .gitignore created/updated${NC}\n"

# Step 10: Git cleanup
echo -e "${YELLOW}🧹 Running git cleanup...${NC}"
git reflog expire --expire=now --all
git gc --prune=now --aggressive
echo -e "${GREEN}✅ Git cleanup completed${NC}\n"

# Step 11: Summary before push
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 REPOSITORY STATUS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

echo "Repository: $(git config --get remote.origin.url)"
echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Total commits: $(git rev-list --count HEAD)"
echo "Modified files: $(git status --short | wc -l)"
echo ""

# Step 12: Push confirmation
echo -e "${RED}⚠️  FINAL WARNING BEFORE PUSH${NC}"
echo "This will force-push to GitHub and rewrite history for all branches!"
echo ""

read -p "Ready to force-push to GitHub? (yes/no): " -r PUSH_CONFIRM
if [[ ! $PUSH_CONFIRM =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}❌ Push cancelled${NC}"
    echo -e "${BLUE}Your local repository has been cleaned but NOT pushed${NC}"
    exit 1
fi

# Step 13: Push to GitHub
echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
echo -e "${BLUE}This may take a moment...${NC}\n"

git push origin --force-with-lease --all
git push origin --force-with-lease --tags

echo -e "${GREEN}✅ Push completed${NC}\n"

# Step 14: Final verification
echo -e "${YELLOW}🔍 Final verification...${NC}"
echo "Checking GitHub remote..."

# Create a temporary clone to verify
TEMP_VERIFY_DIR="/tmp/verify-${REPO_NAME}-$(date +%s)"
mkdir -p "${TEMP_VERIFY_DIR}"
cd "${TEMP_VERIFY_DIR}"
git clone https://github.com/ashking000/Kaggal-Notebooks.git . 2>&1 | tail -5

if git log --all -p 2>/dev/null | grep -iE "(kaggle_key|hf_token|KAGGLE_USERNAME|ash17king0)" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  WARNING: GitHub still shows old history (may be cached)${NC}"
    echo -e "${BLUE}GitHub caches may take up to 24 hours to refresh${NC}"
else
    echo -e "${GREEN}✅ GitHub remote is clean!${NC}"
fi

# Cleanup
cd /
rm -rf "${TEMP_VERIFY_DIR}"

# Final summary
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SECRET PURGE COMPLETE!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 NEXT STEPS FOR YOUR TEAM:${NC}"
echo "1. Notify all collaborators about the history rewrite"
echo "2. They should delete their local clones and re-clone:"
echo "   rm -rf Kaggal-Notebooks"
echo "   git clone https://github.com/ashking000/Kaggal-Notebooks.git"
echo ""
echo -e "${YELLOW}🔑 REGENERATE CREDENTIALS:${NC}"
echo "1. Kaggle API Key: https://www.kaggle.com/settings/account"
echo "2. HuggingFace Token: https://huggingface.io/settings/tokens"
echo "3. Any other exposed API keys"
echo ""
echo -e "${YELLOW}📂 BACKUP LOCATION:${NC}"
echo "Backup created at: ${BACKUP_DIR}"
echo ""
echo -e "${YELLOW}📝 LOG FILE:${NC}"
echo "Filter-repo log: ${REPO_PATH}/filter-repo.log"
echo ""
echo -e "${GREEN}🎉 All secrets have been purged from git history!${NC}\n"

# Cleanup patterns file
rm -f "${PATTERNS_FILE}" "${REPO_PATH}/additional-replacements.txt"

echo -e "${BLUE}Script execution completed successfully!${NC}\n"
