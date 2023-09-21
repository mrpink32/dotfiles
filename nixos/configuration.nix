# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "nvidia" ]; # "amdgpu"
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

  hardware.nvidia = {

    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = true;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  
  hardware.enableAllFirmware = true;

  hardware.nvidia.powerManagement.enable = true;
  # hardware.nvidia.powerManagement.finegrained = true;

  # boot.kernelParams = [ "module_blacklist=amdgpu" ];

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

  fileSystems."/mnt/data" = { 
    device = "/dev/disk/by-partuuid/0115fc15-0f38-1d45-be7b-c5c3d3ef13da";
    fsType = "btrfs";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  # services.xserver.windowManager.openbox.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.displayManager.defaultSession = "plasmawayland";

  # Enable supergfxd power daemon
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [ pkgs.pciutils ];
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = caps:backspace;
  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;


  #***** Apparently not the correct way to enable pipewire https://nixos.wiki/wiki/PipeWire *****
  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikkel = {
    isNormalUser = true;
    description = "mikkel";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flatpak
  # services.flatpak.enable = true;

  # 
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-dbus-proxy
  ];

  # enable nix experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # 
    vim
    alacritty
    neovim
    git
    git-doc
    man
    wget
    wezterm

    # programming langs
    lld_16
    clang_16
    llvm_16
    lldb_16
    libllvm
    gcc
    rustup
    zig
    go
    jdk20
    jdk
    jdk17
    jdk11
    dotnet-sdk_7
    dotnet-sdk
    dotnet-sdk_8
    nodejs_20
    typescript

    # lsps
    zls
    rust-analyzer
    lua-language-server
    csharp-ls
    
    # dependencies
    alsa-oss
    alsa-lib
    alsaLib.dev
    alsa-utils
    alsa-tools
    alsa-firmware
    pango
    cairo



    ncspot
    kate
    jetbrains.clion
    jetbrains.rider
    jetbrains.idea-ultimate
    vscode
    lutris
    # unityhub
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
    mono
    lua
    zip
    qtcreator
    discord
    nasm
    wezterm
    lf
    pkg-config
    neofetch
    librewolf
    slic3r
    btop
    prismlauncher
    dbus
    (python311.withPackages(ps: with ps; [
      python311Packages.protonvpn-nm-lib
      dbus-python
      proxy-py
    ]))
    coreutils
    libreoffice
    onlyoffice-bin
    firefox-devedition

    discordo

    gtk4
    gtk4-layer-shell
    vieb
    protonvpn-gui
    protonvpn-cli
    networkmanager-openvpn

    dolphin
    libsForQt5.ark

    # wm stuff
    waybar
    dunst
    fuzzel
    playerctl
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };

  programs.bash.shellAliases = {
    repos = "cd /mnt/data/repositories";
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

  environment.etc = {
	  "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
		  context.properties = {
			  default.clock.rate = 48000
				  default.clock.quantum = 32
				  default.clock.min-quantum = 32
				  default.clock.max-quantum = 32
		  }
	  '';
  };

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
