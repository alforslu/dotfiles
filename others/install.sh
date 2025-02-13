#!/bin/bash
set -e

# Replace pacman config (backup existing config)
[ -f /etc/pacman.conf ] && cp /etc/pacman.conf /etc/pacman.conf.bak
cp "$(dirname "$0")/pacman.conf" /etc/pacman.conf

# Update package database
pacman -Syu --noconfirm

# Install fonts
pacman -S --noconfirm \
  ttf-noto-nerd \
  noto-fonts-emoji \
  noto-fonts-cjk \
  noto-fonts \
  ttf-jetbrains-mono-nerd \
  ttf-jetbrains-mono \
  starship \
  zoxide

echo "Installation complete."
