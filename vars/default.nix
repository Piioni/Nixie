{
  username = "piioni";
  userfullname = "Juan Rangel";
  useremail = "juanrangel@sipos.ai";
  # Authorized public keys only; leave empty until supplied, never add private keys.
  sshAuthorizedKeys = [ ];
  # Login password applied only when the user is first created; `passwd` owns it afterwards.
  # Generate with: nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt
  initialHashedPassword = "$y$j9T$ouCKPtieqeq503h2Ot36v/$oWEqsrqlkU.fTfLN4rufe2KTrXk3cTX6AMuPikDId84";
}
