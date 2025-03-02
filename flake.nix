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
    packages.${system}.default = pkgs.stdenv.mkDerivation rec {
      pname = "cs2-web-panel";
      version = "0.1.0";

      src = ./.;

      buildInputs = [ pkgs.nodejs_20 ];

      buildPhase = ''
        npm install
      '';

      # installPhase = ''
      #   mkdir -p $out/bin
      #   cp -r * $out/
      # '';
    };

    nixosModules = {
      cs2-web-panel = { config, lib, pkgs, ... }: with lib; {
        options.cs2-web-panel = {
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

        config = mkIf config.cs2-web-panel.enable {
          systemd.services.cs2-web-panel = {
            description = "CS2 Web Panel Service";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              ExecStart = ''
                ${pkgs.nodejs_20}/bin/node ${self.packages.x86_64-linux}/app.js
              '';
              Environment = ''
                PORT=${toString config.cs2-web-panel.port}
                PANEL_USERNAME=${config.cs2-web-panel.username}
                PANEL_PASSWORD=${config.cs2-web-panel.password}
              '';
              Restart = "always";
            };
          };
        };
      };
    };
  };
}

