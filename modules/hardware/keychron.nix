{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    via
  ];

  # Allow VIA access to my Keychron Q3 keyboard
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0123", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

}