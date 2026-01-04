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

  reverseProxy.hosts.ollama.httpPort = config.services.ollama.port;
  reverseProxy.hosts.ai.httpPort = config.services.open-webui.port;
}
