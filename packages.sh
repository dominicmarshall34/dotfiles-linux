#!/bin/bash

# Complete Arch Linux Setup Script
# Run this after a fresh Arch install

set -e

echo "🏗️  Setting up Arch Linux environment..."

# Update system first
echo "📦 Updating system..."
sudo pacman -Syu --noconfirm

# Install packages
echo "⬇️  Installing packages..."
packages=(
    brightnessctl
    dunst
    chromium
    fzf
    ghostty
    git
    hypridle
    hyprland
    hyprlock
    hyprpaper
    less
    neovim
    networkmanager
    openssh
    ripgrep
    ttf-hack-nerd
    waybar
)

sudo pacman -S --needed --noconfirm "${packages[@]}"

# Enable services
echo "🔧 Enabling services..."
sudo systemctl enable --now NetworkManager
# Uncomment if you want SSH enabled by default
# sudo systemctl enable --now sshd



# Set up git (optional - you might want to do this manually)
echo "🔧 Git setup (optional)..."
read -p "Enter your git username (or press Enter to skip): " git_user
if [[ ! -z "$git_user" ]]; then
    git config --global user.name "$git_user"
    read -p "Enter your git email: " git_email
    git config --global user.email "$git_email"
    echo "✅ Git configured"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "💡 Next steps:"
echo "  • Log out and select Hyprland from your display manager"
echo "  • Or run 'Hyprland' from TTY"
echo "  • Configure remaining dotfiles as needed"
