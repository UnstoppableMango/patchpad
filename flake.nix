{
  nixConfig = {
    extra-substituters = [
      "https://mangopkgs.cachix.org"
    ];
    extra-trusted-public-keys = [
      "mangopkgs.cachix.org-1:uJ5FgSbOg1uiXLcL0gBh1lO+y3KVuthy6UeOFYR1fLk="
    ];
  };

  inputs = {
    # nixpkgs and nix2container follow mangopkgs so that skopeo-nix2container,
    # which `container.copyTo` pulls in, resolves to the store path mangopkgs
    # builds and pushes to its cachix cache. Pinning them independently means
    # rebuilding skopeo from source.
    mangopkgs.url = "github:unmango/pkgs";
    nixpkgs.follows = "mangopkgs/nixpkgs";
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

    nix2container.follows = "mangopkgs/nix2container";
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
