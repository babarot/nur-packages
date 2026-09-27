# Every directory under ./pkgs is one package. GoReleaser writes
# pkgs/<name>/default.nix on each release of the tool.
{
  pkgs ? import <nixpkgs> { },
}:
let
  names = builtins.attrNames (
    pkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./pkgs)
  );
in
pkgs.lib.genAttrs names (name: pkgs.callPackage ./pkgs/${name} { })
