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
    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.kernelModules = ["nvidia"];
    boot.initrd.systemd.dbus.enable = true;
    boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

    hardware.enableAllFirmware = true;
    hardware.bluetooth.enable = true;
    #hardware.bluetooth.settings = {General = { Experimental = "true"; }; };

    hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
    };

    # Tell Xorg to use the nvidia driver (also valid for Wayland)
    services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

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
            # offload = {
            #   enable = true;
            #   enableOffloadCmd = false;
            # };

            # Make sure to use the correct Bus ID values for your system!
            amdgpuBusId = "PCI:7:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = true;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.beta;# stable; # vulkan_beta
    };

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Copenhagen";

    # Select internationalisation properties.
    i18n.defaultLocale = "ja_JP.UTF-8";

    i18n.extraLocaleSettings = {
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

    services = {
        displayManager.sddm = {
            enable = true;
            wayland.enable = true;
            #package = pkgs.kdePackages.sddm;
            enableHidpi = true;
        };
        # Enable touchpad support (enabled default in most desktopManager).
        libinput.enable = true;
        desktopManager.plasma6.enable = true;
    };

    # Enable the X11 windowing system.
    services.xserver = {
        enable = true;
        autorun = true;

        # Configure keymap in X11
        xkb = {
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
    #console.keyMap = "dvorak";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound using pipewire.
    sound.enable = false;
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
    nixpkgs.config.allowUnfree = true;

    # enable nix experimental features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Extra xdg portals
    xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [
            pkgs.xdg-utils
            pkgs.xdg-dbus-proxy
            pkgs.xdg-desktop-portal-cosmic
            pkgs.xdg-desktop-portal-gtk
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
                shell = "nix-shell";
                build = "nix-build";
                switch = "sudo nixos-rebuild switch";
                switch-update = "sudo nixos-rebuild switch --upgrade";
                boot-update = "sudo nixos-rebuild boot --upgrade";
                update-inputs = "nix flake update /etc/nixos";
            };
            shellInit = "fastfetch";
        };
        bash = {
            enableCompletion = true;
            shellAliases = {
                repos = "cd /mnt/data/repositories";
                shell = "nix-shell";
                build = "nix-build";
                switch = "sudo nixos-rebuild switch";
                switch-update = "sudo nixos-rebuild switch --upgrade";
                boot-update = "sudo nixos-rebuild boot --upgrade";
                update-inputs = "nix flake update /etc/nixos";
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
            package = inputs.hyprland.packages.${pkgs.system}.hyprland;
            xwayland.enable = true;
        };
        steam = {
            enable = true;
            extest.enable = true;
            gamescopeSession.enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        };
    };

    # List packages installed in system profile. To search, run:
    environment.systemPackages = [ #with pkgs;
        pkgs.vim
        pkgs.alacritty
        pkgs.zellij
        pkgs.git
        pkgs.git-doc
        pkgs.man
        pkgs.man-pages
        pkgs.wget
        pkgs.fastfetch
        pkgs.hydra-check
        # programming langs
        pkgs.lld_18
        pkgs.clang_18
        pkgs.clang-tools_18
        pkgs.lldb_18
        pkgs.llvm_18
        pkgs.llvmPackages_18.clang-unwrapped
        pkgs.llvmPackages_18.stdenv
        pkgs.llvmPackages_18.llvm-manpages
        pkgs.llvmPackages_18.clang-manpages
        pkgs.llvmPackages_18.lldb-manpages
        pkgs.llvmPackages_18.libllvm
        pkgs.libclang
        pkgs.zig_0_12
        pkgs.go
        pkgs.jdk22
        pkgs.jdk
        (with pkgs.dotnetCorePackages; combinePackages [
            sdk_9_0
            sdk_8_0
            sdk_7_0
            sdk_6_0
        ])
        pkgs.dotnetPackages.Nuget
        pkgs.nodejs_20
        pkgs.typescript
        # dependencies
        pkgs.alsa-oss
        pkgs.alsa-lib
        pkgs.alsaLib.dev
        pkgs.alsa-utils
        pkgs.alsa-tools
        pkgs.alsa-firmware
        pkgs.pango
        pkgs.cairo
        pkgs.pkg-config
        pkgs.gnome.adwaita-icon-theme
        pkgs.unzip
        pkgs.unrar
        pkgs.xdg-utils
        pkgs.supergfxctl
        pkgs.tree-sitter
        # other apps
        pkgs.ncspot
        pkgs.kate
        pkgs.jetbrains.clion
        pkgs.jetbrains.rider
        pkgs.jetbrains-toolbox
        pkgs.lutris
        pkgs.unityhub
        #pkgs.godot_4
        (pkgs.callPackage "${inputs.nixpkgs-godot}/pkgs/development/tools/godot/4/mono" { }) #.override { withTouch = false; })
        pkgs.gparted
        pkgs.ffmpeg
        pkgs.gnumake
        pkgs.cmake
        pkgs.opencv
        pkgs.htop
        # native wayland support (unstable)
        pkgs.wineWowPackages.waylandFull
        # winetricks (all versions)
        pkgs.winetricks
        # wine-staging (version with experimental features)
        pkgs.wineWowPackages.staging
        pkgs.protontricks
        pkgs.mono
        pkgs.lua
        pkgs.zip
        (pkgs.discord.override {
            withOpenASAR = true;
            withVencord = true;
        })
        (pkgs.discord-canary.override {
            withOpenASAR = true;
            withVencord = true;
        })
        pkgs.spotify
        pkgs.nasm
        pkgs.lf
        pkgs.slic3r
        pkgs.btop
        pkgs.prismlauncher
        (pkgs.python312.withPackages(ps: with ps; [
            pip
        ]))
        pkgs.coreutils
        pkgs.libreoffice
        pkgs.onlyoffice-bin
        pkgs.vlc
        pkgs.mpv
        pkgs.firefox-devedition
        pkgs.librewolf
        pkgs.freecad
        pkgs.cura
        pkgs.trilium-desktop
        pkgs.heroic
        pkgs.osu-lazer-bin
        pkgs.protonvpn-gui
        pkgs.protonvpn-cli
        #virtual manager
        pkgs.virt-manager
        pkgs.qemu
        pkgs.qemu-utils
        pkgs.virglrenderer
        pkgs.OVMFFull
        #other
        pkgs.gimp
        pkgs.drawio
        pkgs.obs-studio
        pkgs.lshw
        pkgs.discordo
        pkgs.steam-tui
        pkgs.bluez
        pkgs.bluez-tools
        pkgs.gtk4
        pkgs.gtk4-layer-shell
        pkgs.kdePackages.dolphin
        pkgs.kdePackages.ark
        pkgs.kdePackages.ktorrent
        pkgs.kdePackages.partitionmanager
        pkgs.openhmd
        pkgs.openvr
        pkgs.asusctl
        pkgs.brightnessctl
        pkgs.ungoogled-chromium
        pkgs.sixpair
        pkgs.jstest-gtk
        # wm stuff
        pkgs.waybar
        pkgs.dunst
        pkgs.fuzzel
        pkgs.playerctl
        pkgs.hyprpaper
        pkgs.xwaylandvideobridge
        pkgs.rofi
        pkgs.rofi-wayland
        # cosmic
        pkgs.cosmic-term
        pkgs.cosmic-edit
        pkgs.cosmic-files
        pkgs.cosmic-screenshot
        pkgs.webcord-vencord
        #kicad
        #pkgs.kicad
        pkgs.kicad-unstable
        #pkgs.kicad-testing
        pkgs.steamtinkerlaunch
        pkgs.calibre
        pkgs.vesktop

        # custom packages
        # (import /mnt/data/repositories/wayland/src/default.nix)
        # (import /mnt/data/repositories/statusbar/c_test/default.nix)
    ];

    services.monado.enable = true;

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

    #programs.zsh = {
    #    enable = true;
    #    enableCompletion = true;
    #    enableBashCompletion = true;
    #    autosuggestions.enable = true;
    #    shellAliases = {
    #        repos = "cd /mnt/data/repositories";
    #        shell = "nix-shell";
    #        build = "nix-build";
    #        switch = "sudo nixos-rebuild switch";
    #        switch-update = "sudo nixos-rebuild switch --upgrade";
    #        boot-update = "sudo nixos-rebuild boot --upgrade";
    #        update-inputs = "nix flake update /etc/nixos";
    #    };
    #    shellInit = "fastfetch";
    #};
    #programs.bash = {
    #    enableCompletion = true;
    #    shellAliases = {
    #        repos = "cd /mnt/data/repositories";
    #        shell = "nix-shell";
    #        build = "nix-build";
    #        switch = "sudo nixos-rebuild switch";
    #        switch-update = "sudo nixos-rebuild switch --upgrade";
    #        boot-update = "sudo nixos-rebuild boot --upgrade";
    #        update-inputs = "nix flake update /etc/nixos";
    #    };
    #};
    #programs.tmux = {
    #    enable = true;
    #    clock24 = true;
    #};
    #programs.nix-ld = {
    #    enable = true;
    #    libraries = with pkgs; [
    #        # libraries to make available for dynamicly linked programs
    #    ];
    #};
    #programs.hyprland = {
    #    enable = true;
    #    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    #    xwayland.enable = true;
    #};
    #programs.steam = {
    #    enable = true;
    #    extest.enable = true;
    #    gamescopeSession.enable = true;
    #    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    #};

    # Enable the OpenSSH daemon.
    services.openssh.enable = false;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = true;

    environment.variables = rec {
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
