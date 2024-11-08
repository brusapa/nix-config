{...}: {
  home.file.".ssh/id_ed25519_sk.pub".source = ../../ssh.pub;

  home.file.".ssh/allowed_signers".text = "* ${builtins.readFile ../../ssh.pub}";

  programs.ssh = {
    enable = true;
    forwardAgent = true;
  };
}
