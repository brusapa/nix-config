{ config, ... }:
let
  port = 7745;
in {
  services.homebox = {
    enable = true;
    settings = {
      HBOX_WEB_PORT = "${toString port}";
      HBOX_DATABASE_DRIVER = "sqlite3";
      HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
      HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
      HBOX_MODE = "production";
      HBOX_MAILER_HOST = "localhost";
      HBOX_MAILER_PORT = "25";
      HBOX_MAILER_FROM = "cosas@brusapa.com";
    };
  };

  myservices.reverseProxy.hosts.cosas.httpPort = port;
}
