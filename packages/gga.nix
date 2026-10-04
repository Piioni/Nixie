{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  git,
  jq,
  curl,
  coreutils,
  findutils,
  gnugrep,
  gnused,
  gawk,
  procps,
  python3,
}:
stdenvNoCC.mkDerivation rec {
  pname = "gga";
  version = "2.10.1";

  src = fetchurl {
    url = "https://github.com/Gentleman-Programming/gentleman-guardian-angel/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-wdvO4SC4Mjjhx+zOSmD4imaBB5atlaI53rwJ6FCdD7o=";
  };

  sourceRoot = "gentleman-guardian-angel-${version}";
  dontBuild = true;
  doCheck = false;
  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace bin/gga \
      --replace-fail 'VERSION="''${GGA_VERSION:-dev}"' 'VERSION="${version}"' \
      --replace-fail 'LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"' "LIB_DIR=\"$out/libexec/gga/lib\""
    patchShebangs bin/gga
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/gga $out/bin/gga
    mkdir -p $out/libexec/gga
    cp -r lib $out/libexec/gga/lib
    wrapProgram $out/bin/gga --prefix PATH : "${
      lib.makeBinPath [
        git
        jq
        curl
        coreutils
        findutils
        gnugrep
        gnused
        gawk
        procps
        python3
      ]
    }"
    runHook postInstall
  '';

  meta = {
    description = "Gentleman Guardian Angel CLI";
    homepage = "https://github.com/Gentleman-Programming/gentleman-guardian-angel";
    license = lib.licenses.mit;
    mainProgram = "gga";
    platforms = [ "x86_64-linux" ];
  };
}
