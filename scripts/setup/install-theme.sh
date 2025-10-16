#!/bin/bash
# Install chussenot zsh theme (symlink version)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THEME_SOURCE="$DOTFILES_DIR/configs/shell/chussenot.zsh-theme"
THEME_DEST="$HOME/.oh-my-zsh/themes/chussenot.zsh-theme"

echo "🎨 Installing chussenot zsh theme using symlink..."

# Check if Oh-My-Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "❌ Oh-My-Zsh not found. Please install Oh-My-Zsh first."
    echo "   Visit: https://ohmyz.sh/"
    exit 1
fi

# Check if source theme exists
if [ ! -f "$THEME_SOURCE" ]; then
    echo "❌ Source theme not found: $THEME_SOURCE"
    exit 1
fi

# Create themes directory if it doesn't exist
mkdir -p "$HOME/.oh-my-zsh/themes"

# If symlink/file exists but is not correct, replace it
if [ -L "$THEME_DEST" ] || [ -f "$THEME_DEST" ]; then
    if [ "$(readlink -- "$THEME_DEST" 2>/dev/null)" != "$THEME_SOURCE" ]; then
        echo "⚠️  Removing existing theme file: $THEME_DEST"
        rm -f "$THEME_DEST"
    fi
fi

# Create symlink to theme in Oh-My-Zsh themes directory
ln -sf "$THEME_SOURCE" "$THEME_DEST"
echo "✅ Symlink created: $THEME_DEST → $THEME_SOURCE"

# Check if theme is already set in zshrc
if grep -q 'ZSH_THEME="chussenot"' "$HOME/.zshrc" 2>/dev/null; then
    echo "✅ Theme already set in .zshrc"
else
    echo "⚠️  Theme not set in .zshrc yet"
    echo "   You may need to set ZSH_THEME=\"chussenot\" in your .zshrc"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To use the theme:"
echo "  1. Set ZSH_THEME=\"chussenot\" in your .zshrc"
echo "  2. Reload your shell: source ~/.zshrc"
echo "  3. Or start a new terminal session"
echo ""
echo "The theme features:"
echo "  - Git/SVN/HG version control status"
echo "  - Virtual environment support"
echo "  - Exit code display"
echo "  - Timestamp information"
echo "  - Clean, colorful formatting"
