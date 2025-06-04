{ ... }:
{
  services.webdav = {
    enable = true;
    address = "127.0.0.1";
    port = 8989;
    behindProxy = true;
    path = "/var/lib/webdav";
    users = [
      {
        username = "obsidian-personal";
        password = "{env}OBSIDIAN_PERSONAL_PASSWORD";
        permissions = "CRUD";
        directory = "/var/lib/webdav/obsidian-personal";
      },
      {
        username = "obsidian-work";
        password = "{env}OBSIDIAN_WORK_PASSWORD";
        permissions = "CRUD";
        directory = "/var/lib/webdav/obsidian-work";
      }
    ];
  };
}
