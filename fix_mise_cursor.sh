#!/bin/zsh

# Remove broken Cursor shim
echo "Removing broken Cursor shim..."
mise uninstall cursor 2>/dev/null || true

# Clean up mise
echo "Cleaning up mise..."
mise cleanup

# Reset mise configuration
echo "Resetting mise configuration..."
mise reset

# Reinstall Cursor properly
echo "Reinstalling Cursor..."
# Note: Replace this with your actual Cursor installation command


echo "Mise and Cursor fixes applied. Please restart your shell." 