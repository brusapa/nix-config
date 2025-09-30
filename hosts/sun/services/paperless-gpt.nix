{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "paperless-gpt/paperless-token" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."paperless-gpt-secrets.env" = {
      content = ''
        PAPERLESS_API_TOKEN=${config.sops.placeholder."paperless-gpt/paperless-token"}
      '';
    };
  };

  virtualisation.oci-containers.containers.paperless-gpt = {
    image = "icereed/paperless-gpt:latest";

    ports = [
      "11297:8080"
    ];

    volumes = [
      "/var/lib/paperless-gpt/prompts:/app/prompts"
      "/var/lib/paperless-gpt/hocr:/app/hocr"
      "/var/lib/paperless-gpt/pdf:/app/pdf"
    ];

    environmentFiles = [
      config.sops.templates."paperless-gpt-secrets.env".path
    ];

    environment = {
      TZ = "Europe/Madrid";
      PAPERLESS_BASE_URL = "https://documentos.brusapa.com";

      # Ollama (Local)
      LLM_PROVIDER = "ollama";
      LLM_MODEL = "qwen3:8b";
      OLLAMA_HOST = "http://10.80.0.15:" + (toString config.services.ollama.port);
      TOKEN_LIMIT = "1000"; # Recommended for smaller models

      # Optional LLM Settings
      LLM_LANGUAGE = "Spanish";

      # OCR Configuration
      OCR_PROVIDER = "llm";
      VISION_LLM_PROVIDER = "ollama";
      VISION_LLM_MODEL = "minicpm-v:8b";

      # OCR Processing Mode
      OCR_PROCESS_MODE = "image";

      # Enhanced OCR Features
      CREATE_LOCAL_HOCR = "true"; # Optional, save hOCR files locally
      LOCAL_HOCR_PATH = "/app/hocr"; # Optional, path for hOCR files
      CREATE_LOCAL_PDF = "true"; # Optional, save enhanced PDFs locally
      LOCAL_PDF_PATH = "/app/pdf"; # Optional, path for PDF files

      # PDF Upload to paperless-ngx
      PDF_UPLOAD = "false"; # Optional, upload enhanced PDFs to paperless-ngx
      PDF_REPLACE = "false"; # Optional and DANGEROUS, delete original after upload
      PDF_COPY_METADATA = "true"; # Optional, copy metadata from original document
      PDF_OCR_TAGGING = "true"; # Optional, add tag to processed documents
      PDF_OCR_COMPLETE_TAG = "paperless-gpt-ocr-complete"; # Optional, tag name

      AUTO_OCR_TAG = "paperless-gpt-ocr-auto"; # Optional, default: paperless-gpt-ocr-auto
      OCR_LIMIT_PAGES = "5"; # Optional, default: 5. Set to 0 for no limit.
      LOG_LEVEL = "info"; # Optional: debug, warn, error
    };
  };

  services.caddy.virtualHosts."paperless-gpt.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:11297
  '';
}
