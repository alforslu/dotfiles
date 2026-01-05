#!/bin/bash
# RUN WITH SUDO!!
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Replace pacman config (backup existing config)
[ -f /etc/pacman.conf ] && cp /etc/pacman.conf /etc/pacman.conf.bak
cp "$SCRIPT_DIR/configs/pacman.conf" /etc/pacman.conf

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

install -d -m 755 /etc/systemd/system
install -m 644 "$SCRIPT_DIR"/services/*.service /etc/systemd/system/ 2>/dev/null || true
install -m 644 "$SCRIPT_DIR"/services/*.timer   /etc/systemd/system/ 2>/dev/null || true
install -m 644 "$SCRIPT_DIR"/services/user/*.service /etc/systemd/user/ 2>/dev/null || true
install -m 644 "$SCRIPT_DIR"/services/user/*.timer   /etc/systemd/user/ 2>/dev/null || true

systemctl daemon-reload

# Enable timers
systemctl enable --now reflector.timer
systemctl enable --now pacman-cache-wipe.timer
systemctl enable --now --user yay-cache-wipe.timer

echo "Installation complete."
