{
  config,
  osConfig,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli.git;
in
{
  options.${namespace}.cli.git = with types; {
    enable = mkBoolOpt false "Enable git";
    email = mkStrOpt osConfig.${namespace}.user.email "User's email";
    name = mkStrOpt osConfig.${namespace}.user.fullName "User's name";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userEmail = cfg.email;
      userName = cfg.name;
    };
  };
}
