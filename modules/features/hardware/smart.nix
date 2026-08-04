{
  den.aspects.smart = {
    nixos =
      {
        pkgs,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          smartmontools # SMART cli support
        ];

        # SMART checks
        services.smartd = {
          enable = true;
          notifications = {
            # TODO: Enable only when mail is working
            mail.enable = true;
          };
        };
      };
  };
}
