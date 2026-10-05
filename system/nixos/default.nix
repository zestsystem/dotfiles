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
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ (import ../shared/overlays.nix) ];

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

    programs.zsh.enable = true;
    programs.firefox.enable = true;
    users.users.${cfg.username} = {
      isNormalUser = true;
      home = "/home/${cfg.username}";
      extraGroups = [
        "wheel"
        "networkmanager"
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
        home.packages = (import ../shared/home-manager-packages.nix { inherit pkgs; }) ++ [ pkgs.codex ];
      };
    };
  };
}
