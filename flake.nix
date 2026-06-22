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

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, inputs', ... }:
        let
          inherit (inputs'.fenix.packages.stable) toolchain;
          inherit (inputs'.nix2container.packages) nix2container;

          patchpad = (pkgs.callPackage ./nix { inherit toolchain; }).overrideAttrs (old: {
            passthru = (old.passthru or { }) // {
              container = pkgs.callPackage ./nix/container.nix {
                inherit nix2container patchpad;
              };
            };
          });
        in
        {
          packages = {
            inherit patchpad;
            default = patchpad;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nix
              nixfmt
              podman
              skopeo
              toolchain
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
