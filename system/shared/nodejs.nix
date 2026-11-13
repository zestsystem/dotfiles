# Security floor: use the channel's Node once it reaches 22.23.4, else the pinned patched build.
{ inputs, pkgs }:
let
  channelNode = pkgs.nodejs_22;
in
if pkgs.lib.versionAtLeast channelNode.version "22.23.4" then
  channelNode
else
  inputs.nixpkgs-node.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nodejs_22
