#!/bin/bash

set -e

# Colors
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║     Easy Supabase Self-Host      ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════╝${RESET}"
echo ""

# ─── Step 1: Project name ────────────────────────────────────────────────────
read -p "$(echo -e ${BOLD}"📁 Enter your project name: "${RESET})" PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
  echo -e "${RED}✖ Project name cannot be empty.${RESET}"
  exit 1
fi

PROJECT_DIR="$PROJECT_NAME"

echo ""
echo -e "${CYAN}▶ Cloning Supabase repo (shallow)...${RESET}"
git clone --depth 1 https://github.com/supabase/supabase supabase-source

echo -e "${CYAN}▶ Creating project directory: ${BOLD}$PROJECT_DIR${RESET}"
mkdir -p "$PROJECT_DIR"

echo -e "${CYAN}▶ Copying Docker compose files...${RESET}"
cp -rf supabase-source/docker/* "$PROJECT_DIR"
cp supabase-source/docker/.env.example "$PROJECT_DIR/.env"

echo -e "${CYAN}▶ Cleaning up cloned source...${RESET}"
rm -rf supabase-source

cd "$PROJECT_DIR"

echo ""

# ─── Step 2: Generate random keys ────────────────────────────────────────────
read -p "$(echo -e ${BOLD}"🔑 Generate random keys? (y/n): "${RESET})" GEN_KEYS

if [[ "$GEN_KEYS" =~ ^[Yy]$ ]]; then
  if [ -f "./utils/generate-keys.sh" ]; then
    echo ""
    echo -e "${CYAN}▶ Running generate-keys.sh...${RESET}"
    chmod +x ./utils/generate-keys.sh
    sh ./utils/generate-keys.sh

    echo ""
    echo -e "${YELLOW}⚠  Copy the keys above as a backup before starting.${RESET}"
    echo ""
    read -p "$(echo -e ${BOLD}"✅ Done editing .env? Press Enter to continue..."${RESET})"
  else
    echo -e "${RED}✖ utils/generate-keys.sh not found. Skipping key generation.${RESET}"
  fi
else
  echo -e "${YELLOW}⚠  Skipping key generation. Default example keys will be used.${RESET}"
fi

echo ""

# ─── Step 3: Docker compose pull ─────────────────────────────────────────────
read -p "$(echo -e ${BOLD}"🐳 Project is ready! Run docker compose pull now? (y/n): "${RESET})" DO_PULL

if [[ "$DO_PULL" =~ ^[Yy]$ ]]; then
  echo ""
  echo -e "${CYAN}▶ Pulling latest Supabase images (this may take a while)...${RESET}"
  docker compose pull
  echo ""
  echo -e "${GREEN}${BOLD}✔ All images pulled successfully!${RESET}"
  echo ""
  echo -e "${GREEN}${BOLD}🚀 Your Supabase project \"$PROJECT_NAME\" is ready!${RESET}"
  echo -e "   Run ${BOLD}cd $PROJECT_DIR && docker compose up -d${RESET} to start."
else
  echo ""
  echo -e "${GREEN}${BOLD}✔ Setup complete!${RESET}"
  echo -e "   Run ${BOLD}cd $PROJECT_DIR && docker compose pull && docker compose up -d${RESET} when ready."
fi

echo ""
