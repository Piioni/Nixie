{
  description = "NixOS configuration for my machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nix-gaming = {
    url = "github:fufexan/nix-gaming";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser/31b2af977177d347db89d69fac4fe5c44b852007";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixvim = {
    url = "github:nix-community/nixvim/bcb5f577a36565bda07d7b81346b73cad8618d16";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.noctalia-protonvpn = {
    url = "github:GMkonan/noctalia-protonvpn";
    flake = false;
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./vars;
      inherit (vars)
        username
        userfullname
        useremail
        sshAuthorizedKeys
        initialHashedPassword
        ;
      pkgs = nixpkgs.legacyPackages.${system};
      specialArgs = {
        inherit
          username
          userfullname
          useremail
          sshAuthorizedKeys
          initialHashedPassword
          ;
        helium = inputs.helium;
        homeManager = inputs.home-manager;
        nixvim = inputs.nixvim;
        nixGaming = inputs.nix-gaming;
        noctalia = inputs.noctalia;
        stylix = inputs.stylix;
        noctaliaProtonvpn = inputs.noctalia-protonvpn;
      };
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/desktop/default.nix
        ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/laptop/default.nix
        ];
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
