{
  description = "NixOS configuration for my machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          homeManager = inputs.home-manager;
        };
        modules = [ ./hosts/desktop/default.nix ];
      };

      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.nixd
          pkgs.nixfmt
        ];
      };
    };
}
