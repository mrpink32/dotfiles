# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = true;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  # services.xserver.windowManager.openbox.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";

  # services.xserver = {
  #   desktopManager = {
  #     xterm.enable = false;
  #     xfce.enable = true;
  #   };
  #   displayManager.defaultSession = "xfce";
  # };

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
  #  elisa
  #  gwenview
  #  okular
  #  oxygen
  #  khelpcenter
    konsole
    plasma-browser-integration
  #  print-manager
    kwrited
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikkel = {
    isNormalUser = true;
    description = "mikkel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  firefox
    #  kate
    #  thunderbird
    ];
  };
  
  # Enable flatpak
  services.flatpak.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    alacritty
    neovim
    git
    wget
    vscode
    steam
    lutris
    lf
    ntfs3g
    jdk20
    jdk
    go
    zig
    zls
    rustup
    ncspot
    typescript
    gcc
    clang_16
    dotnet-sdk_8
    dotnet-sdk_7
    unityhub
    jetbrains-mono
  #  asusctl
    vivaldi
    vivaldi-ffmpeg-codecs
    ffmpeg
  #  minecraft
    nodejs_20
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    python311
    opencv
    # native wayland support (unstable)
    wineWowPackages.waylandFull
    # winetricks (all versions)
    winetricks
    # wine-staging (version with experimental features)
    wineWowPackages.staging
    lua
    qt6.full
    qt6.qtlanguageserver
    gnumake
    cmake
    jetbrains-toolbox
    zip
    jetbrains.clion
    jetbrains.dataspell
    minecraft
    python311Packages.jupyter
    qtcreator
    qtcreator-qt6
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  #  noto-fonts-emoji
  #  liberation_ttf
  #  fira-code
  #  fira-code-symbols
  #  mplus-outline-fonts.githubRelease
  #  dina-font
  #  proggyfonts
  ];
  fonts.fontDir.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/44bfd8a6-c0a1-420f-83c3-091863b237e7";
      fsType = "btrfs";
    };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
