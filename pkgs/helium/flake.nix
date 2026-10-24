{
  description = "Helium browser for NixOS (repackaged upstream release)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          helium = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.helium;
        }
      );

      overlays.default = final: _prev: {
        helium = final.callPackage ./package.nix { };
      };
    };
}
