{
    description = "A very basic flake";
    inputs = {
        nixpkgs = {
            #url = "github:NixOS/nixpkgs/master";
            #url = "github:NixOS/nixpkgs?ref=master";
            url = "github:NixOS/nixpkgs?ref=nixos-unstable";
        };
        #inputs.nixpkgs = {
        #    type = "github";
        #    owner = "NixOS";
        #    repo = "nixpkgs";
        #    ref = "nixos-26.05";
        #};
        nixpkgs-unstable = {
            url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        };
        nixpkgs-stable = {
            url = "github:NixOS/nixpkgs?ref=nixos-26.05";
        };
        nixvim = {
            url = "github:nix-community/nixvim/nixos-26.05";
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
            url = "github:asus-linux-drivers/asus-numberpad-driver/v7.0.2"; # use this line for the latest release of stable version
            #url = "github:asus-linux-drivers/asus-numberpad-driver"; # or this line for using master branch with the latest changes which may be not stable
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
        awww = {
            url = "git+https://codeberg.org/LGFae/awww";
        };
        waveforms = {
            url = "github:liff/waveforms-flake";
        };
        smath-studio.url = "path:/home/mikkel/Projects/SMathStudioFlake";
        cpak.url = "github:Containerpak/cpak/v2";
    };

    outputs = {nixpkgs,nixpkgs-stable,nixpkgs-unstable,niri,nix-cachyos-kernel,asus-numberpad-driver,waveforms,smath-studio,cpak,...} @ inputs:
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
                                #"https://hyprland.cachix.org/"
                                "https://niri.cachix.org"
                            ];
                            trusted-public-keys = [
                                #"cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                                #"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                                "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
                            ];
                        };
                    }
                    #lix-module.nixosModules.default
                    ({ ... }: { nixpkgs.overlays = [ 
                        overlay-unstable
                        overlay-stable
                        inputs.niri.overlays.niri
                        nix-cachyos-kernel.overlays.default
                        #nix-cachyos-kernel.overlays.pinned
                        # Godot-mono harfbuzz workaround
                        #(final: prev: {
                        #    godot-mono = prev.godot-mono.overrideAttrs (old: {
                        #        sconsFlags = (old.sconsFlags or []) ++ [ "builtin_harfbuzz=true" ];
                        #    });
                        #})
                        # adept2
                        #(final: prev: {
                        #  adept2-runtime = prev.adept2-runtime.overrideAttrs (old: {
                        #    postInstall = (old.postInstall or "") + ''
                        #      mkdir -p $out/lib/udev
                        #      if [ -e usr/lib/udev/dftdrvdtch ]; then
                        #        cp -P usr/lib/udev/dftdrvdtch $out/lib/udev/
                        #        chmod +x $out/lib/udev/dftdrvdtch
                        #      fi
                        #    '';
                        #  });
                        #})
                        # waveform override
                        (final: prev: {
                            waveforms = prev.waveforms.overrideAttrs (old: {
                                src = /home/mikkel/digilent-debs/digilent.waveforms_3.24.4_amd64.deb;
                            });

                            adept2-runtime = prev.adept2-runtime.overrideAttrs (old: {
                                src = /home/mikkel/digilent-debs/digilent.adept.runtime_2.27.9-amd64.deb;
                            });
                        })
                        #(final: prev:
                        #    let
                        #        localDeb = name: hash: final.requireFile {
                        #            inherit name hash;
                        #            url = "file:///home/mikkel/digilent-debs/${name}";
                        #            message = "Place ${name} in /home/mikkel/digilent-debs/";
                        #        };
                        #    in
                        #        {
                        #        waveforms = prev.waveforms.overrideAttrs (old: {
                        #            src = localDeb "digilent.waveforms_3.24.4_amd64.deb"
                        #                "sha256-ky0TAL3M3JYpzDqdTdjGZqZujzeW5B9Nu7H/PYPHoxQ=";
                        #        });
                        #        digilent-adept-runtime = prev.digilent-adept-runtime.overrideAttrs (old: {
                        #            src = localDeb "digilent.adept.runtime_2.27.9-amd64.deb"
                        #                "sha256-yKLM8tnqH/oPOkrk7S/2kKBof/gzgrYtrjD6ExmLv1M=";
                        #        });
                        #    }
                        #)
                    ]; })
                    cpak.nixosModules.default
                    niri.nixosModules.niri
                    waveforms.nixosModules.default
                    #smath-studio.nixosModules.default
                    asus-numberpad-driver.nixosModules.default
                    ./configuration.nix
                ];
            };
            nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; }; # this is the important part
                modules = [
                    ({ config, lib, pkgs, inputs, ... }: {

                        #networking.firewall.allowedTCPPorts = [ 80 22 ];

                        #services.openssh = {
                        #    enable = false;
                        #    ports = [ 22 ];
                        #    allowSFTP = false;
                        #    sftpServerExecutable = "internal-sftp";
                        #};

                        #services.httpd = {
                        #    enable = true;
                        #    adminAddr = "morty@example.org";
                        #};
                    })
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
