{
  description = "A simple web panel to control CS2 servers using RCON";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.buildNpmPackage {
      pname = "cs2-rcon-panel";
      version = "0.1.0";
      npmDepsHash = "sha256-Af0luATZX7V86acWI42BAFprtkx9pYOyznWacsPddVQ=";

      src = ./.;

      npmBuildScript = "build";

      # Specify Node.js version 20
      nodejs = pkgs.nodejs_20;
    };

    nixosModules = {
      cs2-rcon-panel = { config, lib, pkgs, ... }: with lib; {
        options.cs2-rcon-panel = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable the CS2 Web Panel systemd service.";
          };

          port = mkOption {
            type = types.port;
            description = "The port the CS2 Web Panel will listen on.";
          };

          username = mkOption {
            type = types.str;
            description = "The username for the CS2 Web Panel.";
          };

          password = mkOption {
            type = types.str;
            description = "The password for the CS2 Web Panel.";
          };
        };

        config = mkIf config.cs2-rcon-panel.enable {
          systemd.services.cs2-rcon-panel = {
            description = "CS2 Web Panel Service";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            environment = {
              PORT="${toString config.cs2-rcon-panel.port}";
              PANEL_USERNAME="${config.cs2-rcon-panel.username}";
              PANEL_PASSWORD="${config.cs2-rcon-panel.password}";
            };

            serviceConfig = {
              ExecStart = ''
                ${pkgs.nodejs_20}/bin/node ${self.packages.x86_64-linux}/app.js
              '';
              Restart = "always";
            };
          };
        };
      };
    };
  };
}
