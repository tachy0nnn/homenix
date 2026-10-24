# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/networking.nix
    ./modules/nvidia.nix
  ];
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 3;
    minegrub-world-sel = {
      enable = true;
      background = "assets/background-scaled/background-1920x1080.png";
      customIcons = [
        {
          name = "nixos";
          lineTop = with config.system.nixos; distroName + " " + codeName + " (" + version + ")";
          lineBottom = "Survival Mode, No Cheats, Version: " + config.system.nixos.release;
          imgName = "nixos";
        }
      ];
    };
  };

  systemd.services.nix-daemon.environment = {
    ALL_PROXY = "socks5h://127.0.0.1:7897";
    all_proxy = "socks5h://127.0.0.1:7897";
    HTTPS_PROXY = "socks5h://127.0.0.1:7897";
    https_proxy = "socks5h://127.0.0.1:7897";
  };

  boot.kernelPackages = pkgs.linuxPackages_zen; # personal thing
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];
  fileSystems."/".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/home".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/nix".options = [
    "compress=zstd"
    "noatime"
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  boot.initrd.luks.devices."luks-a6b83008-28c3-411a-95c4-6518d6449435".allowDiscards = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  programs.nix-ld.enable = true;
  programs.nix-index-database.comma.enable = true;

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";
  users.users."yon" = {
    isNormalUser = true;
    description = "yon";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs.firefox.enable = true;
  programs.nh = {
    enable = true;
    flake = "/home/yon/homenix";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    warn-dirty = false;
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # pin `nix shell nixpkgs#foo` to the same nixpkgs as the system
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nix.optimise.automatic = true;

  system.stateVersion = "26.05";
}
