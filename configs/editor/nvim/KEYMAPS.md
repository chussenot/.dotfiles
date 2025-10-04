# Vim/NeoVim Key Mappings

This document provides a comprehensive overview of all key mappings in your Vim/NeoVim configuration.

## General Navigation

| Key | Action |
|-----|--------|
| `j` | Move down (linewrap-aware) |
| `k` | Move up (linewrap-aware) |

## Tab Navigation

| Key | Action |
|-----|--------|
| `<C-Left>` | Previous tab |
| `<C-Right>` | Next tab |

## Selection

| Key | Action |
|-----|--------|
| `gV` | Visually select last edited/pasted text |
| `gp` | Select last pasted text |
| `<C-k>` | Move line up |
| `<C-j>` | Move line down |
| `<C-Up>` (visual) | Move selection up |
| `<C-Down>` (visual) | Move selection down |

## Folding

| Key | Action |
|-----|--------|
| `<F8>` | Toggle fold |
| `<S-F8>` | Toggle fold recursively |
| `<C-F8>` | Open all folds |
| `<C-S-F8>` | Close all folds |

## Column Markers

| Key | Action |
|-----|--------|
| `<F10>` | Toggle column highlighting |

## Surroundings (Visual Mode)

| Key | Action |
|-----|--------|
| `(` | Surround with parentheses |
| `{` | Surround with braces |
| `[` | Surround with brackets |
| `'` | Surround with single quotes |
| `"` | Surround with double quotes |

## Configuration

| Key | Action |
|-----|--------|
| `<C-R>` | Reload configuration |
| `<C-F11>` | Toggle relative line numbering |

## Plugin Mappings

### NERDTree

| Key | Action |
|-----|--------|
| `<C-T>` | Toggle NERDTree |

### EasyBuffer

| Key | Action |
|-----|--------|
| `<F2>` | Toggle EasyBuffer |

### Undotree

| Key | Action |
|-----|--------|
| `<F6>` | Toggle Undotree |

### TComment

| Key | Action |
|-----|--------|
| `//` | Toggle comment |

### GitGutter

| Key | Action |
|-----|--------|
| `gh` | Next hunk |
| `gH` | Previous hunk |

### Open Browser

| Key | Action |
|-----|--------|
| `gx` | Smart search |

## Terminal Mode (NeoVim)

| Key | Action |
|-----|--------|
| `<Esc>` | Switch to normal mode |
| `<C-v><Esc>` | Insert literal Escape |

## Notes

- All mappings are organized by category for easy reference
- Some mappings are specific to NeoVim and will not work in regular Vim
- GUI-specific mappings only work when running in GUI mode
- Plugin mappings require the respective plugins to be installed and loaded
