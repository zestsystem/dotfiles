{ inputs }:

{ system, username }:

let
  configuration = import ./configuration.nix { inherit username; };
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  modules = [
    configuration
    inputs.mac-app-util.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = import ./home-manager.nix {
        inherit inputs;
      };
      home-manager.sharedModules = [
        inputs.mac-app-util.homeManagerModules.default
      ];
    }
  ];
}
