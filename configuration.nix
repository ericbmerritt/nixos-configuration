# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options,... }:
let
  talpkgs = (builtins.fetchGit {
    url = "ssh://git@gitlab.com/talendant/talpkgs.git";
    ref = "v0.0.0-build.10.c82edc1";
  });
in {  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.initrd.luks.devices = [
   {
      name = "root";
      device = "/dev/nvme0n1p2";
      preLVM = true;
   }
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.throttled.enable = true;

  networking.hostName = "benedict"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.resolvconf.dnsExtensionMechanism = false;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  hardware.bluetooth.enable = true;

  # Select internationalisation properties.
  i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "dvorak";
     defaultLocale = "en_US.UTF-8";
  };
  nixpkgs.config.allowUnfree = true;
 
  virtualisation.docker.enable = true;   
 
  # Set your time zone.
  time.timeZone = "US/Pacific";

  nixpkgs.overlays = (import talpkgs);

  nix.nixPath =
    # Prepend default nixPath values.
    options.nix.nixPath.default ++ 
    # Append our nixpkgs-overlays.
    [ "nixpkgs-overlays=${talpkgs}/default.nix" ]
  ;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     firefox
     git
     networkmanagerapplet
     wget 
     curl
     vim
     which
     gnupg
     keybase
     keybase-gui
     zsh
     zsh-prezto
     emacs
     vscode
     zip
     unzip
     wget
     gnumake
     killall
     google-chrome
     cabal2nix
     nix-prefetch-git
     cabal-install
     haskellPackages.hpack
  ];

  # enable keybase
  services.keybase.enable = true;
  services.kbfs.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # ENABLE sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ]; 
  
  hardware.bluetooth.extraConfig = "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "ctrl:swapcaps";
  };

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
 
  services.dbus.packages = with pkgs; [ gnome3.dconf gnome2.GConf ];

  services.tlp.enable = true;

  users.users.eric = {
     isNormalUser = true;
     createHome = true;
     shell = pkgs.zsh;
     extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" "docker" ];
  };

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    source ${pkgs.zsh-prezto}/init.zsh

    # Custom Git Commands
    git config --global user.email "eric@merritt.tech" 2> /dev/null
    git config --global user.name "Eric B Merritt" 2> /dev/null
  '';
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

