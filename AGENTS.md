# AGENTS.md - Agent Instructions for Dotfiles Repository

## Repository Structure

This repository contains two distinct NixOS configurations plus supporting files:

### 1. **`nixos/`** - Single Desktop Machine Configuration
- **Hostname**: `tank`
- **Purpose**: Personal workstation (gaming, development, media)
- **Flake**: `nixos/flake.nix` (single machine, uses nixinate for deployment)
- **Key files**: `configuration.nix`, `hardware-configuration.nix`, `penis.nix`
- **Quick rebuild**: Use `rebuild-and-commit.sh` script at root

### 2. **`PJB-NixOS-Configuration/`** - Multi-Machine Infrastructure
- **Purpose**: Complete infrastructure with 19+ machines, VPN, secrets management
- **Flake**: `PJB-NixOS-Configuration/flake.nix` (complex multi-machine setup)
- **Existing AGENTS.md**: `PJB-NixOS-Configuration/AGENTS.md` contains detailed instructions
- **Read that file first** for any work within that subdirectory

### 3. **`nixos-config/`** - Legacy/Home-Manager Configuration
- Appears to be an older configuration using home-manager
- Likely deprecated; avoid unless specifically working on legacy setup

## Essential Commands

### For `nixos/` Configuration
```bash
# Quick rebuild with auto-commit (recommended)
./rebuild-and-commit.sh

# Manual rebuild steps
cd nixos
nix fmt .                    # Format Nix files (REQUIRED before commit)
nix flake check              # Validate flake
nixos-rebuild build --flake .  # Build without installing
sudo nixos-rebuild switch --flake .  # Install and activate
```

### For `PJB-NixOS-Configuration/` Configuration
```bash
cd PJB-NixOS-Configuration
nix fmt                      # Format Nix files (REQUIRED)
nix flake check              # Validate flake + linters
nix run .#<hostname>         # Deploy to specific machine
nix run .#deploy-all         # Deploy to all whitelisted hosts
```

## Key Architecture Notes

### `nixos/` Configuration Details
- **Single machine** configuration (x86_64-linux only)
- Uses **nixinate** for remote deployment (IP: 192.168.88.0)
- **Gaming-focused**: Steam, RSI Launcher, Sunshine streaming, NVIDIA drivers
- **Desktop environment**: Plasma 6 (X11 session)
- **Audio**: PipeWire with custom JBL headset configuration
- **Networking**: Tailscale VPN, custom hosts entries for Epic Games

### `PJB-NixOS-Configuration/` Architecture
- **Multi-machine infrastructure** with WireGuard VPN mesh
- **Secrets management**: Uses secrix (RAGE encryption)
- **19 machines**: Mix of x86_64 and ARM (aarch64)
- **Deployment**: All via VPN (10.88.127.0/24 subnet)
- **SSH**: Custom port 1108, dedicated `deploy` user

## Important Gotchas

### Cross-Configuration Confusion
- **These are separate systems** - don't mix commands or configurations
- `nixos/` is for local desktop, `PJB-NixOS-Configuration/` is for infrastructure
- Each has its own flake.lock, secrets, and deployment methods

### `rebuild-and-commit.sh` Script
- **Located at repository root** (`/home/tank/dotfiles/rebuild-and-commit.sh`)
- **Only works for `nixos/` configuration** (hardcoded path)
- Auto-formats with `alejandra`, rebuilds, commits, and pushes
- Logs to `nixos/nixos-switch.log`

### Nix Formatting
- **Required before commit** in both configurations
- `nixos/` uses `nix fmt` (configured as `nixpkgs-fmt`)
- `PJB-NixOS-Configuration/` also uses `nix fmt`
- Pre-commit hooks may enforce formatting

### Deployment Constraints
- **VPN required** for `PJB-NixOS-Configuration/` deployments
- **Local build** for `nixos/` (no remote deployment configured)
- **Test first**: Always test with `nix run .#<hostname>` before permanent switch

### Secrets Handling
- **Never commit decrypted secrets** - use secrix in `PJB-NixOS-Configuration/`
- **Public keys safe to commit** - found in `secrets/public_keys/`
- **Hardware configs auto-generated** - don't edit `hardware-configuration.nix` manually

## File Organization Patterns

### `nixos/` Structure
```
nixos/
├── configuration.nix          # Main system config
├── hardware-configuration.nix # Auto-generated hardware
├── flake.nix                  # Flake definition
├── penis.nix                  # Additional config
├── nix-citizen-module.nix     # Star Citizen module
├── nix-citizen-overlay.nix    # Package overlays
├── pkgs/                      # Custom packages
│   ├── lug-helper/
│   ├── rsi-launcher/
│   └── wine-astral/
└── nix-citizen-modules/       # Additional modules
```

### `PJB-NixOS-Configuration/` Structure
```
PJB-NixOS-Configuration/
├── flake.nix                  # Main flake with 19 machines
├── machines/                  # Machine configurations
├── environments/              # Software stacks
├── services/                  # Service configurations
├── server_services/           # Server-specific services
├── modifier_imports/          # System modifiers
├── lib/                       # Shared utilities
├── modules/enable-wg.nix      # WireGuard VPN module
├── secrets/                   # Encrypted secrets
├── locale/                    # Network/locale configs
└── documentation/             # Reference docs
```

## Common Tasks

### Add Package to `nixos/`
1. Edit `nixos/configuration.nix`
2. Add to `environment.systemPackages`
3. Test: `cd nixos && nixos-rebuild build --flake .`

### Add Machine to `PJB-NixOS-Configuration/`
1. See `PJB-NixOS-Configuration/AGENTS.md` for detailed steps
2. **Key steps**: Create machine config, generate keys, update `lib/wg_peers.nix`

### Update Flakes
```bash
# For nixos/
cd nixos && nix flake update

# For PJB-NixOS-Configuration/
cd PJB-NixOS-Configuration && nix flake update
```

## Troubleshooting

### Build Failures
```bash
nix flake check          # Check for syntax errors
nix log <derivation>     # View build logs
nix repl                 # Interactive evaluation
```

### Deployment Issues (`PJB-NixOS-Configuration/`)
```bash
ssh -p 1108 deploy@10.88.127.X  # Test SSH connectivity
nix run .#<hostname>            # Test deployment
```

## References
- **`PJB-NixOS-Configuration/AGENTS.md`**: Comprehensive instructions for multi-machine setup
- **`nixos/flake.nix`**: Single machine configuration entry point
- **`rebuild-and-commit.sh`**: Automated rebuild script for desktop