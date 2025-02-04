{username}: {pkgs, ...}: let
  shared-overlays = import ../shared/overlays.nix;
  tmux-sessionizer = import ../shared/tmux-sessionizer.nix {inherit pkgs;};
in {
  nix = {
    settings = {
      auto-optimise-store = false;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["@wheel"];
      warn-dirty = false;
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    config.allowUnsupportedSystem = true;
    config.allowBroken = true;
    overlays = [shared-overlays];
  };

  environment.systemPackages = [tmux-sessionizer pkgs.nixfmt-rfc-style];

  programs = {
    zsh.enable = true;
  };

  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  users.users.${username}.home = "/Users/${username}";
}
