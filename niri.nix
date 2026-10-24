{ pkgs, ... }:

let
  # material symbols glyphs by codepoint (private-use characters are invisible in most editors)
  glyph = code: builtins.fromJSON ''"\u${code}"'';
  g = {
    apps = glyph "e5c3";
    circle = glyph "ef4a";
    memory = glyph "e322";
    radio_button_unchecked = glyph "e836";
    speed = glyph "e9e4";
    volume_off = glyph "e04f";
    volume_up = glyph "e050";
  };

  # glyph as pango markup so it uses the icon font
  icon = glyph: "<span font_family='Material Symbols Rounded' font_size='14pt'>${glyph}</span>";
in
{
  home.packages = with pkgs; [
    swaybg
    roboto
    material-symbols
  ];

  fonts.fontconfig.enable = true;

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

  # material 3 navigation rail on the left: fab on top, destinations, status at the bottom
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "left";
      width = 56;
      spacing = 4;
      modules-left = [
        "custom/launcher"
        "niri/workspaces"
      ];
      modules-right = [
        "tray"
        "pulseaudio"
        "cpu"
        "memory"
        "clock"
      ];

      "custom/launcher" = {
        format = "<span font_family='Material Symbols Rounded' font_size='16pt'>${g.apps}</span>";
        tooltip = false;
        on-click = "fuzzel";
      };
      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = g.radio_button_unchecked;
          active = g.circle;
        };
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      pulseaudio = {
        format = "${icon g.volume_up}\n{volume}%";
        format-muted = "${icon g.volume_off}\nmuted";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        tooltip = false;
      };
      cpu = {
        format = "${icon g.speed}\n{usage}%";
        interval = 5;
        tooltip = false;
      };
      memory = {
        format = "${icon g.memory}\n{percentage}%";
        interval = 10;
        tooltip-format = "{used:0.1f} GiB of {total:0.1f} GiB";
      };
      clock = {
        format = "{:%H\n%M}";
        tooltip-format = "{:%A, %d %B %Y}";
      };
    };

    # material 3 dark (baseline) color roles, tonal surfaces, pill indicators, no outlines
    style = ''
      * {
        font-family: "Roboto", "Noto Sans";
        font-size: 11px;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
        box-shadow: none;
        text-shadow: none;
      }

      /* surface */
      window#waybar {
        background: #141218;
        color: #CAC4D0;
      }

      .modules-left {
        padding-top: 12px;
      }

      .modules-right {
        padding-bottom: 12px;
      }

      tooltip {
        background: #2B2930;
        border-radius: 8px;
      }

      tooltip label {
        color: #E6E0E9;
      }

      /* fab: primary container, 16dp corners */
      #custom-launcher {
        background: #4F378B;
        color: #EADDFF;
        border-radius: 14px;
        padding: 12px 0;
        margin: 0 6px 16px 6px;
      }

      #custom-launcher:hover {
        background: #5B4494;
      }

      /* destinations: 44x28 pill indicator, secondary container when active */
      #workspaces button {
        color: #CAC4D0;
        background: transparent;
        border-radius: 14px;
        min-width: 44px;
        min-height: 28px;
        padding: 0;
        margin: 3px 6px;
        transition: background 200ms ease;
      }

      /* the label inside the button needs the icon font itself, because the * rule above targets it directly */
      #workspaces button label {
        font-family: "Material Symbols Rounded";
        font-size: 16px;
      }

      #workspaces button:hover {
        background: rgba(230, 224, 233, 0.08);
      }

      #workspaces button.active,
      #workspaces button.focused {
        background: #4A4458;
        color: #E8DEF8;
      }

      /* status items: icon over label, state layer on hover */
      #tray,
      #pulseaudio,
      #cpu,
      #memory,
      #clock {
        color: #CAC4D0;
        border-radius: 14px;
        padding: 6px 0;
        margin: 0 6px;
      }

      #pulseaudio:hover,
      #cpu:hover,
      #memory:hover,
      #clock:hover {
        background: rgba(230, 224, 233, 0.08);
      }

      #pulseaudio.muted {
        color: #F2B8B5;
      }

      #clock {
        color: #E6E0E9;
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
