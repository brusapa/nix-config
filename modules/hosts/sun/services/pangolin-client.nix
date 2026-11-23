{
  den.aspects.sun.nixos = {
    services.newt.blueprint = {
      public-resources = {
        jellyfin = {
          auth = {
            sso-enabled = false;
          };
          full-domain = "jellyfin.external.brusapa.com";
          name = "Jellyfin Sun";
          protocol = "http";
          targets = [
            {
              hostname = "localhost";
              method = "http";
              port = 8096;
            }
          ];
        };
        attic = {
          auth = {
            sso-enabled = false;
          };
          full-domain = "attic.external.brusapa.com";
          name = "Attic Sun";
          protocol = "http";
          targets = [
            {
              hostname = "localhost";
              method = "http";
              port = 6732;
            }
          ];
        };
        immich = {
          enabled = false;
          auth = {
            sso-enabled = false;
          };
          full-domain = "fotos.external.brusapa.com";
          name = "Immich Sun";
          protocol = "http";
          targets = [
            {
              hostname = "localhost";
              method = "http";
              port = 2283;
            }
          ];
        };
        serafinylapelota = {
          auth = {
            sso-enabled = false;
          };
          full-domain = "serafinylapelota.com";
          name = "Serafin y la pelota";
          protocol = "http";
          targets = [
            {
              hostname = "localhost";
              method = "http";
              port = 7651;
            }
          ];
        };
      };
    };
  };
}
