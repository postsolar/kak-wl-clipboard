{
  description = "wl-clipboard integration for Kakoune text editor";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let

      version = "v0.1";

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems
          (s: f nixpkgs.legacyPackages.${s});

      kak-wl-clipboard = pkgs: pkgs.callPackage ./default.nix {};

    in

    {

      packages = forAllSystems (pkgs: {
        kak-wl-clipboard = kak-wl-clipboard pkgs;
        default = kak-wl-clipboard pkgs;
      });

      defaultPackage = forAllSystems kak-wl-clipboard;

      devShell = forAllSystems (pkgs: pkgs.mkShell
        { buildInputs = [ pkgs.dash pkgs.wl-clipboard pkgs.kakoune ];
        }
      );

    };
}
