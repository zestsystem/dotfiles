{inputs}: let
  home-manager = import ./shared/home-manager.nix {inherit inputs;};
  home-manager-desktop = import ./nixos/home-manager-desktop.nix;
in {
  mkDarwin = {
    git ? {},
    system,
    username,
  }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      modules = [
        (import ./darwin/configuration.nix {inherit username;})

        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {pkgs, ...}: {
            imports = [(home-manager {inherit git;})];
          };
        }
      ];
    };

  mkNixos = {
    desktop ? true,
    git ? {},
    hypervisor ? "vmware",
    system,
    username,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (import ./nixos/hardware/${hypervisor}/${system}.nix)
        (import ./nixos/configuration.nix {inherit inputs desktop username;})
        (import ./nixos/configuration-desktop.nix {inherit username;})

        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = {pkgs, ...}: {
            imports = [
              (home-manager {inherit git;})
              (home-manager-desktop {inherit pkgs;})
            ];
          };
        }
      ];
    };
}