{
  inputs,
  desktop,
  username,
}: {pkgs, ...}: let
  nix = import ../shared/nix.nix;
in {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fonts = {
    fontconfig = {
      defaultFonts.monospace = ["IntelOne Mono"];
      enable = true;
    };

    fonts = [pkgs.intel-one-mono];
  };

  environment = {
    pathsToLink = ["/libexec" "/share/zsh"];
    systemPackages = with pkgs;
      [
        curl
        k3s
        vim
        wget
        xclip
      ]
      ++ pkgs.lib.optionals desktop [
        dunst
        libnotify
        lxappearance
        pavucontrol
      ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    firewall.enable = false;
    hostName = "${username}-nixos";
    networkmanager.enable = true;
  };

  nix = nix;

  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio =
        if desktop
        then true
        else false;
    };
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services = {
    logind.extraConfig = ''
      RuntimeDirectorySize=20G
    '';

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  system.stateVersion = "23.05";

  time.timeZone = "America/Los_Angeles";

  users = {
    mutableUsers = false;
    users."${username}" = {
      extraGroups = ["docker" "wheel"] ++ pkgs.lib.optionals desktop ["audio"];
      hashedPassword = "";
      home = "/home/${username}";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      shell = pkgs.zsh;
    };
  };

  virtualisation = {
    containerd = {
      enable = true;
      settings = let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs; [cni-plugin-flannel cni-plugins];
        };
      in {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
      };
    };

    podman = {
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
      enable = true;
      extraPackages = with pkgs; [zfs];
    };

    vmware.guest.enable =
      if pkgs.system == "aarch64-linux"
      then false
      else true;
  };
}
