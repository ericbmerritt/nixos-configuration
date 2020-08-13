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
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  home-manager.users.eric = { pkgs, ... }:
    let glab = (pkgs.callPackage ./glab { });
    in {
      home.packages = [
        pkgs.cachix
        pkgs.xclip
        pkgs.killall
        pkgs.tmux
        pkgs.emacs
        pkgs.firefox
        pkgs.google-chrome
        pkgs.gnome3.gnome-tweaks
        pkgs.par
        pkgs.riot-desktop
        pkgs.nodejs
        pkgs.jq
        pkgs.moreutils
        glab
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
      programs.neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;
        withPython3 = true;
        plugins = with pkgs.vimPlugins; [
          haskell-vim
          fzf-vim
          ghcid
          gruvbox
          vim-gitgutter
          vim-airline
          vim-tmux-focus-events
          vim-auto-save
          vimagit
          coc-nvim
        ];
        extraConfig = ''

                    " par setup
                    set textwidth=80
                    set formatprg=par\ -w80req
                    set formatoptions+=t

                    syntax on
                    set updatetime=300

                    filetype plugin indent on

                    " Gruvbox Setup
                    set termguicolors
                    colorscheme gruvbox
                    set background=light 

                    " Autosave setup
                    let g:auto_save = 1
                    let g:auto_save_events = ["InsertLeave", "TextChanged",  "TextChangedI", "CursorHold", "CursorHoldI", "CompleteDone"]
                    set autoread
                    set noswapfile

                    " Line number management
                    set number relativenumber

                    " General setup
                    set number
                    set showmode
                    set smartindent
                    set autoindent
                    set expandtab
                    set shiftwidth=2
                    set softtabstop=2
                    set signcolumn=yes

                    " Use the system clipboard for copy/past
                    set clipboard=unnamed
                    
                    " Coc Setup
                    " Use tab for trigger completion with characters ahead and navigate.
                    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
                    " other plugin before putting this into your config.
                    inoremap <silent><expr> <TAB>
                          \ pumvisible() ? "\<C-n>" :
                          \ <SID>check_back_space() ? "\<TAB>" :
                          \ coc#refresh()
                    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

                    function! s:check_back_space() abort
                      let col = col('.') - 1
                      return !col || getline('.')[col - 1]  =~# '\s'
                    endfunction

                    let g:coc_user_config = {
          	    \ 'rust-client.disableRustup': v:true,
                      \ 'rust.clippy_preference': 'on'
                    \ }
                    " Use K to show documentation in preview window.
                    nnoremap <silent> K :call <SID>show_documentation()<CR>

                    function! s:show_documentation()
                      if (index(['vim','help'], &filetype) >= 0)
                        execute 'h '.expand('<cword>')
                      else
                        call CocAction('doHover')
                      endif
                    endfunction

                    
                    " Add `:Format` command to format current buffer.
                    command! -nargs=0 Format :call CocAction('format')
                  
                    " Add `:OR` command for organize imports of the current buffer.
                    command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
                    
                    " Add `:Next` and `:Previous` commands for errors
                    command! -nargs=0 CNext :call CocAction('diagnosticNext')<CR>
                    command! -nargs=0 CPrev :call CocAction('diagnosticPrevious')<CR>
                  '';

      };

      home.file = { ".tmux.conf" = { source = ./tmux.conf; }; };

    };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

