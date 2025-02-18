{ pkgs, ... }:
{
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    bookmarks = {
      d = "/home/fern/Downloads";
      l = "/home/fern/Software/lix";
      m = "/run/media/fern";
      n = "/home/fern/Nextcloud";
      s = "/home/fern/Software";
    };
    plugins = {
      src =
        (pkgs.fetchFromGitHub {
          owner = "jarun";
          repo = "nnn";
          rev = "v5.0";
          sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
        })
        + "/plugins";
      mappings = {
        p = "preview-tui";
      };
    };
  };
}
