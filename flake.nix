{

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: {

    # NixOS module
    nixosModule = { config, ... }:
      with nixpkgs.lib;
      {
        options = {
          enable = mkEnableOption "Enable BoomPow client";
          
          user = mkOption {
            type = types.str;
            default = "bpow";
            description = "User under which the client runs";
          };

          group = mkOption {
            type = types.str;
            default = "bpow";
            description = "Group under which the client runs";
          };
        };

        config = mkIf config.enable {
          systemd.services.bpow-client = {
            description = "BoomPow client";
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            restartIfChanged = true;
            serviceConfig = {
              type = "simple";
              User = config.user;
              Group = config.group;
              Restart = "always";
              RestartSec = "5s";
              PermissionsStartOnly = true;
        
              ExecStart = ''
                while true; do echo running; sleep 1; done
              '';
            };
          };
        };
      };

  } // (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {

          # nano-work-server
          packages.nano-work-server =
            pkgs.stdenv.mkDerivation {
              name = "nano-work-server";
              src = "${self}/client/bin/linux";
              buildInputs = with pkgs; [
                ocl-icd
              ];
              nativeBuildInputs = with pkgs; [
                autoPatchelfHook
              ];
              installPhase = ''
                install -m 755 -D nano-work-server $out/bin/nano-work-server
              '';
            };

          # bpow-client
          packages.bpow-client =
            pkgs.python3Packages.buildPythonApplication rec {
              name = "bpow-client";
              src = "${self}/client";
              propagatedBuildInputs = with pkgs.python3Packages; [
                amqtt
                aiohttp
                requests
                setuptools
              ];
            };

          # Default package
          defaultPackage = self.packages.${system}.nano-work-server;
        }

      ));
}
