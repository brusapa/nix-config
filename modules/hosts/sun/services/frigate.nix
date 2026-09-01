{ den, ... }:
{
  den.aspects.sun = {
    includes = [
      den.aspects.frigate
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "frigate/mqtt-password" = { };
            "frigate/reolink-rtsp-password" = { };
            "frigate/tapo-admin-password" = { };
          };
          templates."frigate-secrets.env" = {
            content = ''
              FRIGATE_MQTT_PASSWORD=${config.sops.placeholder."frigate/mqtt-password"}
              FRIGATE_REOLINK_RTSP_PASSWORD=${config.sops.placeholder."frigate/reolink-rtsp-password"}
              FRIGATE_TAPO_ADMIN_PASSWORD=${config.sops.placeholder."frigate/tapo-admin-password"}
            '';
          };
        };

        frigate = {
          hwaccel-driver = "iHD";
          media-path = "/mnt/internalBackup/frigate";
          environmentFiles = [
            config.sops.templates."frigate-secrets.env".path
          ];
          settings = ''
            ui:
              time_format: 24hour

            mqtt:
              enabled: true
              host: mqtt.brusapa.com
              user: mosquitto
              password: '{FRIGATE_MQTT_PASSWORD}'
              port: 8883
              tls_ca_certs: /etc/ssl/certs/ca-certificates.crt

            ffmpeg:
              hwaccel_args: preset-vaapi

            detect:
              enabled: true

            detectors:
              ov:
                type: openvino
                device: GPU

            model:
              path: /config/yolov9-t-320.onnx
              model_type: yolo-generic
              width: 320 # <--- should match the imgsize set during model export
              height: 320 # <--- should match the imgsize set during model export
              input_tensor: nchw
              input_dtype: float
              labelmap_path: /labelmap/coco-80.txt

            record:
              enabled: true
              continuous:
                days: 7
              motion:
                days: 14
              alerts:
                retain:
                  days: 30
                  mode: all
              detections:
                retain:
                  days: 30
                  mode: all

            snapshots:
              enabled: true
              retain:
                default: 7

            go2rtc:
              streams:
                camara-menta:
                  - "ffmpeg:http://camaramenta.home/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}#video=copy#audio=copy#audio=opus"
                camara-menta_sub:
                  - "ffmpeg:http://camaramenta.home/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}"
                camara-nora:
                  - "ffmpeg:http://camaranora.home/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}#video=copy#audio=copy#audio=opus"
                camara-nora_sub:
                  - "ffmpeg:http://camaranora.home/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}"
                camara-dormitorio:
                  - ffmpeg:rtsp://tapoadmin:{FRIGATE_TAPO_ADMIN_PASSWORD}@camaradormitorio.home:554/stream1#video=copy#audio=copy#audio=aac

              webrtc:
                listen: ":8555"
                filters:
                  networks: [udp4, tcp4]
                candidates:
                  - 127.0.0.1:8555
                  - 100.73.55.34:8555
                  - 10.80.0.15:8555
                  - go2rtc.brusapa.com:8555
                  - sun.brusapa.com:8555
                  - frigate.brusapa.com:8555


            cameras:
              camara-menta:
                enabled: false
                ffmpeg:
                  inputs:
                    - path: rtsp://127.0.0.1:8554/camara-menta
                      input_args: preset-rtsp-restream
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/camara-menta_sub
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
              camara-nora:
                ffmpeg:
                  inputs:
                    - path: rtsp://127.0.0.1:8554/camara-nora
                      input_args: preset-rtsp-restream
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/camara-nora_sub
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
              camara-dormitorio:
                ffmpeg:
                  output_args:
                    record: preset-record-generic-audio-copy
                  inputs:
                    - path: rtsp://127.0.0.1:8554/camara-dormitorio?video=copy&audio=aac
                      input_args: preset-rtsp-restream
                      roles:
                        - record
                        - detect
                        - audio
                motion:
                  mask: 0.365,0.061,0.365,0,0,0,0,0.061
            version: 0.17-0
          '';
        };
      };
  };
}
