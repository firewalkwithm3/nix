{
  config,
  inputs,
  pkgs,
  hosts,
  ...
}:
let
  uid = toString config.users.users.fern.uid;
in
{
  # Install agenix-rekey and related tools
  environment.systemPackages = with pkgs; [
    inputs.agenix-rekey.packages.${pkgs.system}.default
    rage
    age-plugin-yubikey
  ];

  # Create tmpfile for agenix
  systemd.tmpfiles.settings."10-agenix" = {
    "/tmp/agenix-rekey.${uid}" = {
      d = {
        group = "users";
        mode = "0755";
        user = "fern";
      };
    };
  };

  nix.settings.extra-sandbox-paths = [ "/tmp/agenix-rekey.${uid}" ];

  # agenix-rekey config
  age.rekey = {
    masterIdentities = [ ./yubikey.pub ];
    storageMode = "derivation";
    hostPubkey = hosts.${config.networking.hostName}.pubKey;
  };
}
