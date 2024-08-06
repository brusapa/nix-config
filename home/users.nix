{ inputs, lib, config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.users.gid = 100;

  users.users.bruno = {
    isNormalUser = true;
    description = "Bruno";
    uid = 1000;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdwwDbi4z8NgQeVGjl5dOI9MITbpFGiDOe1SE5QiTO9a548DoMTDdnerY7gkiOXSuPjTSTzVOBT3x28INhMaIQ6MqjgETDvYQlSdnFGZ1Ai1MJl02JOUoE+QiloI2U0qlVoJZrqDcYj1xL6MBTTzZhlJ0FMxFHjFd0HLDCXXMeTcXcAju5aPrrXyR+HcCKqJrYPHKH86gCGzHQVvH6Os26Oe6ykZw2iH/B8ev47Yae/0w3c09DN1uqxeTPr0/SHK6nQc6JrG0cs8V1Nt96WXtQOWqB9R1DpbdWmPY0Hh5t5WrTFdsS54JU8N02soYc6uCLPnxv4i7REzgCwwXJrC6Fxmvu5qBPGTfhi9ES6UlE+RRFxUJ8+EeG8Q2c9xXufsqvqacswc9le7QvsxiC3bQK95BXwc1p9q2ACJtay80OtgnEUMarwdWBzZzwEHtCz9gMnsPh+wwRowZy/cPurvHCtk76qMPhILe4XDs3njw/Lmtpl7zjf/3hILLQlNyELLjXmv9wncGmQs+XZ1Z1htmClQRpzpy83Q1dfuJH2cPOG3OZcouf2tIPUZI+lb/CTtPXndDH1sYs6Sqt1WVk17uwLFq1JIWKhUOYO/z1z/0e6+A0rmeZlMIn2AGW7v96RfRhWP6WSrwdjc5z1ZQYTOuhlcfb2dKMbfd8nxwZ0pRNyw== Yubikey"
    ];
    home = "/home/bruno";
    createHome = true;
  };

  users.users.gurenda = {
    isNormalUser = true;
    description = "Gurenda";
    home = "/home/gurenda";
    createHome = true;
  };
}