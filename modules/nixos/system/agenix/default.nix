{
  config,
  lib,
  pkgs,
  namespace,
  options,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.agenix;
in
{
  options.${namespace}.agenix = with types; {
    enable = mkBoolOpt true "Enable agenix secrets management";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      agenix-rekey
      rage
      age-plugin-yubikey
    ];

    systemd.tmpfiles.settings."10-agenix" = {
      "/tmp/agenix-rekey" = {
        d = {
          group = "users";
          mode = "0755";
          user = "fern";
        };
      };
    };

    nix.settings.extra-sandbox-paths = [ "/tmp/agenix-rekey" ];

    age.identityPaths = mkIf config.${namespace}.impermanence.enable (
      options.age.identityPaths.default
      ++ [
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ]
    );

    age.rekey = {
      masterIdentities = [ ./yubikey.pub ];
      storageMode = "derivation";
      cacheDir = "/tmp/agenix-rekey";
      hostPubkey = config.${namespace}.services.openssh.pubKey;
    };
  };
}
