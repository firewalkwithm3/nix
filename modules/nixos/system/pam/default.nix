{
  inputs,
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
    security.pam.services = mkOption {
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

    ${namespace}.pam = with types; {
      enable = mkBoolOpt true "Enable PAM configuration";
      yubikey.enable = mkBoolOpt config.${namespace}.yubikey.enable "Enable YubiKey PAM rules";
      rssh.enable = mkBoolOpt false "Enable RSSH PAM rules";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.rssh.enable {
      security.pam = {
        rssh.enable = true;
        services.sudo.rssh = true;
      };
    })

    (mkIf cfg.yubikey.enable {
      age.secrets.u2f_keys = {
        rekeyFile = (inputs.self + "/secrets/u2f_keys.age");
        owner = "fern";
      };

      security.pam.u2f = {
        settings = {
          cue = true;
          authfile = config.age.secrets.u2f_keys.path;
          origin = "fern";
        };
      };

      security.pam = {
        services = {
          sudo.rules.auth = {
            u2f.order = lib.mkForce (config.security.pam.services.sudo.rules.auth.unix.order - 10);
          };
          gtklock.rules.auth = {
            u2f.args = lib.mkForce [
              "pinverification=0"
              "userpresence=1"
            ];
          };
        };
      };
    })
  ]);
}
