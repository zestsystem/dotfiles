{ inputs }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zestsystem;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.zestsystem.username = lib.mkOption {
    type = lib.types.str;
    default = "mikeyim";
    description = "Existing login account that receives the shared dotfiles.";
  };

  config = {
    # Keep disks, bootloader, stateVersion, and hardware in the installer config.
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Same binary cache and trust as the Mac, so direnv/devshells can use caches.
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;
    };
    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 14d";
    };
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (import ../shared/overlays.nix)
      inputs.claude-desktop.overlays.default
    ];

    networking.networkmanager.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    services.fwupd.enable = lib.mkDefault true;
    services.libinput.enable = lib.mkDefault true;
    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.displayManager.gdm.enable = lib.mkDefault true;
    services.desktopManager.gnome.enable = lib.mkDefault true;
    security.rtkit.enable = lib.mkDefault true;
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };

    # Dev environment
    # Run prebuilt dynamically linked binaries (npm/pip downloads, language servers, CLI installers).
    programs.nix-ld.enable = lib.mkDefault true;
    virtualisation.docker.enable = lib.mkDefault true;
    # KVM for Claude Desktop Cowork and local VMs.
    virtualisation.libvirtd.enable = lib.mkDefault true;
    programs.virt-manager.enable = lib.mkDefault true;
    fonts.packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
    ];

    programs.zsh.enable = true;
    programs.firefox.enable = true;
    users.users.${cfg.username} = {
      isNormalUser = true;
      home = "/home/${cfg.username}";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "libvirtd"
        "kvm"
      ];
      shell = pkgs.zsh;
    };
    environment.systemPackages = [
      (import ../shared/tmux-sessionizer.nix { inherit pkgs; })
      pkgs.nixfmt
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.${cfg.username} = {
        imports = [ (import ../shared/home-manager.nix { inherit inputs; }) ];
        home.packages =
          (import ../shared/home-manager-packages.nix {
            inherit pkgs;
            nodejs = import ../shared/nodejs.nix { inherit inputs pkgs; };
          })
          ++ [
            pkgs.codex
            # Agent tooling available right after the first switch.
            pkgs.claude-code
            pkgs.claude-desktop-fhs
            pkgs.google-chrome # Claude in Chrome extension
            pkgs.chromium
            pkgs.docker-compose
            pkgs.git-lfs
            pkgs.wl-clipboard
            pkgs.xclip
            pkgs.gnumake
            pkgs.gcc
            pkgs.unzip
          ];
      };
    };
  };
}
