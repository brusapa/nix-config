{ lib, pkgs, ... }:

{
  xdg.mimeApps = 
  {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "application/json" = [ "code.desktop" ];
      "application/pdf" = [ "okularApplication_pdf.desktop" ];
      "application/x-docbook+xml" = [ "code.desktop" ];
      "application/x-yaml" = [ "code.desktop" ];
      "text/markdown" = [ "code.desktop" ];
      "text/plain" = [ "code.desktop" ];
      "text/x-cmake" = [ "code.desktop" ];
    };
  };
}