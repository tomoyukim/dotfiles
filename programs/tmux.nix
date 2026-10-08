{ pkgs }:

{
    enable = true;
    clock24 = true;
    baseIndex = 1;
    prefix = "C-j";
    terminal = "xterm-256color";
    plugins = with pkgs; [
      # sensible is already available in home-manager
      tmuxPlugins.yank
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
        set -g @dracula-plugins "battery network weather"
        set -g @dracula-border-contrast true
        set -g @dracula-show-powerline true

        set -g @dracula-show-left-icon ' :#S'
        set -g @dracula-show-flags true

        set -g @dracula-git-disable-status false
        set -g @dracula-git-no-repo-message "--"
        set -g @dracula-git-show-current-symbol 
        set -g @dracula-battery-label " :"

        set -g @dracula-show-fahrenheit false
        set -g @dracula-show-location false
        '';
      }
    ];

    extraConfig = ''
    set -g terminal-overrides 'xterm:colors=256'
    set -g mouse on

    set -g status-interval 1
    set -g status-justify centre
    set -g status-position top
    set -g status-left-length 90
    set -g status-right-length 90
    set -g status-justify centre

    set -g pane-border-status bottom
    set -g pane-border-format "  :#{pane_index} #T "
    '';
  }
