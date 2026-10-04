{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "engram";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/Gentleman-Programming/engram/releases/download/v${version}/engram_${version}_linux_amd64.tar.gz";
    hash = "sha256-Irv9ge6QcaBNRG9lOELDg6MQG1lOiClRmmOnx0dgLmk=";
  };

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/Gentleman-Programming/engram/v${version}/LICENSE";
    hash = "sha256-CWCFl93aTl+QM6xAeg1AGYbZY3bEf21GeJyjjbZy3BU=";
  };

  sourceRoot = ".";
  dontBuild = true;
  doCheck = false;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 engram $out/bin/engram
    install -Dm644 "$licenseFile" $out/share/licenses/engram/LICENSE
    if [ -d tools ]; then
      mkdir -p $out/share/engram/tools
      cp -r tools/. $out/share/engram/tools/
    fi
    runHook postInstall
  '';

  meta = {
    description = "Engram CLI and agent memory tool";
    homepage = "https://github.com/Gentleman-Programming/engram";
    license = lib.licenses.mit;
    mainProgram = "engram";
    platforms = [ "x86_64-linux" ];
  };
}
