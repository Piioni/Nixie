{
  description = "Mi primer NixOS";

    inputs = {
      # Official NixOS package source, using nixos's unstable branch by default
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

      # Home Manager, for managing user-level configuration
      home-manager = {
        url = "github:nix-community/home-manager/master";
        # url = "github:nix-community/home-manager/release-25.11";

        # The `follows` keyword in inputs is used for inheritance.
        # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
        # to avoid problems caused by different versions of nixpkgs dependencies.
        inputs.nixpkgs.follows = "nixpkgs";
    };


    };

    outputs = { nixpkgs, ... }: {
        nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hosts/desktop/default.nix ];
        };
    };
}
