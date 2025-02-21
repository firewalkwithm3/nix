{ lib, ... }:
{
  options.security.pam.services =
    with lib;
    with types;
    mkOption {
      type = attrsOf (
        submodule (
          { config, ... }:
          {
            config.u2fAuth = true;
            config.rules.auth = {
              u2f = {
                order = config.rules.auth.unix.order + 10;
                control = "sufficient";
                args = [
                  "pinverification=1"
                  "userpresence=1"
                ];
              };
            };
          }
        )
      );
    };
}
