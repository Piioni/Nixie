{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "moshi-hook";
  version = "0.4.17";

  src = fetchurl {
    url = "https://cdn.getmoshi.app/hook/v${version}/moshi-hook_Linux_x86_64.tar.gz";
    hash = "sha256-EMZXrS6E7ahWMt+jyMhbAKUUXjEsYHwDuAgt7j7O5hQ=";
  };

  sourceRoot = ".";
  dontBuild = true;
  doCheck = false;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 moshi-hook $out/bin/moshi-hook
    ln -s moshi-hook $out/bin/moshi
    if [ -f README.md ]; then
      install -Dm644 README.md $out/share/doc/moshi-hook/README.md
    fi
    if [ -d docs ]; then
      cp -r docs $out/share/doc/moshi-hook/docs
    fi
    runHook postInstall
  '';

  meta = {
    description = "Moshi desktop and agent integration hook";
    homepage = "https://getmoshi.app/";
    license = lib.licenses.unfree;
    mainProgram = "moshi-hook";
    platforms = [ "x86_64-linux" ];
  };
}
