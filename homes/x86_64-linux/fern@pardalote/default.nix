{
  osConfig,
  ...
}:
let
  namespace = "flock";
in
{
  ${namespace}.suites.laptop.enable = true;

  # ======================== DO NOT CHANGE THIS ========================
  home.stateVersion = osConfig.system.stateVersion;
  # ======================== DO NOT CHANGE THIS ========================
}
