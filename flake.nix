{
  description = "NixOS configuration for my machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser/31b2af977177d347db89d69fac4fe5c44b852007";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "piioni";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit username;
          helium = inputs.helium;
          homeManager = inputs.home-manager;
        };
        modules = [ ./hosts/desktop/default.nix ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit username;
          helium = inputs.helium;
          homeManager = inputs.home-manager;
        };
        modules = [ ./hosts/laptop/default.nix ];
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
