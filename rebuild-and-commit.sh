#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles/nixos"

echo "Navigating to $DOTFILES_DIR..."
pushd "$DOTFILES_DIR"

echo "Formatting Nix files..."
alejandra . &>> "$DOTFILES_DIR/nixos-switch.log" || true

echo "Checking for changes..."
if git diff --quiet; then
  echo "No changes detected."
else
  echo "Rebuilding NixOS..."
  if sudo nixos-rebuild switch --flake "$DOTFILES_DIR" | tee -a "$DOTFILES_DIR/nixos-switch.log"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Rebuild successful." >> "$DOTFILES_DIR/nixos-switch.log"
    echo "Committing changes..."
    gen=$(sudo nixos-rebuild list-generations | grep current | cut -d' ' -f2-)
    git add -A
    git commit -m "Rebuild at generation: $gen"
    git push
    echo "Commit successful. Generation: $gen"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Rebuild failed." >> "$DOTFILES_DIR/nixos-switch.log"
    cat "$DOTFILES_DIR/nixos-switch.log" | grep --color=always -i error
    exit 1
  fi
fi

popd