{
  den.aspects.bruno.cli.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      nixfmt
      nixd
      alejandra
    ];
  };
}
