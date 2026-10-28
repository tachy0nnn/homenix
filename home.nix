{
  pkgs,
  lib,
  ...
}:

let
  palette = import ./palette.nix;
in
{
  imports = [
    ./ship.nix
    ./niri.nix
  ];
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    wl-clipboard
    devenv
    unstable.mold
    nil
    nixd
    spotify-spotx
    helium

    # nix tooling (awesome-nix)
    nixfmt
    statix
    deadnix
    nix-update
    nix-tree # browse the dependency graph of a derivation
    nix-du # see which gc roots eat disk space
    nix-melt # flake.lock viewer
    cachix
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "us"
        ])
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "ru"
        ])
      ];
      xkb-options = [ "grp:alt_shift_toggle" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      mic-mute = [ "<Ctrl><Shift>m" ];
    };
  };

  # notifications: niri ships no notification daemon, so without this they vanish
  services.mako = {
    enable = true;
    settings = {
      background-color = "#${palette.mako-bg}";
      text-color = "#${palette.mako-fg}";
      border-color = "#${palette.accent}";
      border-size = 2;
      border-radius = 12;
      font = "Roboto 11";
      width = 360;
      margin = "10";
      padding = "12";
      default-timeout = 5000;
      anchor = "top-right";
    };
  };

  # keepassxc starts with the niri/gnome session (systemd user service, not an xdg autostart file)
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC password manager";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs = {
    ghostty = {
      enable = true;
      enableBashIntegration = true;
    };
    nix-search-tv.enable = true;
    nix-init.enable = true;
    keepassxc.enable = true;
    vesktop = {
      enable = true;
      package = lib.makeOverridable (
        {
          withSystemVencord ? false,
        }:
        pkgs.symlinkJoin {
          name = "vesktop";
          paths = [ (pkgs.vesktop.override { inherit withSystemVencord; }) ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/vesktop \
              --add-flags "--proxy-server=socks5://127.0.0.1:7897"
          '';
        }
      ) { };
    };
    obsidian.enable = true;
    prismlauncher.enable = true;
    zed-editor = {
      enable = true;
      package = pkgs.unstable.zed-editor;
      extraPackages = with pkgs; [
        nixd
        nixfmt
        package-version-server
      ];
      extensions = [
        "nix"
        "toml"
        "material-icon-theme"
        "git_firefly"
      ];
    };

    git = {
      enable = true;
      ignores = [
        ".direnv"
        "result"
      ];

      signing = {
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
        format = "ssh";
      };

      settings = {
        user.name = "yon";
        user.email = "154914363+tachy0nnn@users.noreply.github.com";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        fetch.prune = true;
        rebase.autoStash = true;
        merge.conflictStyle = "zdiff3";
        diff.colorMoved = "default";
        url."git@github.com:".insteadOf = "https://github.com/";

        alias = {
          st = "status -sb";
          co = "checkout";
          br = "branch";
          ci = "commit";
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          undo = "reset --soft HEAD~1";
        };
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
        };
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/id_ed25519";
        };
      };
    };

    chromium = {
      enable = true;
      package = pkgs.brave;
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=TouchpadOverscrollHistoryNavigation"
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf.enable = true;
    eza.enable = true;
    bat.enable = true;
    btop.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    jq.enable = true;
    zoxide.enable = true;
    bash.enable = true;
  };
}
