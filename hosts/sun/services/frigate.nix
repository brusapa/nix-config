{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "frigate/mqtt-password" = {
        sopsFile = ../secrets.yaml;
      };
      "frigate/rtsp-menta-password" = {
        sopsFile = ../secrets.yaml;
      };
      "frigate/rtsp-nora-password" = {
        sopsFile = ../secrets.yaml;
      };
      "frigate/rtsp-dormitorio-password" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."karakeep-secrets.env" = {
      content = ''
        FRIGATE_MQTT_PASSWORD=${config.sops.placeholder."frigate/mqtt-password"}
        FRIGATE_RTSP_MENTA_PASSWORD=${config.sops.placeholder."frigate/rtsp-menta-password"}
        FRIGATE_RTSP_NORA_PASSWORD=${config.sops.placeholder."frigate/rtsp-nora-password"}
        FRIGATE_RTSP_DORMITORIO_PASSWORD=${config.sops.placeholder."frigate/rtsp-dormitorio-password"}
      '';
    };
  };



  services.frigate = {
    enable = true;
    vaapiDriver = "iHD";
    settings = {
      mqtt = {
        enabled = true;
        host = 127.0.0.1;
        user = "mosquitto";
        password = "{FRIGATE_MQTT_PASSWORD}"; # TODO PWD
      };
      ffmpeg.hwaccel_args = "preset-vaapi";
      detect.enabled = true;
      detectors.ov = {
        type = "openvino";
        device = "GPU";
      };
      model = {
        path = "/config/yolov9-t-320.onnx"; # TODO Revisar esto
        model_type = "yolo-generic";
        width = 320;
        height = 320;
        input_tensor = "nchw";
        input_dtype = "float";
        labelmap_path = "/labelmap/coco-80.txt"; # TODO Revisar esto
      };
      record = {
        enabled = true;
        retain = {
          days = 7;
          mode = "motion";
        };
        alerts.retain.days = 7;
        detections.retain.days = 7;
      };
      snapshots = {
        enabled = true;
        retain.default = 7;
      };
      go2rtc = {
        streams = {
          camara-menta = [
            "ffmpeg:rtsp://admin:{FRIGATE_RTSP_MENTA_PASSWORD}@10.80.2.3:554/h264Preview_01_main#video=copy#audio=copy"
          ];
          camara-menta-sub = [
            "ffmpeg:rtsp://admin:{FRIGATE_RTSP_MENTA_PASSWORD}@10.80.2.3:554/h264Preview_01_sub#video=copy#audio=copy"
          ];
          camara-nora = [
            "rtsp://admin:{FRIGATE_RTSP_NORA_PASSWORD}@10.80.2.4:554/h264Preview_01_main"
            "ffmpeg:camara-nora#audio=opus"
          ];
          camara-nora_sub = [
            "rtsp://admin:{FRIGATE_RTSP_NORA_PASSWORD}@10.80.2.4:554/h264Preview_01_sub"
            "ffmpeg:camara-nora_sub#audio=opus"
          ];
          camara-dormitorio = [
            "rtsp://tapoadmin:{FRIGATE_RTSP_DORMITORIO_PASSWORD}@10.80.2.6:554/stream1"
            "ffmpeg:camara-dormitorio#audio=aac#video=h264#hardware"
          ];
          camara-dormitorio_sub = [
            "rtsp://tapoadmin:{FRIGATE_RTSP_DORMITORIO_PASSWORD}@10.80.2.6:554/stream2"
            "ffmpeg:camara-dormitorio_sub#audio=aac#video=h264#hardware"
          ];
        };
        webrtc.candidates = [
          "127.0.0.1:8555"
          "100.73.55.34:8555"
          "10.80.0.15:8555"
          "sun.brusapa.com:8555"
          "frigate.brusapa.com:8555"
        ];
      };
      cameras = {
        camara-menta = {
          enabled = false;
          ffmpeg.inputs = [
            {
              path = "rtsp://127.0.0.1:8554/camara-menta";
              input_args: "preset-rtsp-restream";
              roles = [ "record" ];
            }
            {
              path = "rtsp://127.0.0.1:8554/camara-menta_sub";
              input_args: "preset-rtsp-restream";
              roles = [ "detect" ];
            }
          ];
        };
        camara-nora = {
          enabled = false;
          ffmpeg.inputs = [
            {
              path = "rtsp://127.0.0.1:8554/camara-nora";
              input_args: "preset-rtsp-restream";
              roles = [ "record" ];
            }
            {
              path = "rtsp://127.0.0.1:8554/camara-nora_sub";
              input_args: "preset-rtsp-restream";
              roles = [ "detect" ];
            }
          ];
        };
        camara-dormitorio = {
          enabled = false;
          ffmpeg.inputs = [
            {
              path = "rtsp://127.0.0.1:8554/camara-dormitorio";
              input_args: "preset-rtsp-restream";
              roles = [ "record" ];
            }
            {
              path = "rtsp://127.0.0.1:8554/camara-dormitorio_sub";
              input_args: "preset-rtsp-restream";
              roles = [ "detect" ];
            }
          ];
        };
      };
    };
  };
}