{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli.nnn;
in
{
  options.${namespace}.cli.nnn = with types; {
    enable = mkBoolOpt true "Enable nnn - terminal file browser";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.nnn = {
        enable = true;
        package = pkgs.nnn.override { withNerdIcons = true; };
        bookmarks = {
          d = "/home/fern/Downloads";
          g = "/home/fern/git";
          m = "/run/media/fern";
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
    (mkIf config.${namespace}.apps.nextcloud.enable {
      programs.nnn.bookmarks.n = "/home/fern/Nextcloud";
    })
  ]);
}
