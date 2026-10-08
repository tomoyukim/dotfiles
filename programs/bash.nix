{
  enable = true;
  enableCompletion = true;

  historyControl = [ "ignoreboth" ];
  historySize = 1000;
  historyFileSize = 2000;

  shellAliases = {
    grep  = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";
    ls    = "eza --icons";
    ll    = "eza --icons -al --color auto";
    la    = "eza --icons -a --color auto";
  };

  profileExtra = ''
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi

    # Machine-specific login shell config (not managed by home-manager)
    if [ -f ~/.profile.local ]; then
        . ~/.profile.local
    fi

    # Start ssh-agent only for a real terminal login.  In particular, do not
    # start it for Emacs/TRAMP or other non-interactive SSH sessions.
    if [ -t 0 ] && [ -t 1 ]; then
        if [ -f "$HOME/.ssh-agent" ]; then
            . "$HOME/.ssh-agent"
        fi
        if [ -z "''${SSH_AUTH_SOCK:-}" ] || \
           [ ! -S "$SSH_AUTH_SOCK" ] || \
           [ -z "''${SSH_AGENT_PID:-}" ] || \
           ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
            ssh-agent -s > "$HOME/.ssh-agent"
            chmod 600 "$HOME/.ssh-agent"
            . "$HOME/.ssh-agent"
        fi
    fi

    # Roswell
    # export PATH=$PATH:$HOME/.roswell/bin

    '';

  bashrcExtra = ''
    # Machine-specific interactive shell config (not managed by home-manager)
    if [ -f ~/.bashrc.local ]; then
        . ~/.bashrc.local
    fi

    if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
    fi

    # TRAMP uses a non-TTY interactive shell.  Do not replace that shell with
    # fish: TRAMP expects a POSIX-compatible shell for its command protocol.
    if [[ $- == *i* ]] && [[ -t 0 ]] && [[ -t 1 ]] && \
       [[ "''${TERM:-}" != "dumb" ]] && command -v fish >/dev/null; then
        exec fish
    fi

    '';
  # [[ $EMACS != "yes" ]] && exec fish; return
}
