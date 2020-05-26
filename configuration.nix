# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./cachix.nix
    <home-manager/nixos>
  ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };

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
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };
  i18n = { defaultLocale = "en_US.UTF-8"; };
  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "US/Pacific";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    neovim
    which
    gnupg
    keybase
    keybase-gui
    vscode
  ];

  # enable keybase
  services.keybase.enable = true;
  services.kbfs.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  services.printing.enable = true;

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

  hardware.bluetooth.config = {
    General = { Enable = "Source,Sink,Media,Socket"; };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "ctrl:swapescape";
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

  home-manager.users.eric = { pkgs, ... }: {
      home.packages = [
        pkgs.cachix
        pkgs.xclip
        pkgs.killall
        pkgs.tmux
        pkgs.emacs
        pkgs.neovim
        pkgs.firefox
        pkgs.google-chrome
        pkgs.gnome3.gnome-tweaks
	pkgs.par
	pkgs.riot-desktop
      ];
      nixpkgs.config.allowUnfree = true;
      programs.zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          theme = "bira";
        };
        sessionVariables = { EDITOR = "${pkgs.neovim}/bin/nvim"; };
      };

      programs.command-not-found.enable = true;

      programs.git = {
        package = pkgs.gitAndTools.gitFull;
        enable = true;
        userName = "Eric B. Merritt";
        userEmail = "eric@merritt.tech";
      };

      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultCommand =
          "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      };

      home.file = {
        ".tmux.conf" = {
          text = ''
                    # Mod+1..9: switch windows from 1 to 9
                    # Mod+, and Mod+.: switch to next/prev windows
                    # Mod+HJKL or arrows: switch between panes
                    # Mod+N: create new window
                    # Mod+F: toggle full-screen
                    # Mod+V: split vertically
                    # Mod+B: split horizontally (“bisect”)
                    # Mod+X: close pane
                    # Mod+/: enter copy and scroll mode
                    #
                    # Intuitive? Now, same hotkeys with Shift key are used to modify things:
                    #
                    # Mod+< and Mod+>: move current window to the left/right
                    # Mod+Shift+HJKL or arrows: move pane to the left/right/up/down
                    # Mod+Shift+X: close window
                    # Mod+Shift+R: rename window 
                    #
		    set -g focus-events on
                    set-option -g default-terminal screen-256color
                    set -g history-limit 10000
                    set -g base-index 1
                    set-option -g renumber-windows on
                    set -s escape-time 0
                    bind-key -n M-n new-window -c "#{pane_current_path}"
                    bind-key -n M-1 select-window -t :1
                    bind-key -n M-2 select-window -t :2
                    bind-key -n M-3 select-window -t :3
                    bind-key -n M-4 select-window -t :4
                    bind-key -n M-5 select-window -t :5
                    bind-key -n M-6 select-window -t :6
                    bind-key -n M-7 select-window -t :7
                    bind-key -n M-8 select-window -t :8
                    bind-key -n M-9 select-window -t :9
                    bind-key -n M-0 select-window -t :0
                    bind-key -n M-. select-window -n
                    bind-key -n M-, select-window -p
                    bind-key -n M-< swap-window -t -1
                    bind-key -n M-> swap-window -t +1
                    bind-key -n M-X confirm-before "kill-window"
                    bind-key -n M-v split-window -h -c "#{pane_current_path}"
                    bind-key -n M-b split-window -v -c "#{pane_current_path}"
                    bind-key -n M-R command-prompt -I "" "rename-window '%%'"
                    bind-key -n M-f resize-pane -Z
                    bind-key -n M-h select-pane -L
                    bind-key -n M-l select-pane -R
                    bind-key -n M-k select-pane -U
                    bind-key -n M-j select-pane -D
                    bind-key -n M-Left select-pane -L
                    bind-key -n M-Right select-pane -R
                    bind-key -n M-Up select-pane -U
                    bind-key -n M-Down select-pane -D
                    bind-key -n "M-H" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -L; tmux swap-pane -t $old'
                    bind-key -n "M-J" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -D; tmux swap-pane -t $old'
                    bind-key -n "M-K" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -U; tmux swap-pane -t $old'
                    bind-key -n "M-L" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -R; tmux swap-pane -t $old'
                    bind-key -n "M-S-Left" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -L; tmux swap-pane -t $old'
                    bind-key -n "M-S-Down" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -D; tmux swap-pane -t $old'
                    bind-key -n "M-S-Up" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -U; tmux swap-pane -t $old'
                    bind-key -n "M-S-Right" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -R; tmux swap-pane -t $old'
                    bind-key -n M-x confirm-before "kill-pane"
                    bind-key -n M-/ copy-mode
 
                    # Linux system clipboard
                    bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
                    bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "xclip -in -selection clipboard"

                    set -g mouse on
                    set-option -g status-keys vi
                    set-option -g set-titles on
                    set-option -g set-titles-string 'tmux - #W'
                    set -g bell-action any
                    set-option -g visual-bell off
                    set-option -g set-clipboard off
                    setw -g mode-keys vi
                    setw -g monitor-activity on
                    set -g visual-activity on
                    set -g status-style fg=colour15
                    set -g status-justify centre
                    set -g status-left '''
                    set -g status-right '''
                    set -g status-interval 1
                    set -g message-style fg=colour0,bg=colour3
                    setw -g window-status-bell-style fg=colour1
                    setw -g window-status-current-style fg=yellow,bold
                    setw -g window-status-style fg=colour250
                    setw -g window-status-current-format ' #{?#{==:#W,#{b:SHELL}},#{b:pane_current_path},#W} '
                    setw -g window-status-format ' #{?#{==:#W,#{b:SHELL}},#{b:pane_current_path},#W} '
          '';
        };

      };

    };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

