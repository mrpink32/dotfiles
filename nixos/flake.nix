{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/master";
        nixpkgs-unstable = {
            url = "github:NixOS/nixpkgs/nixpkgs-unstable";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.05";
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
            #url = "github:hyprwm/Hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvim = {
            url = "github:nix-community/nixvim/main";
            #inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs-godot = {
            url = "github:ilikefrogs101/nixpkgs/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zig.url = "github:mitchellh/zig-overlay";
        zls.url = "github:zigtools/zls/master";
        nixos-cosmic = {
            url = "github:lilyinstarlight/nixos-cosmic";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        firefox-nightly = {
            url = "github:nix-community/flake-firefox-nightly";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {nixpkgs,nixos-cosmic,nixpkgs-stable,nixpkgs-unstable,...} @ inputs:
    let
        system = "x86_64-linux";
        overlay-stable = final: prev: {
            #stable = nixpkgs-stable.legacyPackages.${prev.system};
            # use this variant if unfree packages are needed:
            stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
            };
        };
        overlay-unstable = final: prev: {
            #unstable = nixpkgs-unstable.legacyPackages.${prev.system};
            # use this variant if unfree packages are needed:
            unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
            };
        };
    in
    {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; }; # this is the important part
            modules = [
                {
                    nix.settings = {
                        substituters = [
                            "https://cosmic.cachix.org/"
                            "https://hyprland.cachix.org/"
                        ];
                        trusted-public-keys = [
                            "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                        ];
                    };
                }
                nixos-cosmic.nixosModules.default
                ({ ... }: { nixpkgs.overlays = [ 
                        overlay-unstable
                        overlay-stable
                ]; })
                ./configuration.nix
            ];
        };
        # Used by `nix develop .#<name>`
        #devShells."<system>"."<name>" = derivation;
        # Used by `nix develop`
        #devShells."<system>".default = derivation;
    }; 
}
