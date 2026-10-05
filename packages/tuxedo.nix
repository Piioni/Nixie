{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "tuxedo";
  version = "2026.8.1";

  src = fetchFromGitHub {
    owner = "webstonehq";
    repo = "tuxedo";
    rev = "69db0a14a72323c19b4b671f8abe32c0c34bdea1";
    hash = "sha256-jF3K8osnK+NHtCV4zOTo1Ft1mPB/z7+ealajo9L4w2k=";
  };

  cargoHash = "sha256-UpSIqUA+mJe31m2Oo6P1ZXvV9+fi90fUYg7OWWts2Js=";
  doCheck = false;

  meta = {
    description = "Terminal todo.txt manager";
    homepage = "https://github.com/webstonehq/tuxedo";
    mainProgram = "tuxedo";
    platforms = lib.platforms.linux;
  };
}
