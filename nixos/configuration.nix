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
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;#pkgs.linuxPackages_latest; #pkgs.linuxPackages_6_1; #pkgs.linuxPackages_latest; #pkgs.linuxPackages_lqx #pkgs.xanmod_latest;
        #kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
            "nvidia_drm.fbdev=1"
            "nvidia_drm.modeset=1"
            #"nmi_watchdog=0"
            #"nowatchdog"
        ];
        kernel = {
            enable = true;
            sysctl = {
                "vm.max_map_count" = 2147483642;
                "vm.swappiness" = 8;
            };
            features = {
                debug = true;
            };
        };
        loader = {
            timeout = 5;
            systemd-boot = {
                enable = true;
                editor = false;
                graceful = true;
            };
            efi.canTouchEfiVariables = true;
        };
        initrd = {
            systemd.dbus.enable = true;
        };
        #extraModulePackages = [ config.boot.kernelPackages.nvidia_x11_beta ];
        #extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
        extraModulePackages = [
            config.boot.kernelPackages.nvidia_x11_beta
            # --- vmware currently blocks cachy kernel from building ---
            #config.boot.kernelPackages.vmware
        ];
        enableContainers = true;

        # load ntsync kernel module
        kernelModules = [ "ntsync" ];

        # plymouth to hide scary text from normies
        plymouth = {
            enable = false;
        };

        # Enable "Silent boot"
        #consoleLogLevel = 3;
        #initrd.verbose = false;
        #kernelParams = [
        #    "quiet"
        #    "rd.udev.log_level=3"
        #    "rd.systemd.show_status=auto"
        #];

        # Hide the OS choice for bootloaders.
        # It's still possible to open the bootloader list by pressing any key
        # It will just not appear on screen unless a key is pressed
        #loader.timeout = 0;
    };

    # ----- udev options -----
    services.udev = {
        # Allow all users to access ntsync directory
        extraRules = ''
            KERNEL=="ntsync", MODE="0666"
        '';
        packages = with pkgs; [ platformio-core.udev ];
        # pio produces false negative when looking for udev rules file
        # pio settings set disable_udev_rules_check Yes
    };

    powerManagement.enable = true;

    # ----- hardware options -----
    hardware = {
        enableAllFirmware = true;
        enableRedistributableFirmware = true;

        # ----- openrazer options -----
        openrazer.enable = false;

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
            # package = config.boot.kernelPackages.nvidiaPackages.beta;
            package = config.boot.kernelPackages.nvidiaPackages.production;
        };

        # ----- AMDGPU options -----
        amdgpu = {
            initrd.enable = true;
            opencl.enable = true;
            #amdvlk = {
            #    enable = true;
            #    support32Bit.enable = true;
            #    supportExperimental.enable = true;
            #};
        };

        opentabletdriver.enable = true;
    };


    # ----- Networking -----
    systemd.services.NetworkManager-wait-online.enable = false;
    networking = {
        hostName = "nixos"; # Define your hostname.
        networkmanager = {
            enable = true;
            #dns = "none";
            plugins = [
                pkgs.networkmanager-openvpn
                pkgs.networkmanager-openconnect
            ];
            wifi.powersave = false;
        };
        # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
        
        # Japan
        #nameservers = [ "130.161.158.4" "130.161.33.17" "192.168.2.1" ];

        #nameservers = [ "9.9.9.9" "1.1.1.1" "240d:1a:b20:200::1" ];

        #resolvconf.enable = true;

        #usePredictableInterfaceNames = false;
        # Configure network proxy if necessary
        # networking.proxy.default = "http://user:password@proxy:port/";
        # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

        # Or disable the firewall altogether.
        firewall = {
            enable = true;
            trustedInterfaces = [ "virbr0" ];
        };
        # Open ports in the firewall.
        firewall.allowedTCPPorts = [ 25565 9000 80 21 22 20 ];
        #firewall.allowedUDPPorts = [ 25565 9000 ];
    };

    #programs.openvpn3.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Copenhagen";

    # Japan
    # time.timeZone = "Asia/Tokyo";
    time.hardwareClockInLocalTime = true;
    services.timesyncd.enable = true;

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
                addons = with pkgs; [
                    fcitx5-mozc
                    fcitx5-hangul
                ];
            };
        };
    };

    services = {
        # EPP stuff
        #auto-epp = {
        #    enable = true;
        #    package = pkgs.auto-epp;
        #    settings = {
        #        Settings = {
        #            epp_state_for_AC = "balance_performance";
        #            epp_state_for_BAT = "power";
        #        };
        #    };
        #};
        # Enable TLP
        tlp = {
            enable = true;
            pd = {
                enable = true;
                #package = pkgs.tlp-pd;
            };
            settings = {
                # CPU governor
                CPU_SCALING_GOVERNOR_ON_AC = "performance";
                CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

                # EPP policy
                CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
                CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

                # CPU Boost policy
                CPU_BOOST_ON_AC = 1;
                CPU_BOOST_ON_BAT = 0;

                # CPU frequency limits (in kHz)
                #CPU_SCALING_MAX_FREQ_ON_AC = 3300000;
                CPU_SCALING_MAX_FREQ_ON_AC = 0;
                CPU_SCALING_MAX_FREQ_ON_BAT = 1500000; # 1800000

                # iGPU DPM performance level
                RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
                RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

                # USB autosuspend
                USB_AUTOSUSPEND = 1;
                USB_EXCLUDE_WWAN = 0;

                # PCIe ASPM
                PCIE_ASPM_ON_AC = "default";
                PCIE_ASPM_ON_BAT = "powersupersave";

                # Wi-Fi powersave
                WIFI_PWR_ON_AC = "off";
                WIFI_PWR_ON_BAT = "on";

                # Disable platform power saving on AC
                #PLATFORM_PROFILE_ON_AC = "performance";
                PLATFORM_PROFILE_ON_AC = "balanced";
                PLATFORM_PROFILE_ON_BAT = "quiet";
            };
        };
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
            wacom.enable = true;
        };
        displayManager = {
            enable = true;
            defaultSession = "niri";
            ly.enable = false;
            sddm = {
                enable = true;
                wayland.enable = true;
            };
            cosmic-greeter.enable = false;
        };
        # Enable touchpad support (enabled default in most desktopManager).
        libinput.enable = true;
        desktopManager = {
            cosmic.enable = true;
            plasma6.enable = true;
            gnome.enable = false;
        };
        #dockerRegistry.enable = true;
        # Enable Asus Numpad Service
        asus-numberpad-driver = {
            enable = true;
            layout = "gx551";
            wayland = true;
            #runtimeDir = "/run/user/1000/";
            waylandDisplay = "wayland-1";
            #ignoreWaylandDisplayEnv = false;
            config = {
                # e.g. "activation_time" = "0.5";
                "activation_time" = "0.0";
                # More Configuration Options

                # enabled = 0
                # disable_due_inactivity_time = 120
                # touchpad_disables_numpad = 1
                # sys_numlock_enables_numpad = 1
                # numpad_disables_sys_numlock = 1
                # enabled_touchpad_pointer = 3
                "press_key_when_is_done_untouch" = "1";

                # key_repetitions = 0
                # multitouch = 0
                # one_touch_key_rotation = 0
                # activation_time = 1
                # brightness = 0x41
                # distance_to_move_only_pointer = 250

                # top_left_icon_activation_time = 1
                # top_left_icon_slide_func_activation_radius = 1200
                # top_left_icon_slide_func_activates_numpad = 1
                # top_left_icon_brightness_func_max_min_only = 1
                # top_left_icon_brightness_func_disabled = 0
                # top_left_icon_slide_func_disabled = 0

                # top_right_icon_slide_func_activation_radius = 1200
                # top_right_icon_coactivator_key = Shift

                # default_backlight_level = 0x01

                # idled = 0
                # idle_brightness = 30
                # idle_time = 30
                # idle_enabled = 0
            };
        };
    };

    # Enable supergfxd power daemon
    systemd.services.supergfxd = {
        enable = true;
        path = [ pkgs.pciutils ];
    };
    services = {
        power-profiles-daemon.enable = false;
        supergfxd.enable = true;
    };

    # Configure console keymap
    console.useXkbConfig = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound using pipewire.
    #hardware.pulseaudio.enable = false;
    #hardware.pulseaudio.support32Bit = false;

    security.polkit.enable = true;
    #security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
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
    users = {
        defaultUserShell = pkgs.zsh;
        groups = {
            libvirtd.members = [ "mikkel" ];
        };
        users.mikkel = {
            isNormalUser = true;
            home = "/home/mikkel";
            description = "mikkel";
            extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "docker" "bluetooth" "dialout" ];
        };
    };

    # Allow unfree packages
    nixpkgs.config = {
        allowUnfree = true;
        allowBroken = false;
        permittedInsecurePackages = [
            "dotnet-sdk-6.0.428"
            "electron-40.10.5"
        ];
    };

    nix = {
        enable = true;
        package = pkgs.nixVersions.latest; #pkgs.lix;
        channel.enable = false;
        # add some flake inputs to the nix-registry for nix search
        registry = {
            nixpkgs.flake = inputs.nixpkgs;
            #hyprland.flake = inputs.hyprland;
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
            includeAllModules = false;
        };
        man = {
            enable = true;
            cache.enable = true;
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

    # enable cpak
    services.cpak.enable = true;


    # Extra xdg portals
    xdg = {
        #sounds.enable = true;
        #mime = {
        #    enable = true;
        #    #defaultApplications = { "application/pdf" = "firefox.desktop"; "image/png" = «thunk»; };
        #};
        #menus.enable = true;
        #icons.enable = true;
        portal = {
            enable = true;
            xdgOpenUsePortal = true;
            extraPortals = [
                pkgs.xdg-utils
                #pkgs.xdg-dbus-proxy
                pkgs.xdg-desktop-portal-gtk
                pkgs.xdg-desktop-portal-gnome
                #pkgs.xdg-desktop-portal-cosmic
                #pkgs.kdePackages.xdg-desktop-portal-kde
            ];
            configPackages = [
                pkgs.xdg-desktop-portal-gtk
                #pkgs.xdg-desktop-portal-cosmic
            ];
            config = {
                common = {
                    default = [
                        "gtk"
                    ];
                };
            };
        };
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
                gamer = "git";
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
            #autoStart = false;
        };
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                # libraries to make available for dynamicly linked programs
            ];
        };
        uwsm.enable = false;
        #hyprland = {
        #    enable = false;
        #    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override{ debug = true; }; #inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override{ debug = true; }; #inputs.hyprland.packages.${pkgs.system}.hyprland;
        #    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        #    withUWSM = false;
        #    xwayland.enable = true;
        #};
        #hyprlock = {
        #    enable = false;
        #    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
        #};
        steam = {
            enable = true;
            package = pkgs.steam.override {
                extraProfile = ''
                    export PROTON_ENABLE_NVAPI=1
                    export PROTON_HIDE_NVIDIA_GPU=0
                    export PROTON_USE_WOW64=1
                    export PROTON_USE_NTSYNC=1
                    export PROTON_ENABLE_WAYLAND=1
                    export PROTON_DXVK_LOWLATENCY=1
                '';
                #export MANGOHUD=1
                #extraEnv = {
                #  MANGOHUD = true;
                #  OBS_VKCAPTURE = true;
                #  RADV_TEX_ANISO = 16;
                #};
                #extraLibraries = p: with p; [
                #  atk
                #];
            };
            extest.enable = true;
            protontricks.enable = true;
            gamescopeSession.enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
            localNetworkGameTransfers.openFirewall = true;
            fontPackages = with pkgs; [
                source-han-sans
                wqy_zenhei
            ];
            extraPackages = with pkgs; [
            ];
        };
        gamescope = {
            enable = true;
            capSysNice = false;
        };
        gamemode.enable = true;
        direnv = {
            enable = true;
            #package = pkgs.nix-direnv;
            silent = true;
            nix-direnv.enable = true;
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
        niri = {
            enable = true;
            package = pkgs.niri;
            #package = pkgs.niri-unstable;
        };
        zoxide = {
            enable = true;
            enableZshIntegration = true;
            enableBashIntegration = true;
        };
        zoom-us.enable = false;
    };

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
            pciutils
            flac
            fastfetch
            bc
            file
            bat
            stable.anki
            mercurial
            cargo
            rustc
            pandoc
            #texliveSmall
            R
            #(inputs.nixpkgs-zig.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zig_0_14)
            #pkgs.zigpkgs.master
            cachix
            go
            openjdk
            openjdk8
            openjdk25
            (with dotnetCorePackages; combinePackages [
                sdk_10_0
                sdk_9_0
                sdk_8_0
                sdk_6_0
                aspnetcore_10_0
                aspnetcore_9_0
                aspnetcore_8_0
            ])
            dotnetPackages.Nuget
            #azure-cli
            #nodePackages_latest.nodejs
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
            lazysql
            # other apps
            ncspot
            #jetbrains.clion
            #jetbrains.rider
            #jetbrains.rust-rover
            #jetbrains.dataspell
            #jetbrains.idea
            #jetbrains.datagrip
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
                    vscode-extensions.platformio.platformio-vscode-ide
                ];
            })
            #unityhub
            stable.godotPackages_4.godot-mono
            gparted
            ffmpeg_7
            xwayland-satellite
            gnumake
            cmake
            opencv
            htop
            #btop
            btop-cuda
            #btop-rocm
            # native wayland support (unstable)
            wineWow64Packages.full
            #wineWow64Packages.waylandFull
            # --- Drop a wine64 alias into your config (the workaround from the nix-gaming issue) [^76716e#42-50]: ---
            (pkgs.runCommand "wine64-alias" {} ''
                mkdir -p $out/bin
                ln -s ${pkgs.wineWow64Packages.full}/bin/wine $out/bin/wine64
            '')
            #winePackages.waylandFull
            #winePackages.full
            # winetricks (all versions)
            winetricks
            # wine-staging (version with experimental features)
            #wineWow64Packages.stagingFull
            steamcmd
            #steam-tui
            mono
            lua
            zip
            (discord-canary.override {
                withOpenASAR = true;
                withVencord = true;
            })
            (discord.override {
                withOpenASAR = true;
                withVencord = true;
            })
            discordo
            vesktop
            spotify
            spotify-player
            nasm
            lf
            ranger
            exfat
            exfatprogs
            prismlauncher
            (python314.withPackages(ps: with ps; [
                pip
                matplotlib
                dbus-python
            ]))
            coreutils
            libreoffice
            #onlyoffice-desktopeditors
            vlc
            mpv
            inputs.firefox-nightly.packages.${pkgs.system}.firefox-nightly-bin
            firefox-devedition
            librewolf
            trilium-desktop
            #heroic
            heroic-unwrapped
            stable.rpcs3
            osu-lazer-bin
            #virtual manager
            qemu
            qemu-utils
            virglrenderer
            OVMFFull
            #other
            gimp3
            stable.krita
            blender
            drawio
            obs-studio
            lshw
            bluez
            bluez-tools
            #gtk4
            #gtk4-layer-shell
            kdePackages.kate
            kdePackages.dolphin
            kdePackages.ark
            kdePackages.ktorrent
            kdePackages.partitionmanager
            kdePackages.spectacle
            kdePackages.kdenlive
            kdePackages.kdeconnect-kde
            kdePackages.okular
            kdePackages.k3b
            haruna
            nautilus
            #openhmd
            openvr
            brightnessctl
            sixpair
            jstest-gtk
            # wm stuff
            waybar
            pavucontrol
            #ncpamixer
            dunst
            #mako
            fuzzel
            playerctl
            hyprpaper
            rofi
            inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
            wl-gammarelay-rs
            wl-gammarelay-applet

            airshipper
            #vintagestory
            stable.freecad-wayland
            #stable.cura
            #kicad
            steamtinkerlaunch
            mangohud
            #polychromatic
            #razergenie
            r2modman
            wireshark
            android-tools

            protonup-qt
            protonup-rs
            qpwgraph
            kew
            dbgate
            devenv
            
            #nvtopPackages.nvidia

            quick-webapps
            oboete
            flatpak-builder
            #flatpak-builder-tools

            easyeffects
            
            wireguard-tools           

            platformio
            platformio-core
            platformio-chrootenv

            #arcanechat-tui

            papers
            komikku

            winboat

            chameleos

            proton-vpn
            proton-vpn-cli

            jellyfin-desktop
            jellyfin
            jellyfin-web
            jellyfin-ffmpeg

            # --- power usage testing stuff ---
            amdctl

            simulide_1_2_0

            # ---  ---
            #collabora-desktop

            # --- note taking ---
            (pkgs.quarto.overrideAttrs (oldAttrs: {
              postPatch = (oldAttrs.postPatch or "") + ''
                substituteInPlace bin/quarto.js \
                  --replace-fail "syntax-highlighting" "highlight-style"
              '';
            }))
            #quarto
            typst
            tectonic
            texliveFull
        ] ++ (import ./jetbrains.nix { inherit pkgs; }).jetbrainsPackages;

        variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
        };
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


    virtualisation = {
        docker = {
            enable = true;
            enableOnBoot = true;
            #storageDriver = "ext4";
            rootless = {
                enable = true;
                setSocketVariable = true;
            };
        };
        libvirtd = {
            enable = true;
            qemu = {
                package = pkgs.qemu_kvm;
                swtpm.enable = true;
            };
        };
        spiceUSBRedirection.enable = true;
        # --- vmware currently blocks cachy kernel from building ---
        #vmware.host.enable = true;
    };


    specialisation = {
        #travel.configuration = {
        #    # --- Kernel: power-saving parameters ---
        #    boot.kernelParams = lib.mkForce [
        #        "nvidia_drm.fbdev=1"
        #        "nvidia_drm.modeset=1"
        #        "amdgpu.dcfeaturemask=0x8"        # Panel Self Refresh (PSR)
        #        "mem_sleep_default=deep"
        #        "pcie_aspm=powersupersave"
        #        "nmi_watchdog=0"
        #        "nowatchdog"
        #    ];

        #    # --- CPU governor ---
        #    #powerManagement.cpuFreqGovernor = "powersave";

        #    # --- Keep your existing power daemons ---
        #    #services.power-profiles-daemon.enable = lib.mkForce true;
        #    #services.auto-epp.enable = lib.mkForce true;
        #    #services.auto-epp.settings.Settings = {
        #    #    epp_state_for_AC = "balance_performance";
        #    #    epp_state_for_BAT = "power";
        #    #};

        #    # --- NVIDIA PRIME Offload: iGPU drives display, dGPU sleeps when idle ---
        #    services.xserver.videoDrivers = lib.mkForce [ "amdgpu" "nvidia" ];
        #    hardware.nvidiaOptimus.disable = lib.mkForce true;
        #    hardware.nvidia = {
        #        prime.sync.enable = lib.mkForce false;
        #        prime.offload = {
        #            enable = lib.mkForce true;
        #            enableOffloadCmd = lib.mkForce true;
        #        };
        #        powerManagement = {
        #            enable = lib.mkForce true;
        #            finegrained = lib.mkForce true;
        #        };
        #    };

        #    # --- Keep networking and radio as in base config ---
        #    networking.networkmanager.wifi.powersave = lib.mkForce false;
        #    hardware.bluetooth.enable = lib.mkForce true;

        #    # --- Keep Flatpak ---
        #    services.flatpak.enable = lib.mkForce true;

        #    # --- Disable only heavy background services you do not need while mobile ---
        #    virtualisation.docker.enable = lib.mkForce false;
        #    virtualisation.libvirtd.enable = lib.mkForce false;
        #    services.printing.enable = lib.mkForce true;
        #    services.openssh.enable = lib.mkForce false;
        #};
        #no-nvidia.configuration = {
        #    # Strip NVIDIA kernel params inherited from base config
        #    boot.kernelParams = lib.mkForce (
        #        lib.filter (p: !(lib.hasPrefix "nvidia_drm" p)) config.boot.kernelParams
        #    );

        #    # Do not build or include the NVIDIA kernel module
        #    boot.extraModulePackages = lib.mkForce (
        #        lib.filter (p: p != config.boot.kernelPackages.nvidia_x11_beta) config.boot.extraModulePackages
        #    );

        #    # Block every NVIDIA module
        #    boot.blacklistedKernelModules = [
        #        "nouveau"
        #        "nvidia"
        #        "nvidia_drm"
        #        "nvidia_modeset"
        #        "nvidia_uvm"
        #    ];

        #    boot.extraModprobeConfig = lib.mkForce ''
        #        blacklist nouveau
        #        blacklist nvidia
        #        blacklist nvidia_drm
        #        blacklist nvidia_modeset
        #        blacklist nvidia_uvm
        #        blacklist nvidiafb
        #        options nouveau modeset=0
        #    '';

        #    # Force AMD iGPU only
        #    services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];

        #    # Disable all NVIDIA options
        #    hardware.nvidiaOptimus.disable = lib.mkForce true;
        #    hardware.nvidia = {
        #        # Use the NVidia open source kernel module (not to be confused with the
        #        # independent third-party "nouveau" open source driver).
        #        # Support is limited to the Turing and later architectures. Full list of 
        #        # supported GPUs is at: 
        #        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
        #        # Only available from driver 515.43.04+
        #        # Do not disable this unless your GPU is unsupported or if you have a good reason to.
        #        #open = true;

        #        # Enable the Nvidia settings menu,
        #        # accessible via `nvidia-settings`.
        #        #nvidiaSettings = lib.mkForce false;
        #        open = lib.mkForce false;
        #        nvidiaSettings = lib.mkForce false;
        #        modesetting.enable = lib.mkForce false;
        #        package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;
        #        prime = {
        #          offload = {
        #            enable = lib.mkForce false;
        #            enableOffloadCmd = lib.mkForce false;
        #          };
        #          sync.enable = lib.mkForce false;
        #        };
        #        powerManagement = {
        #          enable = lib.mkForce false;
        #          finegrained = lib.mkForce false;
        #        };
        #    };

        #    # Disable supergfxd so it doesn't try to manage the dGPU
        #    services.supergfxd.enable = lib.mkForce false;
        #    systemd.services.supergfxd.enable = lib.mkForce false;

        #    # Remove NVIDIA PCI devices so they don't consume power
        #    services.udev.extraRules = ''
        #        # Remove NVIDIA USB xHCI Host Controller devices, if present
        #        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        #        
        #        # Remove NVIDIA USB Type-C UCSI devices, if present
        #        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        #        
        #        # Remove NVIDIA Audio devices, if present
        #        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        #        
        #        # Remove NVIDIA VGA/3D controller devices
        #        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
        #    '';
        #};
        ## All the power
        extreme-power-save.configuration = {
            boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
            # --- Kernel: power-saving parameters ---
            # Strip NVIDIA kernel params inherited from base config
            boot.kernelParams = lib.mkForce (
                [
                    "amdgpu.dcfeaturemask=0x8"        # Panel Self Refresh (PSR)
                    "mem_sleep_default=deep"
                    # "pcie_aspm=powersupersave"
                    "nmi_watchdog=0"
                    "nowatchdog"
                    # "usbcore.autosuspend=2" # not sure if usb autosuspend is too usefull
                ] ++ lib.filter (p: !(lib.hasPrefix "nvidia_drm" p)) config.boot.kernelParams
            );
            
            # Do not build or include the NVIDIA kernel module
            boot.extraModulePackages = lib.mkForce [];
            #boot.extraModulePackages = lib.mkForce (
            #    lib.filter (p: p != config.boot.kernelPackages.nvidia_x11_beta) config.boot.extraModulePackages
            #);

            # Block every NVIDIA module
            boot.blacklistedKernelModules = [
                "nouveau"
                "nvidia"
                "nvidia_drm"
                "nvidia_modeset"
                "nvidia_uvm"
            ];

            boot.extraModprobeConfig = lib.mkForce ''
                blacklist nouveau
                blacklist nvidia
                blacklist nvidia_drm
                blacklist nvidia_modeset
                blacklist nvidia_uvm
                blacklist nvidiafb
                options nouveau modeset=0
            '';
            #options amdgpu power_dpm_force_performance_level=low

            # --- CPU governor ---
            #powerManagement.cpuFreqGovernor = "powersave";

            # --- Disable existing power daemons ---
            #services.power-profiles-daemon.enable = lib.mkForce false;
            #services.auto-epp.enable = lib.mkForce false;
            #services.auto-epp.settings.Settings = {
            #    epp_state_for_AC = "balance_performance";
            #    epp_state_for_BAT = "power";
            #};

            # Force AMD iGPU only
            services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];

            services.displayManager = {
                defaultSession = lib.mkForce "cosmic";
                sddm = {
                    enable = lib.mkForce false;
                    #wayland.enable = true;
                };
                cosmic-greeter.enable = lib.mkForce true;
            };
            services.desktopManager = {
                cosmic.enable = lib.mkForce true;
                plasma6.enable = lib.mkForce true;
                gnome.enable = lib.mkForce false;
            };

            # Disable all NVIDIA options
            hardware.nvidiaOptimus.disable = lib.mkForce true;
            hardware.nvidia = {
                open = lib.mkForce false;
                nvidiaSettings = lib.mkForce false;
                modesetting.enable = lib.mkForce false;
                package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;
                prime = {
                    offload = {
                        enable = lib.mkForce false;
                        enableOffloadCmd = lib.mkForce false;
                    };
                    sync.enable = lib.mkForce false;
                };
                powerManagement = {
                    enable = lib.mkForce false;
                    finegrained = lib.mkForce false;
                };
            };

            # Disable supergfxd so it doesn't try to manage the dGPU
            services.supergfxd.enable = lib.mkForce false;
            systemd.services.supergfxd.enable = lib.mkForce false;

            # Remove NVIDIA PCI devices so they don't consume power
            services.udev.extraRules = ''
                # Remove NVIDIA USB xHCI Host Controller devices, if present
                ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
                
                # Remove NVIDIA USB Type-C UCSI devices, if present
                ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
                
                # Remove NVIDIA Audio devices, if present
                ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
                
                # Remove NVIDIA VGA/3D controller devices
                ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
            '';

            # --- Keep networking and radio as in base config ---
            networking.networkmanager.wifi.powersave = lib.mkForce true;
            hardware.bluetooth.enable = lib.mkForce false;

            # --- Keep Flatpak ---
            services.flatpak.enable = lib.mkForce true;

            # --- Disable only heavy background services you do not need while mobile ---
            #virtualisation.docker.enable = lib.mkForce false;
            #virtualisation.libvirtd.enable = lib.mkForce false;
            services.printing.enable = lib.mkForce false;
            services.openssh.enable = lib.mkForce false;
            
            # Enable TLP
            services.tlp = {
                enable = lib.mkForce true;
                settings = {
                    # CPU governor
                    CPU_SCALING_GOVERNOR_ON_AC = "performance";
                    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

                    # EPP policy
                    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
                    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

                    # CPU Boost policy
                    CPU_BOOST_ON_AC = 1;
                    CPU_BOOST_ON_BAT = 0;

                    # CPU frequency limits (in kHz)
                    #CPU_SCALING_MAX_FREQ_ON_AC = 3300000;
                    CPU_SCALING_MAX_FREQ_ON_AC = 0;
                    CPU_SCALING_MAX_FREQ_ON_BAT = 1500000; # 1800000

                    # iGPU DPM performance level
                    RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
                    RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

                    # USB autosuspend
                    USB_AUTOSUSPEND = 1;
                    USB_EXCLUDE_WWAN = 0;

                    # PCIe ASPM
                    PCIE_ASPM_ON_AC = "default";
                    PCIE_ASPM_ON_BAT = "powersupersave";

                    # Wi-Fi powersave
                    WIFI_PWR_ON_AC = "off";
                    WIFI_PWR_ON_BAT = "on";

                    # Disable platform power saving on AC
                    #PLATFORM_PROFILE_ON_AC = "performance";
                    PLATFORM_PROFILE_ON_AC = "balanced";
                    PLATFORM_PROFILE_ON_BAT = "quiet";
                };
            };

            # Aggressive CPU cap
            #systemd.services.cpu-freq-cap = {
            #    wantedBy = [ "multi-user.target" ];
            #    after = [ "systemd-modules-load.service" ];
            #    serviceConfig = {
            #        Type = "oneshot";
            #        RemainAfterExit = true;
            #        ExecStart = "${pkgs.linuxPackages_latest.cpupower}/bin/cpupower frequency-set -u 2000MHz"; # maybe try 1800MHz
            #    };
            #};

            # Force AMDGPU iGPU into low power profile
            #systemd.services.amdgpu-low-power = {
            #    wantedBy = [ "multi-user.target" ];
            #    after = [ "systemd-modules-load.service" ];
            #    serviceConfig = {
            #        Type = "oneshot";
            #        RemainAfterExit = true;
            #        ExecStart = pkgs.writeShellScript "amdgpu-low-power" ''
            #            for card in /sys/class/drm/card*/device; do
            #                if [ -f "$card/power_dpm_force_performance_level" ]; then
            #                    echo low > "$card/power_dpm_force_performance_level"
            #                fi
            #            done
            #        '';
            #    };
            #};
        };
        ## Jellyfin
        jellyfin.configuration = {
            services.jellyfin = {
                enable = lib.mkForce true;
                openFirewall = lib.mkForce true;
            };
        };
    };

    #services.postgresql = {
    #    enable = false;
    #    package = pkgs.postgresql_18;
    #    #ensureDatabases = [ "mydatabase" ];
    #    enableTCPIP = true;
    #    settings.port = 5432;
    #    authentication = pkgs.lib.mkOverride 10 ''
    #      #type database DBuser origin-address auth-method
    #      local all      all     trust
    #      # ... other auth rules ...

    #      # ipv4
    #      host  all      all     127.0.0.1/32   trust
    #      # ipv6
    #      host  all      all     ::1/128        trust
    #    '';
    #};

    # Enable the OpenSSH daemon.
    services.openssh = {
        enable = true;
        ports = [ 22 ];
        allowSFTP = false;
        sftpServerExecutable = "internal-sftp";
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
}
