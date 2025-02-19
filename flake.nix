{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    stylix.url = "github:danth/stylix/release-24.11";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crowdsec = {
      url = "git+https://codeberg.org/kampka/nix-flake-crowdsec.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    authentik-nix.url = "github:nix-community/authentik-nix";

    lurker.url = "github:oppiliappan/lurker";
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      impermanence,
      disko,
      auto-cpufreq,
      home-manager,
      niri,
      stylix,
      nixvim,
      agenix,
      agenix-rekey,
      crowdsec,
      authentik-nix,
      lurker,
      ...
    }@inputs:

    let
      commonModules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        stylix.nixosModules.stylix
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
        }
      ];

      laptopModules = commonModules ++ [
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
        auto-cpufreq.nixosModules.default
        niri.nixosModules.niri
      ];

      serverModules = commonModules ++ [
        authentik-nix.nixosModules.default
        crowdsec.nixosModules.crowdsec
        crowdsec.nixosModules.crowdsec-firewall-bouncer
        lurker.nixosModules.default
      ];

      commonSpecialArgs = {
        inherit inputs;

        yubikey.pubKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo=";

        hosts = {
          forest = {
            pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLhv0WaxWuQhBb3BG4wrebkb+egB2hdeysbODTGXSSQ";
            installDisk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENA1K324390";
          };
          garden = {
            pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEp5zVloqXFtLEVCl44MwvdkfzIL4MsLqmENXjgPfnQ";
            wg_address = "10.1.0.2/24";
          };
          leaf = {
            pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIUqrhHngT/CRIjF6024MqJNy03ed7dSdKpN/7HSpToX";
            wg_address = "10.1.0.4/24";
            installDisk = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_mSATA_250GB_S41MNG0K821487A";
          };
        };
      };

    in
    {
      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      nixosConfigurations.garden = nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = laptopModules ++ [
          lanzaboote.nixosModules.lanzaboote
          { home-manager.users.fern = import ./home/hosts/garden.nix; }
          ./system/hosts/garden.nix
        ];
      };

      nixosConfigurations.leaf = nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = laptopModules ++ [
          { home-manager.users.fern = import ./home/hosts/leaf.nix; }
          ./system/hosts/leaf.nix
        ];
      };

      nixosConfigurations.forest = nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = serverModules ++ [
          lanzaboote.nixosModules.lanzaboote
          { home-manager.users.fern = import ./home/hosts/forest.nix; }
          ./system/hosts/forest
        ];
      };
    };
}
