{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "gentle-ai";
  version = "4.0.0";

  src = fetchurl {
    url = "https://github.com/Gentleman-Programming/gentle-ai/releases/download/v${version}/gentle-ai_${version}_linux_amd64.tar.gz";
    hash = "sha256-X0QXzynJachtpHmZQv1nM2iECQG+G7Ccd5oS1+1gluo=";
  };

  sourceRoot = ".";
  dontBuild = true;
  doCheck = false;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 gentle-ai $out/bin/gentle-ai
    install -Dm644 LICENSE $out/share/licenses/gentle-ai/LICENSE
    install -Dm644 README.md $out/share/doc/gentle-ai/README.md
    if [ -d contracts ]; then
      cp -r contracts $out/share/doc/gentle-ai/contracts
    fi
    runHook postInstall
  '';

  meta = {
    description = "Gentle AI command-line development harness";
    homepage = "https://github.com/Gentleman-Programming/gentle-ai";
    license = lib.licenses.mit;
    mainProgram = "gentle-ai";
    platforms = [ "x86_64-linux" ];
  };
}
