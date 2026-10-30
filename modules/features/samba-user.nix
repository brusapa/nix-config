{ ... }:
{
  den.aspects.samba-user.provides.to-hosts.nixos =
    {
      lib,
      config,
      user,
      ...
    }:
    let
      name = user.userName;
      secret = "${name}-smb-password";
    in
    lib.mkIf config.services.samba.enable {
      sops.secrets.${secret}.sopsFile = ../users/secrets.yaml;

      system.activationScripts."init_${name}_smbpasswd" = {
        deps = [
          "setupSecrets"
          "users"
        ];
        text = ''
          pw="$(< ${config.sops.secrets.${secret}.path})"
          printf '%s\n%s\n' "$pw" "$pw" \
            | ${config.services.samba.package}/bin/smbpasswd -s -a ${name}
        '';
      };
    };
}
