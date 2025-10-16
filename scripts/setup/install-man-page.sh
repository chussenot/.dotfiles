#!/bin/bash
# Install man page for keymaps function

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MAN_SOURCE="$DOTFILES_DIR/man/man1/keymaps.1"
MAN_DEST="$HOME/.local/share/man/man1/keymaps.1"

echo "📖 Installing keymaps man page..."

# Create man directory if it doesn't exist
mkdir -p "$HOME/.local/share/man/man1"

# Copy man page
if [ -f "$MAN_SOURCE" ]; then
    cp "$MAN_SOURCE" "$MAN_DEST"
    echo "✅ Man page copied to $MAN_DEST"
else
    echo "❌ Source man page not found: $MAN_SOURCE"
    exit 1
fi

# Update man database
if command -v mandb >/dev/null 2>&1; then
    mandb -q
    echo "✅ Man database updated"
else
    echo "⚠️  mandb not found, man page may not be immediately searchable"
fi

# Add to MANPATH if not already present
if ! echo "$MANPATH" | grep -q "$HOME/.local/share/man"; then
    echo "export MANPATH=\"\$HOME/.local/share/man:\$MANPATH\"" >> "$HOME/.zshrc"
    echo "✅ Added ~/.local/share/man to MANPATH in .zshrc"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Usage:"
echo "  man keymaps    # View the manual page"
echo ""
echo "The man page is now available system-wide."
