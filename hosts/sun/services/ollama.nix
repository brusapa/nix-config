{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
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
      OLLAMA_API_BASE = "http://127.0.0.1:11434";
    };
  };
  services.caddy.virtualHosts."ollama.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:11434;
  '';
  services.caddy.virtualHosts."ai.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:11111
  '';
}
