{ lib, ... }:
{
  virtualisation.oci-containers.containers = {
    memos = {
      image = "neosmemo/memos:latest";
      ports = [ "5230:5230" ];
      volumes = [
        "memos:/var/opt/memos"
      ];
      extraOptions = [ "--pull=newer" ];
    };
  };

  services.caddy.virtualHosts."memos.ferngarden.net" = {
    logFormat = lib.mkForce ''
      	    output discard
      	  '';
    extraConfig = ''
      	    reverse_proxy 127.0.0.1:5230
      	  '';
  };
}
