{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/master";
        nixpkgs-unstable = {
            url = "github:NixOS/nixpkgs/nixpkgs-unstable";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.11";
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; #"github:hyprwm/Hyprland/main";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvim = {
            url = "github:nix-community/nixvim/main";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs-godot = {
            url = "github:ilikefrogs101/nixpkgs/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs-zls = {
            url = "github:zigtools/zls/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {self,nixpkgs,nixpkgs-stable,nixpkgs-unstable,...} @ inputs:
    let
        system = "x86_64-linux";
        #overlay-stable = final: prev: {
        #    #stable = nixpkgs-stable.legacyPackages.${prev.system};
        #    stable = import nixpkgs-stable {
        #        inherit system;
        #        config.allowUnfree = true;
        #    };
        #};
        #overlay-unstable = final: prev: {
        #    #unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        #    unstable = import nixpkgs-unstable {
        #        inherit system;
        #        config.allowUnfree = true;
        #    };
        #};
    in 
    {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = system;
            specialArgs = { inherit inputs; }; # this is the important part
            modules = [
                #({ config, pkgs, ... }: {
                #    nixpkgs.overlays = [
                #        overlay-stable
                #        overlay-unstable
                #    ];
                #})
                ./configuration.nix
            ];
        };
    }; 
}
