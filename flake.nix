{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spotx-nix = {
      url = "github:SpotX-Official/SpotX-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minegrub-world-sel-theme = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      minegrub-world-sel-theme,
      nix-index-database,
      nix-flatpak,
      niri,
      treefmt-nix,
      git-hooks,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlay-unstable = _final: _prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      overlay-local = final: _prev: {
        helium = final.callPackage ./pkgs/helium/package.nix { };
        syncthing = final.callPackage ./pkgs/syncthing/package.nix { };
      };

      # tooling for working on this repo
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      pre-commit = git-hooks.lib.${system}.run {
        src = ./.;
        hooks.treefmt = {
          enable = true;
          package = treefmtEval.config.build.wrapper;
        };
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = [
              overlay-unstable
              overlay-local
              inputs.spotx-nix.overlays.default
            ];
          }
          niri.nixosModules.niri

          ./configuration.nix
          minegrub-world-sel-theme.nixosModules.default
          nix-index-database.nixosModules.nix-index
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "bak";
            home-manager.useUserPackages = true;
            home-manager.users."yon" = import ./home.nix;
          }
        ];
      };

      # expose custom packages so `nix-update --flake helium` and `nix-update --flake syncthing` work
      packages.${system} = {
        helium = pkgs.callPackage ./pkgs/helium/package.nix { };
        syncthing = pkgs.callPackage ./pkgs/syncthing/package.nix { };
      };

      # nix fmt formats the whole repo, nix flake check verifies formatting
      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system}.formatting = treefmtEval.config.build.check self;

      # nix develop (or direnv) in this repo: formatter, linters, store tools
      devShells.${system}.default = pkgs.mkShell {
        inherit (pre-commit) shellHook;
        packages = [
          treefmtEval.config.build.wrapper
          pkgs.statix
          pkgs.deadnix
          pkgs.nixfmt
          pkgs.nix-update
          pkgs.nix-tree
          pkgs.nix-du
          pkgs.nix-melt
          pkgs.cachix
        ];
      };

      # `nix flake init -t ~/homenix#rust` in an empty project directory
      templates.rust = {
        path = ./templates/rust;
        description = "Rust project: rust-overlay + crane + treefmt-nix + git-hooks";
        welcomeText = ''
          rust template created wuw!!
          newxt: git init, cargo init, git add -A, then direnv allow (or nix develop)!!
          seeww docs/rust-nix-guide.md in homenix repo for the full workflow >,<!!
          goowd luwk cutie!!! <3
        '';
      };
    };
}
