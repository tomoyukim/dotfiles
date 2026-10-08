{ config, pkgs, nixgl } :

{
  enable = true;
  package = config.lib.nixGL.wrap pkgs.alacritty;
  
  settings = {
    env.TERM = "xterm-256color";
    window = {
      #        opacity = 0.9;
      startup_mode = "Maximized";
      dynamic_title = true;
      class = {
        instance = "Alacritty";
        general = "Alacritty";
      };
    };
    scrolling.history = 10000;
    font = {
      normal = {
        family = "HackGen Console NF";
        style = "Regular";
      };
      bold = {
        family = "HackGen Console NF";
        style = "Bold";
      };
      italic = {
        family = "HackGen Console NF";
        style = "Italic";
      };
      bold_italic = {
        family = "HackGen Console NF";
        style = "Bold Italic";
      };
      size = 12.0;
    };
    selection.save_to_clipboard = false;
    cursor = {
      style = {
        shape = "Underline";
        blinking = "On";
      };
    };

    mouse.bindings = [
      {
        mouse = "Right";
        action = "PasteSelection";
      }
    ];
    keyboard.bindings = [
      {
        key = "Return";
        mods = "Control|Shift";
        action = "ToggleFullscreen";
      }
      {
        key = "Z";
        mods = "Control";
        action = "Minimize";
      }
    ];
    colors = { # Dracula
      primary = {
        background = "#282a36";
        foreground = "#f8f8f2";
      };
      cursor = {
        text = "CellBackground";
        cursor = "CellForeground";
      };
      vi_mode_cursor = {
        text = "CellBackground";
        cursor = "CellForeground";
      };
      search = {
        matches = {
          background = "#50fa7b";
          foreground = "#44475a";
        };
        focused_match = {
          background = "#ffb86c";
          foreground = "#44475a";
        };
      };
      footer_bar = {
        background = "#282a36";
        foreground = "#f8f8f2";
      };
      hints = {
        start = {
          background = "#f1fa8c";
          foreground = "#282a36";
        };
        end = {
          background = "#282a36";
          foreground = "#f1fa8c";
        };
      };
      line_indicator = {
        background = "None";
        foreground = "None";
      };
      selection = {
        text = "CellForeground";
        background = "#44475a";
      };
      normal = {
        black = "#21222c";
        red = "#ff5555";
        green = "#50fa7b";
        yellow = "#f1fa8c";
        blue = "#bd93f9";
        magenta = "#ff79c6";
        cyan = "#8be9fd";
        white = "#f8f8f2";
      };
      bright = {
        black = "#6272a4";
        red = "#ff6e6e";
        green = "#69ff94";
        yellow = "#ffffa5";
        blue = "#d6acff";
        magenta = "#ff92df";
        cyan = "#a4ffff";
        white = "#ffffff";
      };
    };
  };
}
