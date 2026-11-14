{ inputs }:
{ pkgs, ... }:
let
  shared-config = import ../shared/home-manager.nix { inherit inputs; };
  nodejs = import ../shared/nodejs.nix { inherit inputs pkgs; };
  shared-packages = import ../shared/home-manager-packages.nix { inherit pkgs nodejs; };
in
{
  imports = [ shared-config ];

  home.packages = shared-packages;
}
