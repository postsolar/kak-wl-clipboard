{ lib, stdenvNoCC, makeWrapper, wl-clipboard }:

stdenvNoCC.mkDerivation {
  pname = "kak-wl-clipboard";
  version = "v0.1.1";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    makeWrapper "$src/kak-wl-clipboard.sh" "$out/kak-wl-clipboard.sh" \
      --prefix PATH : ${ lib.makeBinPath [ wl-clipboard ] }
    cp -- "$src/kak-wl-clipboard.kak" "$out/"
    '';

  meta = with lib; {
    description = "wl-clipboard integration for Kakoune text editor";
    homepage = "https://github.com/postsolar/kak-wl-clipboard";
    license = licenses.mit;
    maintainers = with maintainers; [ postsolar ];
    platforms = platforms.linux;
  };
}

