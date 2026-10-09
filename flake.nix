{
  description = "babarot's Nix packages, from the prebuilt binaries of each release";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: import ./default.nix { inherit pkgs; });
      overlays.default = final: _prev: import ./default.nix { pkgs = final; };
      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
