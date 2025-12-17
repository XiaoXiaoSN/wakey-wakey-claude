#!/bin/bash
# Setup crontab for Wakey Wakey Claude
#
# This script adds two cron jobs:
# - 5:00 AM: Initial wake up to start counting token usage
#
# Usage:
#   chmod +x setup-crontab.sh
#   ./setup-crontab.sh

set -e

# Define constants
ANTHROPIC_MODEL=haiku
PROMPT="reply hi only"

# colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # no color

echo -e "${GREEN}🐱 Wakey Wakey Claude - Crontab Setup${NC}"
echo ""

# check if claude is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude CLI is not installed${NC}"
    echo "Please install it first:"
    echo "  curl -fsSL https://claude.ai/install.sh | bash"
    exit 1
fi

# get claude path
CLAUDE_PATH=$(which claude)
echo -e "${GREEN}✓ Claude CLI found at: ${CLAUDE_PATH}${NC}"

# get log path
LOG_PATH="${HOME}/wakey-wakey-claude.log"
echo -e "${GREEN}✓ Logs will be written to: ${LOG_PATH}${NC}"

# create backup of current crontab
echo ""
echo -e "${YELLOW}Creating backup of current crontab...${NC}"
crontab -l > /tmp/crontab.backup 2>/dev/null || true
echo -e "${GREEN}✓ Backup saved to: /tmp/crontab.backup${NC}"

# check if wakey-wakey entries already exist
if crontab -l 2>/dev/null | grep -q "wakey-wakey-claude"; then
    echo ""
    echo -e "${YELLOW}Warning: Wakey Wakey Claude entries already exist in crontab${NC}"
    read -p "Do you want to replace them? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted${NC}"
        exit 1
    fi

    # remove existing entries
    crontab -l 2>/dev/null | grep -v "wakey-wakey-claude" | crontab -
    echo -e "${GREEN}✓ Removed existing entries${NC}"
fi

# add new crontab entries
echo ""
echo -e "${YELLOW}Adding new crontab entries...${NC}"

(crontab -l 2>/dev/null; echo "# Wakey Wakey Claude - 5 AM wake up") | crontab -
(crontab -l; echo "0 21 * * * ${CLAUDE_PATH} -p --model $ANTHROPIC_MODEL --max-turns 1 \"$PROMPT\" >> ${LOG_PATH} 2>&1") | crontab -
(crontab -l; echo "") | crontab -
(crontab -l; echo "# Wakey Wakey Claude - 10 AM first reset") | crontab -
(crontab -l; echo "0 18 * * * ${CLAUDE_PATH} -p --model $ANTHROPIC_MODEL --max-turns 1 \"$PROMPT\" >> ${LOG_PATH} 2>&1") | crontab -

echo -e "${GREEN}✓ Crontab entries added${NC}"

# display current crontab
echo ""
echo -e "${YELLOW}Current crontab:${NC}"
echo "----------------------------------------"
crontab -l | grep -A1 "Wakey Wakey Claude"
echo "----------------------------------------"

# test command
echo ""
echo -e "${YELLOW}Testing Claude command...${NC}"
if ${CLAUDE_PATH} -p --model $ANTHROPIC_MODEL --max-turns 1 "$PROMPT" >> ${LOG_PATH} 2>&1; then
    echo -e "${GREEN}✓ Test successful! Check ${LOG_PATH} for output${NC}"
else
    echo -e "${RED}✗ Test failed. Please check your Claude setup${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Check logs: tail -f ${LOG_PATH}"
echo "  2. List crontab: crontab -l"
echo "  3. Remove crontab: crontab -r"
echo "  4. Edit crontab: crontab -e"
echo ""
echo "Note for macOS users:"
echo "  You may need to grant Full Disk Access to /usr/sbin/cron"
echo "  System Preferences > Security & Privacy > Full Disk Access"
echo ""
