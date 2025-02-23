# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:

{
    imports = [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./nixvim-configuration.nix
    ];

    # Bootloader.
    boot = {
        kernelPackages = pkgs.linuxPackages_latest; #pkgs.linuxPackages_6_1; #pkgs.linuxPackages_latest; #pkgs.linuxPackages_lqx #pkgs.xanmod_latest;
        #kernelParams = [ "processor.max_cstate=1" "intel_idle.max_cstate=0" "amdgpu.mcbp=0" "preempt=full" ]; #
        kernelParams = [
            "nvidia_drm.fbdev=1"
            "nvidia_drm.modeset=1"
        ];
        kernel = {
            enable = true;
            sysctl = {
                "vm.max_map_count" = 2147483642;
                "vm.swappiness" = 10;
            };
            features = {
                #rust = true;
                debug = true;
            };
        };
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        initrd = {
            #kernelModules = [ "nvidia" ];
            systemd.dbus.enable = true;
        };
        extraModulePackages = [ config.boot.kernelPackages.nvidia_x11_beta ];
    };

    # ----- hardware options -----
    hardware = {
        enableAllFirmware = true;
        enableRedistributableFirmware = true;
        #cpu.amd.updateMicrocode = true;

        # ----- openrazer options -----
        openrazer.enable = true;

        # ----- bluetooth options -----
        bluetooth = {
            enable = true;
            input = {
                General = {
                    ClassicBondedOnly = false;
                };
            };
            #settings = {General = { Experimental = "true"; }; };
        };

        # ----- graphics options -----
        graphics = {
            enable = true;
            #extraPackages = [ inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers ];
            enable32Bit = true;
            #extraPackages32 =  [ inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers ];
        };

        # ----- Nvidia options -----
        nvidia = {
            # Use the NVidia open source kernel module (not to be confused with the
            # independent third-party "nouveau" open source driver).
            # Support is limited to the Turing and later architectures. Full list of 
            # supported GPUs is at: 
            # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
            # Only available from driver 515.43.04+
            # Do not disable this unless your GPU is unsupported or if you have a good reason to.
            open = true;

            # Enable the Nvidia settings menu,
            # accessible via `nvidia-settings`.
            nvidiaSettings = true;

            # Modesetting is needed for most Wayland compositors
            modesetting.enable = true;

            prime = {
                #offload = {
                #    enable = true;
                #    enableOffloadCmd = true;
                #};
                sync.enable = true;
                amdgpuBusId = "PCI:7:0:0";
                nvidiaBusId = "PCI:1:0:0";
            };

            # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
            powerManagement = {
                enable = true;
                # Fine-grained power management. Turns off GPU when not in use.
                # Experimental and only works on modern Nvidia GPUs (Turing or newer).
                finegrained = false;
            };

            # Optionally, you may need to select the appropriate driver version for your specific GPU.
            # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/os-specific/linux/nvidia-x11
            package = config.boot.kernelPackages.nvidiaPackages.beta;
        };

        # ----- AMDGPU options -----
        #amdgpu = {
        #    initrd.enable = true;
        #    opencl.enable = true;
        #    #amdvlk = {
        #    #    enable = true;
        #    #    support32Bit.enable = true;
        #    #    supportExperimental.enable = true;
        #    #};
        #};
    };

    specialisation = {
        travel.configuration = {
            services.xserver.videoDrivers = ["amdgpu"];
            hardware.nvidia = {
                prime.sync.enable = lib.mkForce false;
                prime.offload = {
                    enable = lib.mkForce true;
                    enableOffloadCmd = lib.mkForce true;
                };
                powerManagement.finegrained = lib.mkForce true;
            };
        };
    };

    # ----- Networking -----
    networking = {
        networkmanager.enable = true;
        hostName = "nixos"; # Define your hostname.
        # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

        # Configure network proxy if necessary
        # networking.proxy.default = "http://user:password@proxy:port/";
        # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    };

    # Set your time zone.
    time.timeZone = "Europe/Copenhagen";

    # Select internationalisation properties.
    i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
            LC_ADDRESS = "ja_JP.UTF-8";
            LC_IDENTIFICATION = "ja_JP.UTF-8";
            LC_MEASUREMENT = "ja_JP.UTF-8";
            LC_MONETARY = "ja_JP.UTF-8";
            LC_NAME = "ja_JP.UTF-8";
            LC_NUMERIC = "ja_JP.UTF-8";
            LC_PAPER = "ja_JP.UTF-8";
            LC_TELEPHONE = "ja_JP.UTF-8";
            LC_TIME = "ja_JP.UTF-8";
        };
        inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
                waylandFrontend = true;
                addons = with pkgs; [ fcitx5-mozc ];
            };
        };
    };

    services = {
        # Enable the X11 windowing system.
        xserver = {
            enable = true;
            autorun = true;
            # Load nvidia driver for Xorg and Wayland
            videoDrivers = ["nvidia"]; #"amdgpu"
            # Configure keymap in X11
            xkb = {
                model = "pc104";
                layout = "us,dk,gr";
                variant = "dvorak,dvorak,polytonic";
                options = "caps:backspace,shift:both_capslock,grp:win_space_toggle";
            };
        };
        displayManager = {
            defaultSession = "cosmic";
            sddm = {
                enable = true;
                wayland.enable = true;
                #package = pkgs.kdePackages.sddm;
                #enableHidpi = true;
            };
        };
        # Enable touchpad support (enabled default in most desktopManager).
        #libinput.enable = true;
        desktopManager = {
            cosmic.enable = true;
            plasma6.enable = true;
        };
        #dockerRegistry.enable = true;
    };

    # Enable supergfxd power daemon
    #systemd.services.supergfxd.path = [ pkgs.pciutils ];
    #systemd.services.supergfxd.enable = true;
    #services = {
    #    #power-profiles-daemon.enable = true;
    #    #supergfxd.enable = true;
    #    #asusd = {
    #    #    enable = true;
    #    #    enableUserService = true;
    #    #    package = pkgs.asusctl;
    #    #};
    #};

    # Configure console keymap
    console.useXkbConfig = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound using pipewire.
    #hardware.pulseaudio.enable = false;
    #hardware.pulseaudio.support32Bit = false;

    security.polkit.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        # jack.enable = true;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.defaultUserShell = pkgs.zsh;
    users.groups = {
        libvirtd.members = [ "mikkel" ];
    };
    users.users.mikkel = {
        isNormalUser = true;
        #home = "/mnt/data/home/mikkel";
        description = "mikkel";
        extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "bluetooth" "docker" ];
    };

    # Allow unfree packages
    nixpkgs.config = {
        allowUnfree = true;
        allowBroken = false;
    };

    nix = {
        enable = true;
        package = pkgs.nixVersions.latest; #pkgs.lix;
        channel.enable = false;
        # add some flake inputs to the nix-registry for nix search
        registry = {
            nixpkgs.flake = inputs.nixpkgs;
	        hyprland.flake = inputs.hyprland;
            nixpkgs-stable.flake = inputs.nixpkgs-stable;
            nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
            firefox-nightly.flake = inputs.firefox-nightly;
            #lix-module.flake = inputs.lix-module;
        };
        settings = {
            sandbox = true;
            # enable nix experimental features
            experimental-features = [ "nix-command" "flakes" ];
            max-jobs = 4;
        };
    };

    documentation = {
        enable = true;
        nixos = {
            enable = true;
            #includeAllModules = true;
        };
        man = {
            enable = true;
            generateCaches = true;
            man-db = {
                enable = true;
                package = pkgs.man-db;
            };
        };
        info.enable = true;
        doc.enable = true;
        dev.enable = true;
    };

    # enable flatpak
    services.flatpak.enable = true;

    virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        storageDriver = "btrfs";
        rootless = {
            enable = true;
            setSocketVariable = true;
        };
    };

    # Extra xdg portals
    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-utils
            pkgs.xdg-dbus-proxy
            #pkgs.xdg-desktop-portal-cosmic
            pkgs.kdePackages.xdg-desktop-portal-kde
        ];
    };

    programs = {
        zsh = {
            enable = true;
            enableCompletion = true;
            enableBashCompletion = true;
            autosuggestions.enable = true;
            shellAliases = {
                repos = "cd /home/repositories";
                build = "nix-build";
                update-inputs = "nix flake update /etc/nixos";
                list-profiles = "nix-env --list-generations -p /nix/var/nix/profiles/system";
            };
            #shellInit = "fastfetch";
        };
        bash = {
            completion.enable = true;
            shellAliases = {
                repos = "cd /home/repositories";
                build = "nix-build";
                update-flakes = "nix flake update /etc/nixos";
                list-profiles = "nix-env --list-generations -p /nix/var/nix/profiles/system";
            };
        };
        tmux = {
            enable = true;
            clock24 = true;
            keyMode = "vi";
            baseIndex = 1;
        };
        rog-control-center = {
            enable = true;
            autoStart = true;
        };
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                # libraries to make available for dynamicly linked programs
            ];
        };
        uwsm.enable = true;
        hyprland = {
            enable = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override{ debug = true; }; #inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override{ debug = true; }; #inputs.hyprland.packages.${pkgs.system}.hyprland;
            portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
            withUWSM = true;
            xwayland.enable = true;
        };
        hyprlock = {
            enable = false;
            #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
        };
        steam = {
            enable = true;
            extest.enable = true;
            protontricks.enable = true;
            gamescopeSession.enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
            fontPackages = with pkgs; [ source-han-sans ];
            extraPackages = with pkgs; [
                gamescope
            ];
        };
        gamescope.enable = true;
        gamemode.enable = true;
        direnv = {
            enable = true;
            loadInNixShell = true;
            enableZshIntegration = true;
        };
        thunderbird = {
            enable = true;
            package = pkgs.thunderbird-latest;
        };
        virt-manager = {
            enable = true;
        };
    };

    #packageGroups = import ../package-groups.nix { inherit pkgs; };
    #environment.systemPackages = with packageGroups; [ desktop dev utils ];

    # List packages installed in system profile. To search, run:
    environment = {
        plasma6.excludePackages = with pkgs; [
            kdePackages.konsole
            kdePackages.plasma-browser-integration
            kdePackages.oxygen
        ];
        systemPackages = with pkgs; [ 
            microcode-amd
            vim
            alacritty
            kitty
            zellij
            git
            git-doc
            man
            man-pages
            wget
	        inetutils
            flac
            fastfetch
            neovim-unwrapped
            bc
            file
            bat
            anki
            zoxide
            mercurial
            llvmPackages_19.clang
            llvmPackages_19.clang-tools
            llvmPackages_19.lld
            llvmPackages_19.lldb
            llvmPackages_19.llvm
            llvmPackages_19.libclang
            cargo
            rustc
            R
            #(inputs.zig.packages.${pkgs.stdenv.hostPlatform.system}.master)
            pkgs.zigpkgs.master
            odin
            go
            openjdk
            openjdk8
            openjdk21
            openjdk23
            (with dotnetCorePackages; combinePackages [
                sdk_9_0
                sdk_8_0
                aspnetcore_9_0
                aspnetcore_8_0
            ])
            dotnetPackages.Nuget
            nodePackages_latest.nodejs
            typescript
            # dependencies
            glibc.dev
            libGLU.dev
            alsa-oss
            alsa-lib.dev
            libpulseaudio.dev
            alsa-utils
            alsa-tools
            alsa-plugins
            alsa-firmware
            pango
            cairo
            pkg-config
            adwaita-icon-theme
            unzip
            unrar
            xdg-utils
            supergfxctl
            tree-sitter
            libva.dev
            # other apps
            ncspot
            kdePackages.kate
            jetbrains.clion
            jetbrains.rider
            #(jetbrains.rider.overrideAttrs (attrs: {
            #    postInstall = (attrs.postInstall or "") + lib.optionalString (stdenv.hostPlatform.isLinux) ''
            #        (
            #          cd $out/rider
            #          ls -d $PWD/plugins/cidr-debugger-plugin/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
            #          xargs patchelf \
            #            --replace-needed libssl.so.10 libssl.so \
            #            --replace-needed libcrypto.so.10 libcrypto.so \
            #            --replace-needed libcrypt.so.1 libcrypt.so
            #          for dir in lib/ReSharperHost/linux-*; do
            #            rm -rf $dir/dotnet
            #            ln -s ${dotnetCorePackages.sdk_9_0.unwrapped}/share/dotnet $dir/dotnet 
            #          done
            #        )
            #    '';
            #}))
            jetbrains.writerside
            jetbrains.rust-rover
            jetbrains.idea-ultimate
            jetbrains-toolbox
            (vscode-with-extensions.override {
                vscodeExtensions = with vscode-extensions; [
                    #ms-python.python
                    vscodevim.vim
                    ms-vscode.live-server
                    ritwickdey.liveserver
                    ms-vsliveshare.vsliveshare
                    ms-azuretools.vscode-docker
                    ms-vscode-remote.remote-ssh
                    vscode-extensions.ms-dotnettools.csharp
                    vscode-extensions.ms-dotnettools.csdevkit
                    vscode-extensions.ms-dotnettools.vscode-dotnet-runtime
                ];
            })
            lutris
            unityhub
            godot.godot_4-mono
            gparted
            ffmpeg_7
            gnumake
            cmake
            opencv
            htop
            # native wayland support (unstable)
            wineWowPackages.waylandFull
            # winetricks (all versions)
            winetricks
            # wine-staging (version with experimental features)
            wineWowPackages.staging
            #pkgs.protontricks
            steamcmd
            mono
            lua
            zip
            (discord-canary.override {
                #withOpenASAR = true;
                withVencord = true;
            })
            (discord.override {
                withOpenASAR = true;
                withVencord = true;
            })
            discordo
            spotify
            nasm
            lf
            #slic3r
            btop
            prismlauncher
            (python313.withPackages(ps: with ps; [
                pip
            ]))
            coreutils
            libreoffice
            onlyoffice-bin
            vlc
            mpv
            inputs.firefox-nightly.packages.${pkgs.system}.firefox-nightly-bin
            firefox-devedition
            librewolf
            trilium-desktop
            heroic
            rpcs3
            osu-lazer-bin
            protonvpn-gui
            protonvpn-cli
            #virtual manager
            qemu
            qemu-utils
            virglrenderer
            OVMFFull
            #other
            gimp
            krita
            blender
            drawio
            obs-studio
            lshw
            steam-tui
            bluez
            bluez-tools
            #gtk4
            #gtk4-layer-shell
            kdePackages.dolphin
            kdePackages.ark
            kdePackages.ktorrent
            kdePackages.partitionmanager
            kdePackages.spectacle
            kdePackages.kdenlive
            openhmd
            openvr
            brightnessctl
            sixpair
            jstest-gtk
            # wm stuff
            waybar
            pavucontrol
            #ncpamixer
            dunst
            fuzzel
            playerctl
            hyprpaper
            rofi
            rofi-wayland

            swww

            airshipper
            freecad-wayland
            #stable.cura
            stable.kicad
            steamtinkerlaunch
            stable.calibre
            vesktop
            mangohud
            polychromatic
            razergenie
            r2modman
            wireshark
            android-tools
        ];
    };

    #services.monado.enable = true;

    fonts = {
        packages = with pkgs; [
            wqy_zenhei
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts
            nerd-fonts.jetbrains-mono
            #(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
        fontDir.enable = true;
        fontconfig.enable = true;
    };


    virtualisation.libvirtd = {
        enable = true;
        qemu = {
            package = pkgs.qemu_kvm;
            swtpm.enable = true;
            ovmf = {
                enable = true;
                packages = [ pkgs.OVMFFull.fd ];
            };
        };
    };

    # Enable the OpenSSH daemon.
    services.openssh = {
        enable = false;
        ports = [ 22 ];
        allowSFTP = false;
        sftpServerExecutable = "internal-sftp";
    };

    # Or disable the firewall altogether.
    networking.firewall.enable = true;
    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 25565 9000 80 21 22 20 ];
    networking.firewall.allowedUDPPorts = [ 25565 9000 ];
    
    services.vsftpd = {
        enable = true;
        #cannot chroot && write
        #chrootlocalUser = true;
        writeEnable = true;
        localUsers = true;
        #userlist = [ "martyn" "cam" ];
        #userlistEnable = true;
    };

    environment.variables = {
        EDITOR = "nvim";
        PATH = [];
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
}
