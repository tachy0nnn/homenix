{
  pkgs,
  lib,
  ...
}:

{
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    eza
    bat
    wl-clipboard
    jq
    devenv
    unstable.mold
    nil
    nixd
    spotify-spotx

    # nix tooling (awesome-nix)
    nixfmt
    statix
    deadnix
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

  programs = {
    nix-init.enable = true;
    vesktop.enable = true;
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
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf.enable = true;
    zoxide.enable = true;
    bash.enable = true;
  };
}
