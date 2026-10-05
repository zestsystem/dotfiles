{
  description = "ThinkPad X1 Carbon with Zestsystem dotfiles";
  inputs.dotfiles.url = "github:zestsystem/dotfiles";
  inputs.nixpkgs.follows = "dotfiles/nixpkgs";

  outputs =
    { nixpkgs, dotfiles, ... }:
    {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Preserve the installer's hardware import, bootloader, and stateVersion.
          ./configuration.nix
          dotfiles.nixosModules.default
          {
            # Must match the account you created in the graphical installer.
            zestsystem.username = "mikeyim";
          }
        ];
      };
    };
}
