# dotfiles

My personal dotfiles managed with Nix Home Manager.

## Structure

- `hosts/` — Host-specific configurations
- `features/` — Optional Home Manager features
- `programs/` — Shared program configurations
- `pkgs/` — Custom Nix packages

## Notes

This repository is primarily intended for personal use and depends on a
separate private configuration repository. Application-specific configuration
and runtime code are maintained in the private repository under `apps/`.
