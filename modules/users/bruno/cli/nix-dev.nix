{
  den.aspects.bruno.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      nixfmt
      nixd
      alejandra
    ];
  };
}
