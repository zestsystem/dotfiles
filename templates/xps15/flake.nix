{
  description = "Dell XPS 15 9560 with Zestsystem dotfiles";
  inputs.dotfiles.url = "github:zestsystem/dotfiles";
  inputs.nixpkgs.follows = "dotfiles/nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs =
    {
      nixpkgs,
      dotfiles,
      nixos-hardware,
      ...
    }:
    {
      nixosConfigurations.xps15 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Preserve the installer's hardware import, bootloader, and stateVersion.
          ./configuration.nix
          # Intel iGPU only: GTX 1050 powered off for battery and a simple Wayland session.
          # Swap for nixos-hardware.nixosModules.dell-xps-15-9560 to get PRIME offload.
          nixos-hardware.nixosModules.dell-xps-15-9560-intel
          dotfiles.nixosModules.default
          {
            # Must match the account you created in the graphical installer.
            zestsystem.username = "mikeyim";
          }
        ];
      };
    };
}
