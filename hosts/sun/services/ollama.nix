{ config, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "0.0.0.0";
    openFirewall = true;
    loadModels = [
      "llama3.1:8b"
      "qwen3:8b"
      "minicpm-v:8b"
    ];
  };
  services.open-webui = {
    enable = true;
    port = 11111;
    host = "0.0.0.0";
    openFirewall = false;
    environment = {
      OLLAMA_API_BASE = "http://localhost:${toString config.services.ollama.port}";
    };
  };
  services.caddy.virtualHosts."ollama.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.ollama.port}
  '';
  services.caddy.virtualHosts."ai.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.open-webui.port}
  '';
}
