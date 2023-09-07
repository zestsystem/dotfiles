{
  description = "Development packages and systems for Zestsystem";

  inputs = {
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = inputs @ {flake-parts, ...}: let
    systems = import ./system {inherit inputs;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages = {
            goofysystem-nvim = pkgs.vimUtils.buildVimPlugin {
                name = "Goofysystem";
                src = ./config/nvim;
            };
        };
      };

      flake = {
        darwinConfigurations = {
          work-darwin = systems.mkDarwin {
            system = "aarch64-darwin";
            username = "mikeyim";
          };
        };
      };
    };
}
