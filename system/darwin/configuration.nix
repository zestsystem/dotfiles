{ system, username }:
{ pkgs, ... }:
let
  shared-overlays = import ../shared/overlays.nix;
  tmux-sessionizer = import ../shared/tmux-sessionizer.nix { inherit pkgs; };
in
{
  nix = {
    package = pkgs.lix;
    settings = {
      auto-optimise-store = false;
      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      ssl-cert-file = "/etc/ssl/cert.pem";
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "@admin"
        "@wheel"
        username
      ];
      warn-dirty = false;
    };
    enable = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    config.allowUnsupportedSystem = true;
    config.allowBroken = true;
    hostPlatform = system;
    overlays = [ shared-overlays ];
  };

  environment.systemPackages = [
    tmux-sessionizer
    pkgs.nixfmt-rfc-style
  ];

  environment.etc = {
    "nix/nix.conf".knownSha256Hashes = [
      "daa9d824601c088f52de3da176e14328ba41e7be3eb450fdf8b93c86f236f722"
    ];
    bashrc.knownSha256Hashes = [
      "4e8f7aa087f0955fb6012fe07bfa2bdb770225f16f0ab4fe71a21f0f0f311d3a"
    ];
    zshrc.knownSha256Hashes = [
      "946d120e490c6aa89a8a07ab80ecfc8717336e4edcc8741f939fb6606d553239"
    ];
    "ssl/certs/ca-certificates.crt".knownSha256Hashes = [
      "9dae8d76e55cb08991f2b672d58999ea15560d910759c16b544f843bdffbb994"
    ];
  };

  programs = {
    zsh.enable = true;
  };

  ids.gids.nixbld = 350;

  system.stateVersion = 4;

  users.users.${username}.home = "/Users/${username}";
}
