# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

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

  boot.kernelPackages = pkgs.linuxPackages_zen; # personal thing
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
    # extra-substituters = [ "https://nix-community.cachix.org" ];
    # extra-trusted-public-keys = [
    #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # ];
  };
  nix.optimise.automatic = true;

  system.stateVersion = "26.05";
}
