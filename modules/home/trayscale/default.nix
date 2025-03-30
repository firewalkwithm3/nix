{
  osConfig,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.trayscale;
in
{
  options.${namespace}.trayscale = with types; {
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable trayscale - GUI interface for Tailscale";
  };

  config = mkIf (cfg.enable && osConfig.${namespace}.networking.tailscale.enable) {
    services.trayscale = enabled;
  };
}
