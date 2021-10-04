{

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: {

    # NixOS module
    nixosModule = { config, ... }:
      with nixpkgs.lib;
      let
        cfg = config.services.boompow;
      in
      {
        options.services.boompow = {

          enable = mkEnableOption "Enable the nano-work-server and bpow-client as systemd services.";

          cpuThreads = mkOption {
            type = types.int;
            default = 1;
            description = ''
              Specifies how many CPU threads to use.

              This option is only applied if 'mode' is set to 'cpu'.
            '';
          };

          gpuAddress = mkOption {
            type = types.str;
            default = "0:0";
            description = ''
              Specifies which GPU(s) to use in the form <PLATFORM:DEVICE:THREADS>...
              THREADS is optional and defaults to 1048576.

              This option is only applied if 'mode' is set to 'gpu'.
            '';
          };

          group = mkOption {
            type = types.str;
            default = "bpow";
            description = "Group under which the BoomPow client and Nano work server run.";
          };

          mode = mkOption {
            type = types.enum [ "cpu" "gpu" ];
            default = "gpu";
            description = ''
              Run the Nano work server in CPU or GPU mode.

              Use the options 'gpuAddress' and 'cpuThreads' to configure the modes.
            '';
          };

          port = mkOption {
            type = types.int;
            default = 7000;
            description = "Local port of the Nano work server.";
          };

          user = mkOption {
            type = types.str;
            default = "bpow";
            description = "User under which the BoomPow client and Nano work server run.";
          };

          walletAddress = mkOption {
            type = types.str;
            description = "Banano wallet address which will receive the payments.";
          };

          workType = mkOption {
            type = types.enum [ "any" "ondemand" "precache" ];
            default = "any";
            description = "Work type, one of 'any', 'ondemand' or 'precache'.";
          };
        };

        config = mkIf cfg.enable {

          # Systemd service for bpow-client
          systemd.services.bpow-client = {
            description = "BoomPow client";
            after = [ "nano-work-server.service" ];
            wantedBy = [ "multi-user.target" ];
            restartIfChanged = true;
            serviceConfig = {
              Type = "simple";
              User = cfg.user;
              Group = cfg.group;
              Restart = "always";
              RestartSec = "5s";
              PermissionsStartOnly = true;
              ExecStart = ''
                ${self.packages.${config.nixpkgs.localSystem.system}.bpow-client}/bin/bpow-client \
                  --payout ${cfg.walletAddress} \
                  --work ${cfg.workType} \
                  --worker_uri 127.0.0.1:${toString cfg.port} \
                  --limit-logging
              '';
            };
          };

          # Systemd service for nano-work-server
          systemd.services.nano-work-server = {
            description = "nano work server";
            after = [ "network.target" ];
            before = [ "bpow-client.service" ];
            wantedBy = [ "multi-user.target" ];
            restartIfChanged = true;
            serviceConfig = {
              Type = "simple";
              User = cfg.user;
              Group = cfg.group;
              Restart = "always";
              RestartSec = "5s";
              PermissionsStartOnly = true;
              ExecStart = ''
                ${self.packages.${config.nixpkgs.localSystem.system}.nano-work-server}/bin/nano-work-server \
                   ${if cfg.mode == "gpu" then "--gpu ${cfg.gpuAddress}" else "--cpu-threads ${toString cfg.cpuThreads}"} \
                   --listen-address 127.0.0.1:${toString cfg.port}
              '';
            };
          };

          # User and group
          users.users = mkIf (cfg.user == "bpow") {
            bpow = {
              group = cfg.group;
              isSystemUser = true;
            };
          };
          users.groups = mkIf (cfg.group == "bpow") {
            bpow = {};
          };

        };
      };

  } // (flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        {

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

          # Default package
          defaultPackage = self.packages.${system}.bpow-client;
        }

    ));
}
