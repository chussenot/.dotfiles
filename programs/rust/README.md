# Rust programs

This workspace is for Rust helpers that support the dotfiles repository.

## Programs

- `chussenot-theme` — collects prompt metadata for the `chussenot` zsh theme and prints shell-neutral `key=value` lines.

## Usage

Run from the workspace root:

```sh
cargo run -p chussenot-theme
```

Or from anywhere:

```sh
cargo run -p chussenot-theme --manifest-path /home/runner/work/.dotfiles/.dotfiles/chussenot/.dotfiles/programs/rust/Cargo.toml
```
