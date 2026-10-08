{ enable, name, email, extraConfig }:

{
  enable = enable;
  settings = {
    user = {
      name = name;
      email = email;
    };
    aliases = {
      fp = "!git fetch -p && git-delete-merged-branches";
      showpr = "!f() { git log --merges --oneline --reverse --ancestry-path $1...master | grep 'Merge pull request #' | head -n 1; }; f";
      s = "status";
      co = "checkout";
      root = "rev-parse --show-toplevel";
    };
  };
  extraConfig = extraConfig;
}
