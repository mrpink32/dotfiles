{
    description = "A very basic flake";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/master";
        #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        nixpkgs-unstable = {
            url = "github:NixOS/nixpkgs/nixpkgs-unstable";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs-stable = {
            url = "github:NixOS/nixpkgs/nixos-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvim = {
            url = "github:nix-community/nixvim/main";
        };
        nixpkgs-godot = {
            #url = "github:NixOS/nixpkgs#09b9c34"; #355753#"github:ilikefrogs101/nixpkgs/master";
            url = "github:nixos/nixpkgs?rev=b9cbab7e1bca23161e6da701a8eb6294230a4f05"; #dd51f52372a20a93c219e8216fe528a648ffcbf4
        };
        zig.url = "github:mitchellh/zig-overlay";
        zls = {
            url = "github:zigtools/zls/master"; #github:mrpink32/zls/master
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-cosmic = {
            url = "github:lilyinstarlight/nixos-cosmic";
        };
        firefox-nightly = {
            url = "github:nix-community/flake-firefox-nightly";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        #lix-module = {
        #    url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
    };

    outputs = {nixpkgs,nixos-cosmic,nixpkgs-stable,nixpkgs-unstable,nixpkgs-godot,zig,...} @ inputs:
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
            overlay-godot = final: prev: {
                #godot = nixpkgs-unstable.legacyPackages.${prev.system};
                # use this variant if unfree packages are needed:
                godot = import nixpkgs-godot {
                    inherit system;
                    config.allowUnfree = true;
                };
            };
        in
            {
            nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
                #inherit system;
                system = "x86_64-linux";
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
                    #lix-module.nixosModules.default
                    nixos-cosmic.nixosModules.default
                    ({ ... }: { nixpkgs.overlays = [ 
                        overlay-unstable
                        overlay-stable
                        overlay-godot
                        zig.overlays.default
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
