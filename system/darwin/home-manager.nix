{ inputs }:
{ pkgs, ... }:
let
  shared-config = import ../shared/home-manager.nix { inherit inputs; };
  channelNode = pkgs.nodejs_22;
  # Security floor: use the channel's Node once it reaches 22.23.4, else the pinned patched build.
  nodejs =
    if pkgs.lib.versionAtLeast channelNode.version "22.23.4" then
      channelNode
    else
      inputs.nixpkgs-node.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nodejs_22;
  shared-packages = import ../shared/home-manager-packages.nix { inherit pkgs nodejs; };
in
{
  imports = [ shared-config ];

  home.packages = shared-packages;
}
