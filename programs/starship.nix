{ lib, theme ? "modus-operandi" } :

let
  colorSchemes = {
    modus-operandi = {
      base = "#000000";     # fg-main
      error = "#a60000";    # red
      primary = "#6f5500";  # yellow
      secondary = "#000000";# fg-main
      accent = "#0031a9";   # blue
      warning = "#005e8b";  # cyan
      highlight = "#000000";# fg-main
      info = "#721045";     # magenta
      success = "#006800";  # green
    };
    dracula = {
      base = "#f8f8f2";     # white
      error = "#ff5555";    # red
      primary = "#8be9fd";  # blue
      secondary = "#bd93f9";# purple
      accent = "#f1fa5c";   # yellow
      warning = "#ffb86c";  # orange
      highlight = "#ff79c6";# pink
      info = "#CE71D2";     # magenta
      success = "#50fa7b";  # green
    };
    gruvbox = {
      base = "#ebdbb2";
      error = "#cc241d";
      primary = "#83a598";
      secondary = "#d3869b";
      accent = "#fabd2f";
      warning = "#fe8019";
      highlight = "#b16286";
      info = "#d79921";
      success = "#98971a";
    };
    nord = {
      base = "#eceff4";
      error = "#bf616a";
      primary = "#88c0d0";
      secondary = "#b48ead";
      accent = "#ebcb8b";
      warning = "#d08770";
      highlight = "#b48ead";
      info = "#a3be8c";
      success = "#8fbcbb";
    };
  };

  colors = colorSchemes.${theme} or colorSchemes.dracula;

  usernameColors = { root = colors.primary; user = colors.secondary; };
  hostnameColors = { host = colors.error; };
  directoryColors = { path = colors.accent; readOnly = colors.info; };
  gitBranchColors = { branch = colors.warning; };
  gitCommitColors = { commit = colors.primary; };
  gitStateColors = { state = colors.highlight; };
  gitStatusColors = { status = colors.info; };
  nodejsColors = { version = colors.success; };
  packageColors = { version = colors.success; };
  characterColors = { success = colors.base; error = colors.error; };
in
{
  enable = true;
  enableFishIntegration = true;
  settings = {
    add_newline = false;
    scan_timeout = 60;
    command_timeout = 500;

    format = lib.concatStrings [
      "$username"
      "$hostname"
      "$directory"
      "$git_branch"
      "$git_commit"
      "$git_state"
      "$git_status"
      "$nodejs"
      "$package"
      "$line_break"
      "$character"
    ];

    character = {
      success_symbol = "[ ](fg:${characterColors.success})";
      error_symbol = "[ ](fg:${characterColors.error})";
    };

    username = {
      format = "[$user 󰄾]($style) ";
      style_root = "fg:${usernameColors.root}";
      style_user = "fg:${usernameColors.user}";
      show_always = true;
    };

    hostname = {
      format = "[$hostname 󰄾]($style) ";
      style = "bold fg:${hostnameColors.host}";
      ssh_only = true;
    };

    directory = {
      format = "[ $path]($style)[$read_only]($read_only_style) [󰄾]($style) ";
      style = "fg:${directoryColors.path}";
      read_only_style = "fg:${directoryColors.readOnly}";
      truncation_length = 3;
      truncation_symbol = "_/";
      truncate_to_repo = true;
    };

    git_branch = {
      format = "[$symbol$branch 󰄾]($style) ";
      symbol = " ";
      style = "fg:${gitBranchColors.branch}";
    };

    git_commit = {
      format = "[ $hash$tag 󰄾]($style)";
      style = "fg:${gitCommitColors.commit}";
      only_detached = false;
    };

    git_state = {
      format = "[\\($state( $progress_current of $progress_total)\\) 󰄾]($style)";
      style = "fg:${gitStateColors.state}";
    };

    git_status = {
      format = "[$all_status$ahead_behind 󰄾 ]($style) ";
      style = "fg:${gitStatusColors.status}";
      conflicted = " 󰘕";
      ahead = " ";
      behind = " ";
      diverged = " 󰘖";
      up_to_date = " ";
      untracked = " ";
      stashed = " 󰌨";
      modified = " ";
      staged = " ";
      renamed = " ";
      deleted = " ";
    };

    nodejs = {
      format = "[$symbol($version )󰄾]($style)";
      style = "fg:${nodejsColors.version}";
      detect_extensions = [];
      detect_files = ["package.json"];
      detect_folders = [];
    };

    package = {
      format = " [$symbol$version 󰄾]($style)";
      style = "fg:${packageColors.version}";
      symbol = "󰏗 ";
    };

    cmake = {
      disabled = true;
    };

    java = {
      disabled = true;
    };

    kotlin = {
      disabled = true;
    };

    swift = {
      disabled = true;
    };
  };
}
