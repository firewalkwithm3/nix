{
  osConfig,
  lib,
  ...
}:
let
  namespace = "flock";
in
with lib;
with lib.${namespace};
{
  ${namespace}.suites.server = enabled;

  # ======================== DO NOT CHANGE THIS ========================
  home.stateVersion = osConfig.system.stateVersion;
  # ======================== DO NOT CHANGE THIS ========================
}
