{
  den.aspects.zfsBackupPuller.nixos = 
    { lib, config, ... }:
    let
      cfg = config.services.zfsBackupPuller;

      shortName = hostname: builtins.head (lib.splitString "." hostname);

      sendOptions = "w";
      recvOptions = "up";
      extraArgs = [
        "--no-sync-snap"
        "--create-bookmark"
      ];

      targetSanoidTemplate = {
        autosnap = false;
        autoprune = true;
        hourly = 48;
        daily = 14;
        monthly = 6;
        yearly = 0;
      };

      targetPath =
        pool: hostName: poolName: datasetName:
        "${pool.targetPool}/backups/${shortName hostName}/${poolName}/${datasetName}";

      allTargetDatasets = lib.concatMap (
        hostName:
        let
          host = cfg.hosts.${hostName};
        in
        lib.concatMap (
          poolName:
          let
            pool = host.pools.${poolName};
          in
          map (datasetName: targetPath pool hostName poolName datasetName) pool.datasets
        ) (lib.attrNames host.pools)
      ) (lib.attrNames cfg.hosts);

      mkHostCommands =
        hostName: host:
        lib.concatMapAttrs (
          poolName: pool:
          lib.listToAttrs (
            map (datasetName: {
              name = "backup-${shortName hostName}-${poolName}-${datasetName}";
              value = {
                source = "${host.sshUser}@${hostName}:${poolName}/${datasetName}";
                target = targetPath pool hostName poolName datasetName;
                inherit sendOptions recvOptions extraArgs;
              };
            }) pool.datasets
          )
        ) host.pools;

      poolSubmodule = lib.types.submodule {
        options = {
          targetPool = lib.mkOption {
            type = lib.types.str;
            default = "zstorage";
            description = "Pool local que recibe la réplica.";
          };
          datasets = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Datasets a respaldar bajo este pool.";
          };
        };
      };

      hostSubmodule = lib.types.submodule {
        options = {
          sshUser = lib.mkOption {
            type = lib.types.str;
            default = "zfspuller";
          };
          pools = lib.mkOption {
            type = lib.types.attrsOf poolSubmodule;
            default = { };
            description = "Pools remotos a respaldar, indexados por nombre.";
          };
        };
      };
    in
    {
      options.services.zfsBackupPuller.hosts = lib.mkOption {
        description = "Hosts remotos desde los que tirar (pull) vía syncoid, indexados por hostname (FQDN).";
        default = { };
        type = lib.types.attrsOf hostSubmodule;
      };

      config = {
        services.syncoid = {
          enable = lib.mkIf (allTargetDatasets != [ ]) true;
          commands = lib.concatMapAttrs mkHostCommands cfg.hosts;
        };

        services.sanoid = {
          enable = lib.mkIf (allTargetDatasets != [ ]) true;
          datasets = lib.listToAttrs (
            map (dataset: lib.nameValuePair dataset targetSanoidTemplate) allTargetDatasets
          );
        };
      };
    };
}