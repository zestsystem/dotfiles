# Nix dotfiles: macOS and NixOS

This flake supports the existing Apple Silicon Mac (`work-darwin`) and exports
`nixosModules.default` for an Intel/AMD NixOS laptop. Both use the shared Home
Manager settings for Zsh, Git, Neovim, tmux, Kitty, direnv, and developer packages
(Node.js, Bun, Go, Doppler, GitHub CLI, jq, ripgrep, ffmpeg, and more).

macOS keeps its nix-darwin and mac-app-util integration, including the Codex app
CLI alias. Linux installs the Nixpkgs Codex CLI and Firefox. The NixOS module
also defaults to GNOME, NetworkManager, PipeWire audio, Bluetooth, firmware
updates, touchpad support, and power profiles. It does not install macOS apps
on Linux. MySQL is a client/package here; no database service is enabled.

## macOS

From this checkout:

```sh
just darwin work switch
```

## ThinkPad X1 Carbon: first setup

1. Install NixOS using the graphical USB installer. Choose **GNOME** and create
   your normal user (the example below uses `mikeyim`). Reboot into the installed
   system and log in. Set your password through the installer; this repo contains
   no passwords or private keys.
2. Keep `/etc/nixos/configuration.nix` and `hardware-configuration.nix` from that
   installation. They own your actual disk UUIDs, encryption, bootloader,
   CPU/kernel settings, timezone, and `system.stateVersion`. Do not replace them
   with another machine's files or change stateVersion to match a new release.
3. Clone the dotfiles, then make the portable Claude configuration available
   where Home Manager expects it:

   ```sh
   nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git
   git clone https://github.com/zestsystem/dotfiles.git ~/dotfiles
   mkdir -p ~/.config
   ln -s ~/dotfiles/claude-code ~/.config/claude-code
   ```

   If `~/.config/claude-code` already exists, reconcile it with the checkout
   instead of replacing it. Your checkout can also live at `~/.config` as on the
   Mac, but there is no need to move existing desktop application settings.

4. Back up `/etc/nixos`, then copy `templates/thinkpad/flake.nix` from this repo
   into `/etc/nixos/flake.nix`. The template imports the existing installer
   configuration and the shared module; it does not repartition anything.
   If `/etc/nixos/flake.nix` already exists, integrate these inputs/modules into
   it instead of overwriting it. Change `zestsystem.username` in the template to
   match the account you created.
5. Build before activating:

   ```sh
   sudo env NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild build --flake /etc/nixos#thinkpad
   sudo env NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake /etc/nixos#thinkpad
   ```

   Both bootstrap commands enable flakes explicitly: building alone does not
   activate the new Nix settings. Home Manager backs up managed files with `.backup`;
   resolve any existing backup-name collisions before retrying activation.

The template fetches the published `main` branch. Until this change is merged,
set its `inputs.dotfiles.url` to a local checkout containing the change, e.g.
`path:/home/mikeyim/dotfiles`, or a published feature branch. A path input is
snapshotted in the Nix store; refresh its lock after editing that checkout.

## Updates

The ThinkPad's `/etc/nixos/flake.lock` pins both dotfiles and software versions.
Pulling your shell checkout alone does not update that system lock:

```sh
cd /etc/nixos
sudo nix flake update dotfiles
sudo nixos-rebuild build --flake .#thinkpad
sudo nixos-rebuild switch --flake .#thinkpad
```

From the dotfiles checkout, `just nixos` also switches `/etc/nixos#thinkpad`.
Package versions remain pinned by the dotfiles' own `flake.lock`; updating its
Nixpkgs input is a separate reviewed change.

## Customizing the laptop

Add machine-specific options to `/etc/nixos/configuration.nix`. For another
desktop, explicitly set `services.desktopManager.gnome.enable = false` and
`services.displayManager.gdm.enable = false` before enabling its replacement.
The X1 Carbon generation is still needed before selecting any optional
model-specific hardware module. Hardware acceleration, Wi-Fi, suspend, audio,
and battery behavior must be checked on the actual laptop.

Secrets and service logins are separate: authenticate Doppler/GitHub/Codex on the
laptop as needed. `just secrets` is opt-in and retrieves your existing Doppler
configuration; rebuilding alone does not download secrets.

Linux receives generated Claude settings with the macOS sound and checkout
auto-sync hooks removed (the secret-read guard remains). Edit their source in
`claude-code/settings.json` and rebuild to update them. macOS retains its writable
settings symlink and existing hooks.
