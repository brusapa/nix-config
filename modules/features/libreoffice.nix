{
  den.aspects.libreoffice.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        libreoffice-qt
        hunspell
        hunspellDicts.en_US
        hunspellDicts.es_ES
      ];
    };
}
