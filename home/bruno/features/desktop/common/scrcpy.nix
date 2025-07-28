{ pkgs, ... }:
{
  home.packages = with pkgs; [
    scrcpy
    (writeShellScriptBin "scrcpy-bruno" ''
      ${pkgs.scrcpy}/bin/scrcpy --tcpip=movil-bruno.rex-eagle.ts.net:39411
    '')
  ];
}