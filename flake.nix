{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        treefmt-nix.flakeModule
      ];

      perSystem = { pkgs, inputs', ... }: {
        packages.default = pkgs.callPackage ./nix {
          toolchain = inputs'.fenix.packages.stable.toolchain;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            inputs'.fenix.packages.stable.toolchain
            nix
            nixfmt
          ];
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs.rustfmt.enable = true;
          programs.nixfmt.enable = true;
        };
      };
    };
}
