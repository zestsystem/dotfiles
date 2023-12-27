{
  description = "Development packages and systems for Zestsystem";

  inputs = {
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }: let
    git = {
      extraConfig.github.user = username;
      userEmail = "mk337337@gmail.com";
      username = "mikeyim";
    };
    username = "zestsystem";
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        darwinConfigurations = {
          zestsystem = self.lib.mkDarwin {
            inherit git username;
            system = "aarch64-darwin";
          };
        };

        lib = import ./lib {inherit inputs;};

        nixosConfigurations = {
          zestsystem = self.lib.mkNixOS {
            inherit git username;
            system = "x86_64-linux";
          };
        };
      };

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [just];
          };
        };

        packages = {
          zestsystem-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "Zestsystem";
            src = ./config/nvim;
          };
        };
      };
    };
}
