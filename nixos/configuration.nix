# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = ["nvidia"];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware.enableAllFirmware = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  # ----- Nvidia options -----
  hardware.nvidia = {
    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = false;

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

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-partuuid/5ade5046-c81a-4e13-8243-12f95819492d";
    fsType = "btrfs";
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
  i18n.defaultLocale = "en_US.UTF-8";

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


  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
    displayManager.sddm.enable = true;
  
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "dvorak";
      options = "caps:backspace,shift:both_capslock,grp:win_space_toggle";
    };
  };

  # Enable supergfxd power daemon
  services.power-profiles-daemon.enable = true;
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [ pkgs.pciutils ];
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;


  #***** Apparently not the correct way to enable pipewire https://nixos.wiki/wiki/PipeWire *****
  # Enable sound with pipewire.
  sound.enable = true;
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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikkel = {
    isNormalUser = true;
    description = "mikkel";
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Extra xdg portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-dbus-proxy
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  # xdg.portal.extraPortals = [
  #   # pkgs.xdg-desktop-portal-hyprland
  #   pkgs.xdg-desktop-portal-gtk
  #   pkgs.xdg-dbus-proxy
  # ];

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;
  };

  # programs.hyprland = {
  #   enable = true;
  #   package = pkgs.hyprland;
  #   xwayland.enable = true;

  #   systemd.enable = true;
  # };

  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # enable nix experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  # };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim
    neovim
    kitty
    alacritty
    git
    git-doc
    man
    wget

    # programming langs
    lld
    clang
    clang-tools
    clang-manpages
    lldb
    libclang
    llvm_17
    libllvm
    llvm-manpages
    # llvmPackages_17.stdenv
    # llvmPackages_17.clang-manpages
    # llvmPackages_17.llvm-manpages
    # llvmPackages_17.lldb-manpages
    # llvmPackages_17.libllvm
    gcc
    rustup
    zig
    go
    jdk20
    jdk
    jdk11
    (with dotnetCorePackages; combinePackages [
      sdk_9_0
      sdk_8_0
      sdk_7_0
      sdk_6_0
    ])
    # dotnet-sdk_7
    # dotnet-sdk
    # dotnet-sdk_8
    nodejs_20
    typescript

    # lsps
    zls
    rust-analyzer
    lua-language-server
    csharp-ls
    omnisharp-roslyn
    
    # dependencies
    alsa-oss
    alsa-lib
    alsaLib.dev
    alsa-utils
    alsa-tools
    alsa-firmware
    pango
    cairo
    pkg-config
    gnome.adwaita-icon-theme
    unzip
    xdg-utils
    supergfxctl
    tree-sitter

    # other apps
    ncspot
    kate
    jetbrains.clion
    jetbrains.rider
    lutris
    webcord
    unityhub
    godot_4
    godot4-mono
    # godot3-mono
    ffmpeg
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
    protontricks
    mono
    lua
    zip
    discord
    spotify
    nasm
    lf
    neofetch
    librewolf
    slic3r
    btop
    prismlauncher
    dbus
    # python312
    # (pkgs.python3.withPackages (python-pkgs: [
    #   python-pkgs.pandas
    #   python-pkgs.requests
    # ]))
    (python312.withPackages(ps: with ps; [
      pip
      # (pip)
    ]))
    coreutils
    libreoffice
    onlyoffice-bin
    vlc
    mpv
    firefox-devedition
    freecad
    cura
    trilium-desktop
    heroic
    osu-lazer-bin
    protonvpn-gui
    protonvpn-cli

    virt-manager
    qemu
    qemu-utils
    virglrenderer
    OVMFFull

    gimp
    drawio
    obs-studio


    lshw
    discordo
    steam-tui

    bluez

    gtk4
    gtk4-layer-shell
    jetbrains-toolbox

    dolphin
    libsForQt5.ark

    asusctl

    bluetuith

    ungoogled-chromium
    # chromium

    # wm stuff
    waybar
    dunst
    fuzzel
    playerctl
    hyprpaper
    xwaylandvideobridge
    rofi
    rofi-wayland
    hyprcursor

    # custom packages
    # (import /mnt/data/repositories/wayland/src/default.nix)
    # (import /mnt/data/repositories/statusbar/c_test/default.nix)
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # libraries to make available for dynamicly linked programs
    ];
  };



  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      nerdfonts
      fira-code-nerdfont
      fira-code
      fira-code-symbols
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "jetbrains-mono" ];
        serif = [ "Noto Serif CJK JP" ];
        sansSerif = [ "Noto Sans CJK JP" ];
      };
    };
    fontDir.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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

  programs.bash.shellAliases = {
    repos = "cd /mnt/data/repositories";
    switch = "sudo nixos-rebuild switch";
    switch-update = "sudo nixos-rebuild switch --upgrade";
    boot-update = "sudo nixos-rebuild boot --upgrade";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  environment.variables = rec {
    EDITOR = "nvim";
    PATH = [
      # "/mnt/data/repositories/zig/zig-out/bin"
      # "/home/mikkel/Downloads/zig-linux-x86_64-0.12.0-dev"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
