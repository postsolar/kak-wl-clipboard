{ lib, stdenvNoCC, makeWrapper, wl-clipboard }:

stdenvNoCC.mkDerivation {
  pname = "kak-wl-clipboard";
  version = "v0.1";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    makeWrapper "$src/kak-wl-clipboard.sh" "$out/kak-wl-clipboard.sh" \
      --prefix PATH : ${ lib.makeBinPath [ wl-clipboard ] }
    cp -- "$src/kak-wl-clipboard.kak" "$out/"
    '';
}

