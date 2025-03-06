{
  options,
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.aviary;
let
  namespace = "flock";
in
{
  # ======================== DO NOT CHANGE THIS ========================
  home.stateVersion = osConfig.system.stateVersion;
  # ======================== DO NOT CHANGE THIS ========================
}
