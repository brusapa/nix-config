{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [
      "llama3.1:8b"
    ];
  };
  services.open-webui = {
    enable = true;
    port = 11111;
    host = "0.0.0.0";
    openFirewall = true;
    environment = {
      OLLAMA_API_BASE = "http://127.0.0.1:11434";
    };
  };
}
