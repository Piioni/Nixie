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

  inputs.nixvim = {
    url = "github:nix-community/nixvim/167da56c3ab1e51751a6ae4a997ed66587f9edae";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./vars;
      inherit (vars) username userfullname useremail;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit username userfullname useremail;
          helium = inputs.helium;
          homeManager = inputs.home-manager;
          nixvim = inputs.nixvim;
        };
        modules = [ ./hosts/desktop/default.nix ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit username userfullname useremail;
          helium = inputs.helium;
          homeManager = inputs.home-manager;
          nixvim = inputs.nixvim;
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
