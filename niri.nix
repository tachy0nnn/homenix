{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swaybg
    roboto
  ];

  fonts.fontconfig.enable = true;

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

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
        background: #1a1625;
        color: #cac4d0;
      }

      #workspaces button {
        color: #6e6780;
        background: transparent;
        padding: 0 8px;
      }

      #workspaces button:hover {
        color: #cac4d0;
      }

      #workspaces button.active {
        color: #d98cb3;
      }

      #clock {
        color: #e6d9f0;
      }

      #pulseaudio,
      #tray {
        color: #cac4d0;
        padding: 0 10px;
      }

      #pulseaudio.muted {
        color: #6e6780;
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
        background = "1a1625f2";
        text = "e6d9f0ff";
        match = "d98cb3ff";
        selection = "2f2840ff";
        selection-text = "e6d9f0ff";
        selection-match = "d98cb3ff";
        border = "d98cb3ff";
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
      color = "1a1625";
      inside-color = "2a2438";
      ring-color = "d98cb3";
      key-hl-color = "9d86c9";
      line-color = "00000000";
      text-color = "e6d9f0";
      show-failed-attempts = true;
    };
  };
}
