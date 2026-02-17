#!/bin/bash

# QuirkyTerminal Installation Script
# This script will install the quirkyterminal tool and configure it to run on terminal startup

echo "QuirkyTerminal Installation"
echo "==============================="
echo ""

# Create bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Copy the Swift script
echo "Installing quirkyterminal..."
cp quirkyterminal.swift ~/.local/bin/quirkyterminal
chmod +x ~/.local/bin/quirkyterminal

# Detect shell and add to appropriate config file
SHELL_NAME=$(basename "$SHELL")
CONFIG_FILE=""

case "$SHELL_NAME" in
    bash)
        CONFIG_FILE="$HOME/.bash_profile"
        if [ ! -f "$CONFIG_FILE" ]; then
            CONFIG_FILE="$HOME/.bashrc"
        fi
        ;;
    zsh)
        CONFIG_FILE="$HOME/.zshrc"
        ;;
    fish)
        CONFIG_FILE="$HOME/.config/fish/config.fish"
        ;;
    *)
        echo "⚠️  Unknown shell: $SHELL_NAME"
        echo "Please manually add the following line to your shell configuration:"
        echo "~/.local/bin/quirkyterminal"
        exit 1
        ;;
esac

# Check if already added
if grep -q "quirkyterminal" "$CONFIG_FILE" 2>/dev/null; then
    echo "✅ quirkyterminal is already configured in $CONFIG_FILE"
else
    echo "⚙️  Adding quirkyterminal to $CONFIG_FILE..."
    echo "" >> "$CONFIG_FILE"
    echo "# Display system info on terminal startup" >> "$CONFIG_FILE"
    echo "~/.local/bin/quirkyterminal" >> "$CONFIG_FILE"
    echo "✅ Added to $CONFIG_FILE"
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "To see the system info now, run:"
echo "  ~/.local/bin/quirkyterminal"
echo ""
echo "Or open a new terminal window."
echo ""
echo "To uninstall, remove the following:"
echo "  - ~/.local/bin/quirkyterminal"
echo "  - The quirkyterminal line from $CONFIG_FILE"
