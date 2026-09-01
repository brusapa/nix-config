{ den, ... }:
{
  den.aspects.saturn = {
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
          };
          templates."frigate-secrets.env" = {
            content = ''
              FRIGATE_MQTT_PASSWORD=${config.sops.placeholder."frigate/mqtt-password"}
              FRIGATE_REOLINK_RTSP_PASSWORD=${config.sops.placeholder."frigate/reolink-rtsp-password"}
            '';
          };
        };

        frigate = {
          hwaccel-driver = "iHD";
          media-path = "/zsonabia/frigate";
          environmentFiles = [
            config.sops.templates."frigate-secrets.env".path
          ];
          settings = ''
            ui:
              time_format: 24hour

            mqtt:
              enabled: true
              host: mqtt.sonabia.brusapa.com
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
              path: plus://b91005c20f4c78066f3571c0dd77a5d2

            objects:
              filters:
                person:
                  min_score: 0.7
                  threshold: 0.85

            record:
              enabled: true
              continuous:
                days: 3
              motion:
                days: 7
              alerts:
                retain:
                  days: 30
                  mode: motion
                pre_capture: 5
                post_capture: 5
              detections:
                retain:
                  days: 30
                pre_capture: 5
                post_capture: 5

            snapshots:
              enabled: true
              retain:
                default: 30

            go2rtc:
              streams:
                alero_cocina:
                  - ffmpeg:http://camaracocina.home/flv?port=1935&app=bcs&stream=channel0_sub.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                alero_piscina:
                  - ffmpeg:http://camarapiscina.home/flv?port=1935&app=bcs&stream=channel0_sub.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                alero_campa:
                  - ffmpeg:http://camaracampa.home/flv?port=1935&app=bcs&stream=channel0_sub.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                alero_felix:
                  - ffmpeg:http://camaraperal.home/flv?port=1935&app=bcs&stream=channel0_sub.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                alero_felix_record:
                  - ffmpeg:http://camaraperal.home/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                alero_garaje:
                  - ffmpeg:http://camaragaraje.home/flv?port=1935&app=bcs&stream=channel0_sub.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                alero_garaje_record:
                  - ffmpeg:http://camaragaraje.home/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}
                portero:
                  - ffmpeg:http://camaraportero.home/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}#video=copy#audio=copy#audio=opus
                  - rtsp://admin:{FRIGATE_REOLINK_RTSP_PASSWORD}@camaraportero.home/Preview_01_sub
                portero_record:
                  - ffmpeg:http://camaraportero.home/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=admin&password={FRIGATE_REOLINK_RTSP_PASSWORD}

              webrtc:
                candidates:
                  - 100.75.31.27:8555
                  - 10.80.20.20:8555
                  - stun:8555


            cameras:
              alero_cocina:
                enabled: true
                ffmpeg:
                  inputs:
                    - path:
                        rtsp://admin:{FRIGATE_REOLINK_RTSP_PASSWORD}@camaracocina.home:554/h264Preview_01_main
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/alero_cocina
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
                live:
                  streams:
                    alero_cocina: alero_cocina
                motion:
                  mask:
                    - 0,0,0.208,0,0,0.379
                    - 0.665,0.534,0.928,0.617,0.998,0.545,0.998,0,0.713,0.002,0.736,0.069
                objects:
                  filters:
                    person:
                      mask:
                        - 0,0.373,0.209,0.004,0.001,0
                        - 0.61,0.041,0.707,0.144,0.711,0.212,0.701,0.522,0.938,0.592,0.992,0.555,0.996,0.006,0.582,0
                        - 0.903,1,0.97,0.569,1,0.528,1,1
                  mask:
                    - 0.61,0.041,0.707,0.144,0.711,0.212,0.701,0.522,0.938,0.592,0.992,0.555,0.996,0.006,0.582,0
                    - 0.903,1,0.97,0.569,1,0.528,1,1
              alero_piscina:
                enabled: true
                ffmpeg:
                  inputs:
                    - path:
                        rtsp://admin:{FRIGATE_REOLINK_RTSP_PASSWORD}@camarapiscina.home:554/h264Preview_01_main
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/alero_piscina
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
                live:
                  streams:
                    alero_piscina: alero_piscina
                motion:
                  mask:
                    - 0.779,0.071,1,0.075,1,0,0.781,0
                    - 0,0,1,0,1,0.514,0.944,0.426,0.739,0.138,0.56,0.039,0.556,0.08,0.483,0.059,0.479,0.087,0.409,0.101,0.407,0.132,0.346,0.149,0.349,0.229,0.293,0.252,0.301,0.299,0.264,0.321,0.246,0.368,0.043,0.795,0.014,0.731,0,0.757
              alero_campa:
                enabled: true
                ffmpeg:
                  inputs:
                    - path:
                        rtsp://admin:{FRIGATE_REOLINK_RTSP_PASSWORD}@camaracampa.home:554/h264Preview_01_main
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/alero_campa
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
                live:
                  streams:
                    alero_campa: alero_campa
                motion:
                  mask:
                    - 0.484,0.351,0.854,0.469,0.878,0.458,0.961,0.66,1,0.596,1,0.001,0,0.001,0,0.499,0.107,0.656,0.219,0.381
              alero_felix:
                enabled: true
                ffmpeg:
                  inputs:
                    - path: rtsp://127.0.0.1:8554/alero_felix_record
                      input_args: preset-rtsp-restream
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/alero_felix
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
                live:
                  streams:
                    alero_felix: alero_felix
                motion:
                  mask:
                    - 640,0,640,33,442,32,443,0
                objects:
                  filters:
                    person:
                      mask:
                        - 440,134,436,192,410,189,414,132
                        - 411,203,361,227,371,143,396,143
              alero_garaje:
                enabled: true
                ffmpeg:
                  inputs:
                    - path: rtsp://127.0.0.1:8554/alero_garaje_record
                      input_args: preset-rtsp-restream
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/alero_garaje
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
                live:
                  streams:
                    alero_garaje: alero_garaje
                motion:
                  mask:
                    - 0.688,0.089,1,0.092,1,0,0.688,0
                    - 0.834,0.467,0.999,0.499,0.999,0.004,0.831,0.001
                    - 0.292,0.001,0.185,0.389,0.069,0.444,0.072,0.649,0,0.758,0.001,0.001
                    - 0.261,0.278,0.263,0.339,0.432,0.319,0.432,0.244
              portero:
                enabled: true
                ffmpeg:
                  inputs:
                    - path: rtsp://127.0.0.1:8554/portero_record?video&audio
                      input_args: preset-rtsp-restream
                      roles:
                        - record
                    - path: rtsp://127.0.0.1:8554/portero
                      input_args: preset-rtsp-restream
                      roles:
                        - detect
                live:
                  streams:
                    portero: portero
                motion:
                  mask: 0,0.344,1,0.342,1,0,0,0
            version: 0.17-0
          '';
        };
      };
  };
}
