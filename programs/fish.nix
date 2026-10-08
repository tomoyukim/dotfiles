{ pkgs } :

{
  enable = true;

  interactiveShellInit = ''
      # fzf plugin
      set -U FZF_LEGACY_KEYBINDINGS 0
      # zoxide
      set -x _ZO_ECHO 1
      set -x _ZO_RESOLVE_SYMLINKS 1

      # Emacs vterm integration
      if test "$INSIDE_EMACS" = "vterm"; and set -q EMACS_VTERM_PATH; and test -f "$EMACS_VTERM_PATH/etc/emacs-vterm.fish"
          source "$EMACS_VTERM_PATH/etc/emacs-vterm.fish"
      end

      direnv hook fish | source

      # Use eza completions for eza abbreviations and aliases.
      complete -c e -w eza
      complete -c la -w eza
      complete -c ll -w eza
      complete -c ls -e
      complete -c ls -w eza
    '';

  shellAbbrs = {
    cdr = "cd (git root)";
    e = "eza --icons=always";
    export = "bass -d export";
    ga = "git add";
    gbd = "git branch -d";
    gc = "git commit";
    gca = "git commit --amend";
    gcm = "git commit -m";
    gd = "git diff";
    gf = "git fetch --prune";
    gl = "git log -4 --stat";
    gm = "git merge";
    gp = "git push origin";
    gr = "git restore .";
    grs = "git reset .";
    gs = "git status";
    gsc = "git switch -c";
    gsw = "git switch";
    gt = "gtags --gtagslabel=pygments --debug";
    la = "eza --icons=always -a --color=auto";
    ll = "eza --icons=always -al --color=auto";
    ls = "eza --icons=always";
    make = "bass make";
    prf = "git diff main (git rev-parse --abbrev-ref HEAD) --name-only";
    pr = "gh-pr-switch";
    ne = "nix-env -qaPs";
  };

  plugins = [
    {
      name = "fzf";
      src = pkgs.fetchFromGitHub {
        owner = "jethrokuan";
        repo = "fzf";
        rev = "479fa67d7439b23095e01b64987ae79a91a4e283";
        sha256 = "sha256-28QW/WTLckR4lEfHv6dSotwkAKpNJFCShxmKFGQQ1Ew=";
      };
    }
    {
      name = "bass";
      src = pkgs.fetchFromGitHub {
        owner = "edc";
        repo = "bass";
        rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
        sha256 = "sha256-fl4/Pgtkojk5AE52wpGDnuLajQxHoVqyphE90IIPYFU=";
      };
    }
    {
      name = "fish-ghq";
      src = pkgs.fetchFromGitHub {
        owner = "decors";
        repo = "fish-ghq";
        rev = "cafaaabe63c124bf0714f89ec715cfe9ece87fa2";
        sha256 = "sha256-6b1zmjtemNLNPx4qsXtm27AbtjwIZWkzJAo21/aVZzM=";
      };
    }
  ];

  functions = {
    ssh = {
      body = ''
        TERM=xterm-256color command ssh $argv
      '';
      description = "use a popular terminfo in ssh env";
    };
    load-openai-key = {
      body = ''
        set -l key (pass show openai-key)
        or return
        set -gx OPENAI_API_KEY $key[1]
      '';
      description = "load OpenAI API key from pass";
    };
    load-chroma-key = {
      body = ''
        set -l key (pass show openai-key)
        or return
        set -gx CHROMA_OPENAI_API_KEY $key[1]
      '';
      description = "load Chroma OpenAI API key from pass";
    };
    load-jquants-key = {
      body = ''
        set -l key (pass show jquants-key)
        or return
        set -gx JQUANTS_API_KEY $key[1]
      '';
      description = "load J-Quants API key from pass";
    };
    claude = {
      body = ''
        set -l key (pass show claude-key)
        or return
        set -lx ANTHROPIC_API_KEY $key[1]
        command claude $argv
      '';
      description = "run claude with Anthropic API key from pass";
    };
    gh-pr-open = ''
       set selected_pr_id (gh pr list| fzf --preview "echo {} | awk '{print \$1}' | xargs gh pr view | tr -d '\r' | bat --color=always --style=header,grid -l md" | awk '{ print $1 }')
       if test -n "$selected_pr_id"
         commandline "gh pr view --web $selected_pr_id"
       end
       commandline -f repaint
      '';
    gh-pr-switch = ''
       set selected_pr_id (gh pr list| fzf --preview "echo {} | awk '{print \$1}' | xargs gh pr view | tr -d '\r' | bat --color=always --style=header,grid -l md" | awk '{ print $1 }')
       if test -n "$selected_pr_id"
         commandline "gh pr checkout $selected_pr_id"
       end
       commandline -f repaint
      '';
    md = "grip $argv[1] --export - | lynx -stdin";
    xcode-open = {
      body = ''
          set project_list (find ./ -type d | grep -e '.*xcodeproj$' -e '.*xcworkspace$')
          switch (count $project_list)
          case 0
            	commandline ""
          case 1
            	commandline "open -a Xcode $project_list"
          case '*'
            	set target (printf "%s\n" $project_list | fzf)
            	commandline "open -a Xcode $target"
          end
          commandline -f repaint
        '';
      description = "open xcodeproj or xcworkspace in Xcode with interactive filter powered by fzf";
    };
  };
}
