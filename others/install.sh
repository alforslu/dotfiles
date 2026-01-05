#!/bin/bash
set -e

# Replace pacman config (backup existing config)
[ -f /etc/pacman.conf ] && cp /etc/pacman.conf /etc/pacman.conf.bak
cp "$(dirname "$0")/configs/pacman.conf" /etc/pacman.conf

# Update package database
pacman -Syu --noconfirm

# Install deps and software I always want
pacman -S --noconfirm \
  ttf-noto-nerd \
  noto-fonts-emoji \
  noto-fonts-cjk \
  noto-fonts \
  ttf-jetbrains-mono-nerd \
  ttf-jetbrains-mono \
  starship \
  zoxide \
  keychain \
  reflector \
  btop

# Enable weekly reflector timer
systemctl enable --now reflector.timer

echo "Installation complete."
