{
  description = "wl-clipboard integration for Kakoune text editor";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems
          (system: f nixpkgs.legacyPackages.${system});

      kak-wl-clipboard = pkgs: pkgs.callPackage ./default.nix {};

    in
      {
        packages = forAllSystems (pkgs: {
          kak-wl-clipboard = kak-wl-clipboard pkgs;
          default = kak-wl-clipboard pkgs;
        });

        devShell = forAllSystems (pkgs: pkgs.mkShell {
          buildInputs = [ pkgs.dash pkgs.wl-clipboard pkgs.kakoune ];
        });

        overlays.default = final: prev: {
          kakounePlugins = prev.kakounePlugins // {
            kak-wl-clipboard = prev.callPackage ./default.nix {};
          };
        };
      };
}
