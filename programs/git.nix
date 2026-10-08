{ home }:

{
  enable = true;
  includes = [
    {
      # Machine-specific user.name and user.email stay outside the repositories.
      # [Setup]
      #  mkdir -p ~/.config/git
      #  chmod 700 ~/.config/git
      #  ${EDITOR:-vi} ~/.config/git/gitconfig.local
      #  chmod 600 ~/.config/git/gitconfig.local
      # [Verify]
      #  git config --show-origin --get user.name
      #  git config --show-origin --get user.email
      path = "~/.config/git/gitconfig.local";
    }
  ];
  settings = {
    alias = {
      fp = "!git fetch -p && git-delete-merged-branches";
      showpr = "!f() { git log --merges --oneline --reverse --ancestry-path $1...master | grep 'Merge pull request #' | head -n 1; }; f";
      s = "status";
      co = "checkout";
      root = "rev-parse --show-toplevel";
    };
    core = {
      excludesfile = "${home.homeDirectory}/.gitignore_global";
      editor = "nano";
    };
    init = {
      defaultBranch = "main";
    };
    fetch = {
      prune = true;
    };
    github = {
      user = "tomoyukim";
    };
    ghq = {
      root = "~/Documents/repos";
      "https://github.com/tomoyukim" = {
        root = "~/Documents/workspace";
        vsc = "git";
      };
      "https://bitbucket.org/tomoyukim" = {
        root = "~/Documents/workspace";
        vsc = "git";
      };
    };
  };
}
