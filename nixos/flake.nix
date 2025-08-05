{
    description = "A very basic flake";
    inputs = {
        nixpkgs = {
            #url = "github:NixOS/nixpkgs/master";
            #url = "github:NixOS/nixpkgs?ref=master";
            url = "github:NixOS/nixpkgs?ref=nixos-unstable";
        };
        nixpkgs-unstable = {
            url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        };
        nixpkgs-stable = {
            url = "github:NixOS/nixpkgs/nixos-25.05";
        };
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
        };
        nixvim = {
            url = "github:nix-community/nixvim/main";
        };
        #zig.url = "github:mitchellh/zig-overlay";
        zls = {
            url = "github:zigtools/zls?ref=master";
        };
        firefox-nightly = {
            url = "github:nix-community/flake-firefox-nightly";
        };
        niri = {
            url = "github:sodiboo/niri-flake/main";
        };
        #lix-module = {
        #    url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
        asus-numberpad-driver = {
            url = "github:asus-linux-drivers/asus-numberpad-driver";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {nixpkgs,nixpkgs-stable,nixpkgs-unstable,asus-numberpad-driver,niri,...} @ inputs:
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
                #inherit system;
                system = "x86_64-linux";
                specialArgs = { inherit inputs; }; # this is the important part
                modules = [
                    {
                        nix.settings = {
                            substituters = [
                                #"https://cosmic.cachix.org/"
                                "https://hyprland.cachix.org/"
                                "https://niri.cachix.org"
                            ];
                            trusted-public-keys = [
                                #"cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                                "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
                            ];
                        };
                    }
                    #lix-module.nixosModules.default
                    ({ ... }: { nixpkgs.overlays = [ 
                        overlay-unstable
                        overlay-stable
                        inputs.niri.overlays.niri
                    ]; })
                    ./configuration.nix
                    asus-numberpad-driver.nixosModules.default
                ];
            };
            #nixosConfigurations.container = nixpkgs.lib.nixosSystem {
            #    system = "x86_64-linux";
            #    specialArgs = { inherit inputs; }; # this is the important part
            #    modules = [
            #        ({ pkgs, ... }: {
            #            boot.isContainer = true;

            #            networking.firewall.allowedTCPPorts = [ 80 22 ];

            #            services.openssh = {
            #                enable = false;
            #                ports = [ 22 ];
            #                allowSFTP = false;
            #                sftpServerExecutable = "internal-sftp";
            #            };

            #            services.httpd = {
            #                enable = true;
            #                adminAddr = "morty@example.org";
            #            };
            #        })
            #    ];
            #};
            # Used by `nix develop .#<name>`
            #devShells."<system>"."<name>" = derivation;
            # Used by `nix develop`
            #devShells."<system>".default = derivation;
       }; 
}
