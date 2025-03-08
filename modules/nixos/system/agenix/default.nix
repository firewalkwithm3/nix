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

    age.rekey =
      let
        yubikeyPubKey = pkgs.writeText "yubikey.pub" ''
          #       Serial: 30220854, Slot: 1
          #         Name: agenix-rekey
          #      Created: Sat, 15 Feb 2025 04:16:11 +0000
          #   PIN policy: Once   (A PIN is required once per session, if set)
          # Touch policy: Cached (A physical touch is required for decryption, and is cached for 15 seconds)
          #    Recipient: age1yubikey1q067ueujmw6jvfrqa3sdlhy004kyqlp8gmv7hjy7pqgfwehzr8q7y3eegdy
          AGE-PLUGIN-YUBIKEY-1XC3V6QVZ08WTJ6GM3CGKY
        '';

      in
      {
        masterIdentities = [ "${yubikeyPubKey}" ];
        storageMode = "derivation";
        cacheDir = "/tmp/agenix-rekey";
        hostPubkey = config.${namespace}.services.openssh.pubKey;
      };
  };
}
