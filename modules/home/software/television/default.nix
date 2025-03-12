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
    enable = mkBoolOpt false "Enable Television TUI fuzzy finder";
    settings = mkOpt settingsFormat.type { } "Settings for Television";
    nix-search-tv.enable = mkBoolOpt true "Enable plugin for searching nix packages";
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
          source_command = "${pkgs.nix-search-tv}/bin/nix-search-tv print";
          preview_command = "${pkgs.nix-search-tv}/bin/nix-search-tv preview {}";
        }
      ];
    })
  ]);
}
