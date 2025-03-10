{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
with lib.types;
let
  cfg = config.${namespace}.pam;
in
{
  options = {
    ${namespace}.pam = with types; {
      enable = mkBoolOpt true "Enable PAM configuration";
      rssh.enable = mkBoolOpt false "Enable RSSH PAM rules";
      gtklock.enable = mkBoolOpt config.${namespace}.desktop-environment.enable "Enable gtklock rules";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.gtklock.enable {
      security.pam.services.gtklock = { };
    })
    (mkIf cfg.rssh.enable {
      security.pam = {
        rssh.enable = true;
        services.sudo.rssh = true;
      };
    })
  ]);
}
