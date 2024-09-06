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
        kernelPackages = pkgs.linuxPackages_latest; #pkgs.linuxPackages_len; #pkgs.linuxPackages_lqx #pkgs.xanmod_latest;
        #kernelParams = [ "processor.max_cstate=1" ];
        kernel = {
            enable = true;
            sysctl = { "vm.max_map_count" = 2147483642; };
            features = {
                rust = true;
                debug = true;
            };
        };
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.kernelModules = [ "nvidia" ];
        initrd.systemd.dbus.enable = true;
        extraModulePackages = [ config.boot.kernelPackages.nvidia_x11_beta ];
    };

    #hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;

    hardware.openrazer.enable = true;

    hardware.bluetooth = {
        enable = true;
        input = {
            General = {
                ClassicBondedOnly = false;
            };
        };
    };
    #hardware.bluetooth.settings = {General = { Experimental = "true"; }; };

    # enable graphics
    hardware.graphics = {
        enable = true;
        #extraPackages = [ inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers ];
        enable32Bit = true;
        #extraPackages32 =  [ inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers ];
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"]; #"amdgpu"

    # ----- Nvidia options -----
    hardware.nvidia = {
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
            sync.enable = true;
            nvidiaBusId = "PCI:1:0:0";
            amdgpuBusId = "PCI:7:0:0";
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

    # ----- AMD GPU options -----
    #hardware.amdgpu = {
    #    initrd.enable = true;
    #    opencl.enable = true;
    #    amdvlk = {
    #        enable = true;
    #        support32Bit.enable = true;
    #        supportExperimental.enable = true;
    #    };
    #};

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
        displayManager = {
            defaultSession = "hyprland";
            sddm = {
                enable = true;
                wayland.enable = true;
                #package = pkgs.kdePackages.sddm;
                #enableHidpi = true;
            };
        };
        # Enable touchpad support (enabled default in most desktopManager).
        libinput.enable = true;
        desktopManager = {
            cosmic.enable = true;
            plasma6.enable = true;
        };
    };

    # Enable the X11 windowing system.
    services.xserver = {
        enable = true;
        autorun = true;

        # Configure keymap in X11
        xkb = {
            model = "pc104";
            layout = "us,dk";
            variant = "dvorak,dvorak";
            options = "caps:backspace,shift:both_capslock,grp:win_space_toggle";
        };
    };
    security.polkit.enable = true;

    # Enable supergfxd power daemon
    systemd.services.supergfxd.path = [ pkgs.pciutils ];
    services = {
        power-profiles-daemon.enable = true;
        supergfxd.enable = true;
        asusd = {
            enable = true;
            enableUserService = true;
        };
    };

    # Configure console keymap
    console.useXkbConfig = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound using pipewire.
    hardware.pulseaudio.enable = false;
    hardware.pulseaudio.support32Bit = false;
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
    users.users.mikkel = {
        isNormalUser = true;
        home = "/mnt/data/home/mikkel";
        description = "mikkel";
        extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "bluetooth" ];
    };

    # Allow unfree packages
    nixpkgs.config = {
        allowUnfree = true;
        allowBroken = false;
    };

    nix = {
        package = pkgs.nixVersions.latest;
        # add some flake inputs to the nix-registry for nix search
        registry = {
            nixpkgs.flake = inputs.nixpkgs;
	        hyprland.flake = inputs.hyprland;
            nixpkgs-stable.flake = inputs.nixpkgs-stable;
            nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
        };
        # enable nix experimental features
        settings.experimental-features = [ "nix-command" "flakes" ];
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
                repos = "cd /mnt/data/repositories";
                build = "nix-build";
                update-inputs = "nix flake update /etc/nixos";
            };
            #shellInit = "fastfetch";
        };
        bash = {
            completion.enable = true;
            shellAliases = {
                repos = "cd /mnt/data/repositories";
                build = "nix-build";
                update-flakes = "nix flake update /etc/nixos";
            };
        };
        tmux = {
            enable = true;
            clock24 = true;
        };
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                # libraries to make available for dynamicly linked programs
            ];
        };
        hyprland = {
            enable = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override{ debug = true; }; #inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override{ debug = true; }; #inputs.hyprland.packages.${pkgs.system}.hyprland;
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
            mercurial
            #clang_18
            #clang-tools_18
            #lld_18
            #lldb_18
            #llvm_18
            #libclang
            llvmPackages_19.clang
            llvmPackages_19.clang-tools
            llvmPackages_19.lld
            llvmPackages_19.lldb
            llvmPackages_19.llvm
            llvmPackages_19.libclang
            cargo
            rustc
            (inputs.zig.packages.${pkgs.stdenv.hostPlatform.system}.master)
            odin
            go
            jdk22
            jdk
            (with dotnetCorePackages; combinePackages [
                sdk_9_0
                sdk_8_0
                sdk_7_0
                sdk_6_0
                aspnetcore_9_0
            ])
            dotnetPackages.Nuget
            nodePackages_latest.nodejs
            #nodejs_22
            typescript
            # dependencies
            glibc.dev
            libGLU.dev
            SDL2.dev
            freetype.dev
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
            jetbrains.writerside
            jetbrains.rust-rover
            jetbrains.idea-ultimate
            #vscode
            (vscode-with-extensions.override {
                vscodeExtensions = with vscode-extensions; [
                    #ms-python.python
                    vscodevim.vim
                    ms-vscode.live-server
                    ritwickdey.liveserver
                    ms-vsliveshare.vsliveshare
                    ms-azuretools.vscode-docker
                    ms-vscode-remote.remote-ssh
                    vscode-extensions.ms-dotnettools.csdevkit
                ];
            })
            lutris
            unityhub
            #(callPackage "${inputs.nixpkgs-godot}/pkgs/development/tools/godot/4/mono" { }) #.override { withTouch = false; })
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
            (discord.override {
                withOpenASAR = true;
                withVencord = true;
            })
            discordo
            #(discord-canary.override {
            #    withOpenASAR = true;
            #    withVencord = true;
            #})
            spotify
            nasm
            lf
            slic3r
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
            unstable.freecad
            stable.cura
            trilium-desktop
            heroic
            osu-lazer-bin
            protonvpn-gui
            protonvpn-cli
            #virtual manager
            virt-manager
            qemu
            qemu-utils
            virglrenderer
            OVMFFull
            #other
            gimp
            krita
            drawio
            obs-studio
            lshw
            steam-tui
            bluez
            bluez-tools
            gtk4
            gtk4-layer-shell
            kdePackages.dolphin
            kdePackages.ark
            kdePackages.ktorrent
            kdePackages.partitionmanager
            kdePackages.spectacle
            kdePackages.kdenlive
            openhmd
            openvr
            asusctl
            brightnessctl
            sixpair
            jstest-gtk
            # wm stuff
            waybar
            dunst
            fuzzel
            playerctl
            hyprpaper
            xwaylandvideobridge
            rofi
            rofi-wayland
            # cosmic
            cosmic-term
            cosmic-edit
            cosmic-files
            cosmic-screenshot
            unstable.kicad
            #kicad-unstable
            #kicad-testing
            steamtinkerlaunch
            calibre
            vesktop
            # Razer device management apps
            polychromatic
            razergenie
            r2modman
            # custom packages
            # (import /mnt/data/repositories/wayland/src/default.nix)
            # (import /mnt/data/repositories/statusbar/c_test/default.nix)
        ];
    };

    #services.monado.enable = true;

    fonts = {
        packages = with pkgs; [
            wqy_zenhei
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
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
    services.openssh.enable = false;

    networking.firewall.enable = true;
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ 8080 ];
    # networking.firewall.allowedUDPPorts = [ 51820 ];

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
