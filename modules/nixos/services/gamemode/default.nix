{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.gamemode;
in
{
  options.${namespace}.services.gamemode = with types; {
    enable = mkBoolOpt config.${namespace}.desktop-environment.enable "Enable gamemode service";
  };

  config = mkIf cfg.enable {
    programs.gamemode.enable = true;
    users.users.${config.${namespace}.user.name}.extraGroups = [ "gamemode" ];
  };
}
