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

  outputs = inputs@{ flake-parts, self, ... }:
    let
      systems = import ./system { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          zestsystem-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "Zestsystem";
            src = ./config/nvim;
          };
        };
      };

      flake = {
        darwinConfigurations = {
          work-darwin = systems.mkDarwin {
            system = "aarch64-darwin";
            username = "zestsystem";
          };
        };

      };
    };
}
