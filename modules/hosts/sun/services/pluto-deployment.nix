{
  den.aspects.sun.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "deploy-pluto";
          text = ''
            out=$(nix build --no-link --print-out-paths \
              /etc/nixos#nixosConfigurations.pluto.config.system.build.toplevel)
            sudo nix store sign --key-file /var/lib/nix-signing/key.sec --recursive "$out"
            nixos-rebuild switch --flake /etc/nixos#pluto \
              --sudo --ask-sudo-password --target-host bruno@pluto.brusapa.com
          '';
        })
      ];
    };
}
