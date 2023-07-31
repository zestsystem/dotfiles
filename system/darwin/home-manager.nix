{inputs}: {pkgs, ...}: let
  shared-config = import ../shared/home-manager.nix {inherit inputs;};
  shared-packages = import ../shared/home-manager-packages.nix {inherit pkgs;};
in {
  imports = [shared-config];

  home.packages = shared-packages;
}
