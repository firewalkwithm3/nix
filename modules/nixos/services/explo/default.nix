{
  inputs,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.explo;

  envFile = pkgs.writeTextFile {
    name = "explo-env";
    destination = "/bin/.env";
    text = ''
      EXPLO_SYSTEM=${cfg.settings.server.type}
      SYSTEM_URL=${cfg.settings.server.url}
      SYSTEM_USERNAME=${cfg.settings.server.user}
      DOWNLOAD_DIR=${cfg.settings.downloadDir}
      LISTENBRAINZ_USER=${cfg.settings.listenbrainz.user}
      PERSIST=${boolToString cfg.settings.persist}
      LISTENBRAINZ_DISCOVERY=${cfg.settings.listenbrainz.discovery}
    '';
  };

  exploWithEnv = pkgs.buildEnv {
    name = "exploWithEnv";
    paths = [
      pkgs.${namespace}.explo
      envFile
    ];
  };
in
{
  options.${namespace}.services.explo = with types; {
    enable = mkBoolOpt false "Enable explo";
    user = mkStrOpt "explo" "User to run as";
    group = mkStrOpt "media" "Group to run as";
    secretsFile = mkStrOpt config.age.secrets.explo.path "File where secrets are stored";
    settings = {
      persist = mkBoolOpt false "Whether to keep old playlists";
      downloadDir = mkStrOpt "/mnt/volume2/media/beets/explo" "Directory to download music to";
      server = {
        type = mkStrOpt "subsonic" "Type of server";
        url = mkStrOpt "https://music.fern.garden" "Address of server";
        user = mkStrOpt "fern" "Username for server";
      };
      listenbrainz = {
        user = mkStrOpt "mtqueerie" "Username for Listenbrainz";
        discovery = mkStrOpt "playlist" "How to retrieve recommendations";
      };
    };
  };

  config = mkIf cfg.enable {
    age.secrets.explo.rekeyFile = (inputs.self + "/secrets/services/explo.age");

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = { };

    systemd.services.explo = {
      description = " Spotify's \"Discover Weekly\" for self-hosted music systems";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      documentation = [ "https://github.com/LumePart/Explo" ];
      startAt = "Mon 07:00:00";

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.secretsFile;
        ExecStart = "${exploWithEnv}/bin/explo";
        WorkingDirectory = "${exploWithEnv}/bin";
      };
    };
  };
}
