{ pkgs, ... }:

let
  palette = import ./palette.nix;

  niriConfigText =
    builtins.replaceStrings
      [ "@accent@" "@border-inactive@" "@bg-overlay@" "@bg@" ]
      [
        "#${palette.accent}"
        "#${palette.border-inactive}"
        "#${palette.bg-overlay}"
        "#${palette.bg}"
      ]
      (builtins.readFile ./niri/config.kdl);

  niriConfigFile = pkgs.writeText "niri-config.kdl" niriConfigText;

  validatedNiriConfig =
    pkgs.runCommand "niri-config.kdl"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${niriConfigFile}
        cp ${niriConfigFile} $out
      '';

  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    text = ''
      choice=$(printf '%s\n' lock logout reboot bios shutdown \
        | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "power ~ ")

      case "$choice" in
        lock)     ${pkgs.swaylock}/bin/swaylock -f ;;
        logout)   niri msg action quit --skip-confirmation ;;
        reboot)   systemctl reboot ;;
        bios)     systemctl reboot --firmware-setup ;;
        shutdown) systemctl poweroff ;;
      esac
    '';
  };
in
{
  home.packages = with pkgs; [
    swaybg
    roboto
    powerMenu
  ];

  fonts.fontconfig.enable = true;

  xdg.configFile."niri/config.kdl".source = validatedNiriConfig;

  # lock screen automatically before system suspend (s2idle)
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
  };

  # slim top bar: workspaces left, clock center, tray and volume right
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 0;
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "pulseaudio"
      ];

      "niri/workspaces" = {
        format = "{index}";
      };
      clock = {
        format = "{:%H:%M}";
        tooltip-format = "{:%A, %d %B %Y}";
      };
      pulseaudio = {
        format = "{volume}%";
        format-muted = "muted";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        tooltip = false;
      };
      tray = {
        icon-size = 16;
        spacing = 8;
      };
    };

    style = ''
      * {
        font-family: "Roboto", "Noto Sans";
        font-size: 12px;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
        box-shadow: none;
      }

      window#waybar {
        background: #${palette.bg};
        color: #${palette.fg};
      }

      #workspaces button {
        color: #${palette.fg-muted};
        background: transparent;
        padding: 0 8px;
      }

      #workspaces button:hover {
        color: #${palette.fg};
      }

      #workspaces button.active {
        color: #${palette.accent};
      }

      #clock {
        color: #${palette.fg-bright};
      }

      #pulseaudio,
      #tray {
        color: #${palette.fg};
        padding: 0 10px;
      }

      #pulseaudio.muted {
        color: #${palette.fg-muted};
      }
    '';
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        prompt = "\"~ \"";
        width = 30;
      };
      colors = {
        background = "${palette.bg}f2";
        text = "${palette.fg-bright}ff";
        match = "${palette.accent}ff";
        selection = "${palette.bg-selection}ff";
        selection-text = "${palette.fg-bright}ff";
        selection-match = "${palette.accent}ff";
        border = "${palette.accent}ff";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = palette.bg;
      inside-color = palette.bg-lock;
      ring-color = palette.accent;
      key-hl-color = palette.accent-alt;
      line-color = "00000000";
      text-color = palette.fg-bright;
      show-failed-attempts = true;
    };
  };
}
