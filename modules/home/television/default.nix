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
  cfg = config.${namespace}.cli.television;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.${namespace}.cli.television = with types; {
    enable = mkBoolOpt true "Enable television - TUI fuzzy finder";
    settings = mkOpt settingsFormat.type { } "Settings for television";
    nix-search-tv.enable = mkBoolOpt true "Enable nix-search-tv - plugin for searching nix packages";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        television
      ];

      xdg.configFile."television/nix_channels.toml".source =
        settingsFormat.generate "television.toml" cfg.settings;
    }

    (mkIf cfg.nix-search-tv.enable {
      ${namespace}.cli.television.settings.cable_channel = [
        {
          name = "nixpkgs";
          source_command = "nix-search-tv print";
          preview_command = "nix-search-tv preview {}";
        }
      ];
    })
  ]);
}
