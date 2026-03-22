{
  config,
  lib,
  pkgs,
  rev,
  ...
}:
let
  cfg = config.services.btrfs-nfs-csi.agent;

  inherit (lib)
    mkEnableOption
    mkOption
    ;

  inherit (lib.types) package;
in
{
  options.services.btrfs-nfs-csi.agent = {
    enable = mkEnableOption "BTRFS-NFS CSI agent";

    basePath = lib.mkOption {
      type = lib.types.str;
      default = "/export/data";
      description = "Base path for btrfs subvolume creation (AGENT_BASE_PATH)";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file containing secrets such as AGENT_TENANTS";
    };

    listenAddr = lib.mkOption {
      type = lib.types.str;
      default = ":8000";
      description = "Address for the agent to listen on (AGENT_LISTEN_ADDR)";
    };

    package = mkOption {
      type = package;
      description = "The btrfs-nfs-csi package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.btrfs-nfs-csi-agent.environmentFile must be set because AGENT_TENTATS is required to run the service";
      }
    ];

    # This parodies deploy/agent/agent.service
    systemd.services."btrfs-nfs-csi-agent" = {
      description = "btrfs-nfs-csi agent";
      after = [ "network.target" ];

      environment = {
        AGENT_BASE_PATH   = cfg.basePath;
        AGENT_LISTEN_ADDR = cfg.listenAddr;
      };

      path = [
        pkgs.btrfs-progs
        pkgs.nfs-utils
      ];

      script = "${cfg.package}/bin/btrfs-nfs-csi agent";
      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;
        Restart = "always";
        RestartSec = "5";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

