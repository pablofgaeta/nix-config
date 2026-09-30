{...}: {
  den.aspects.llama.homeManager = {
    lib,
    pkgs,
    ...
  }: let
    isLinux = pkgs.stdenv.hostPlatform.isLinux;

    llamaCpp =
      if isLinux
      then pkgs.llama-cpp-rocm
      else pkgs.llama-cpp;

    llamaSwapConfig = (pkgs.formats.yaml {}).generate "llama-swap-config.yaml" {
      healthCheckTimeout = 600;
      globalTTL = 600;
      unloadTimeout = 15;
      logLevel = "info";
      logToStdout = "both";
      sendLoadingState = true;
      includeAliasesInList = true;

      hooks = {
        on_startup = {
          preload = ["qwen-fast"];
        };
      };

      models =
        {
          "qwen-fast" = {
            name = "Qwen3 8B Q8_0";
            aliases = [
              "default"
              "chat"
              "gpt-4o-mini"
              "qwen3-8b"
              "qwen3-8b-q8"
            ];
            ttl = 600;
            cmd = lib.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "--hf-repo Qwen/Qwen3-8B-GGUF"
              "--hf-file Qwen3-8B-Q8_0.gguf"
              "--alias qwen3-8b-q8"
              "--host 127.0.0.1"
              "--port \${PORT}"
              "--n-gpu-layers all"
              "--flash-attn on"
              "--ctx-size 16384"
              "--cache-type-k q8_0"
              "--cache-type-v q8_0"
              "--batch-size 1024"
              "--ubatch-size 512"
              "--parallel 1"
            ];
          };

          "qwen-coder" = {
            name = "Qwen3 14B Q4_K_M";
            aliases = [
              "coder"
              "code"
              "qwen3-14b"
              "qwen3-14b-q4"
            ];
            ttl = 600;
            cmd = lib.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "--hf-repo Qwen/Qwen3-14B-GGUF"
              "--hf-file Qwen3-14B-Q4_K_M.gguf"
              "--alias qwen3-14b-q4"
              "--host 127.0.0.1"
              "--port \${PORT}"
              "--n-gpu-layers all"
              "--flash-attn on"
              "--ctx-size 8192"
              "--cache-type-k q8_0"
              "--cache-type-v q8_0"
              "--batch-size 1024"
              "--ubatch-size 512"
              "--parallel 1"
            ];
          };

          "qwen-fim" = {
            name = "Qwen 2.5 Coder 14B FIM";
            aliases = [
              "qwen2.5-coder-14b-fim"
              "fim"
            ];
            ttl = 600;
            cmd = lib.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "--hf-repo bartowski/Qwen2.5-Coder-14B-GGUF"
              "--hf-file Qwen2.5-Coder-14B-Q4_K_M.gguf"
              "--alias qwen2.5-coder-14b-fim"
              "--host 127.0.0.1"
              "--port \${PORT}"
              "--n-gpu-layers all"
              "--flash-attn on"
              "--ctx-size 8912"
              "--cache-type-k q8_0"
              "--cache-type-v q8_0"
              "--batch-size 1024"
              "--ubatch-size 512"
              "--parallel 1"
              "--cache-reuse 256"
              "--cache-ram 0"
            ];
          };

          "qwen-fim-7b" = {
            name = "Qwen 2.5 Coder 7B FIM";
            aliases = [
              "qwen2.5-coder-7b-fim"
              "fim-7b"
            ];
            ttl = 600;
            cmd = lib.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "--hf-repo QuantFactory/Qwen2.5-Coder-7B-GGUF"
              "--hf-file Qwen2.5-Coder-7B.Q4_K_M.gguf"
              "--alias qwen2.5-coder-7b-fim"
              "--host 127.0.0.1"
              "--port \${PORT}"
              "--n-gpu-layers all"
              "--flash-attn on"
              "--ctx-size 8912"
              "--cache-type-k q8_0"
              "--cache-type-v q8_0"
              "--batch-size 1024"
              "--ubatch-size 512"
              "--parallel 1"
              "--cache-reuse 256"
              "--cache-ram 0"
            ];
          };
        }
        // lib.optionalAttrs isLinux {
          "qwen-large" = {
            name = "Qwen3.8 27B Q4_K_M";
            aliases = [
              "large"
              "qwen3.8-27b"
              "qwen3.8-27b-q4"
            ];
            ttl = 600;
            cmd = lib.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "--hf-repo ggml-org/Qwen3.8-27B-GGUF"
              "--hf-file Qwen3.8-27B-Q4_K_M.gguf"
              "--alias qwen3.8-27b-q4"
              "--host 127.0.0.1"
              "--port \${PORT}"
              "--n-gpu-layers 55"
              "--flash-attn on"
              "--ctx-size 4096"
              "--cache-type-k q8_0"
              "--cache-type-v q8_0"
              "--batch-size 512"
              "--ubatch-size 256"
              "--parallel 1"
            ];
          };
        };
    };

    llamaSwapServer = pkgs.writeShellApplication {
      name = "llama-swap-server";
      runtimeInputs = [pkgs.llama-swap];
      text = ''
        exec llama-swap \
          -config "${llamaSwapConfig}" \
          -listen 127.0.0.1:8012 \
          "$@"
      '';
    };

    mkQwenFimServer = {
      name,
      repo,
      alias,
    }:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [llamaCpp];
        text = ''
          exec llama-server \
            --hf-repo ${repo}:Q4_K_M \
            --alias ${alias} \
            --host 127.0.0.1 \
            --port 8012 \
            --n-gpu-layers all \
            --flash-attn on \
            --ctx-size 8912 \
            --cache-type-k q8_0 \
            --cache-type-v q8_0 \
            --batch-size 1024 \
            --ubatch-size 512 \
            --parallel 1 \
            --cache-reuse 256 \
            --cache-ram 0 \
            --no-webui \
            "$@"
        '';
      };

    mkQwenChatServer = {
      name,
      repo,
      file,
      alias,
      ctxSize,
    }:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [llamaCpp];
        text = ''
          exec llama-server \
            --hf-repo ${repo} \
            --hf-file ${file} \
            --alias ${alias} \
            --host 127.0.0.1 \
            --port 8012 \
            --n-gpu-layers all \
            --flash-attn on \
            --ctx-size ${toString ctxSize} \
            --cache-type-k q8_0 \
            --cache-type-v q8_0 \
            --batch-size 1024 \
            --ubatch-size 512 \
            --parallel 1 \
            "$@"
        '';
      };

    qwenFimServer = mkQwenFimServer {
      name = "qwen-fim-server";
      repo = "bartowski/Qwen2.5-Coder-14B-GGUF";
      alias = "qwen2.5-coder-14b-fim";
    };

    qwenFimServer7b = mkQwenFimServer {
      name = "qwen-fim-server-7b";
      repo = "QuantFactory/Qwen2.5-Coder-7B-GGUF";
      alias = "qwen2.5-coder-7b-fim";
    };

    qwenCoderServer = mkQwenChatServer {
      name = "qwen-coder-server";
      repo = "Qwen/Qwen3-14B-GGUF";
      file = "Qwen3-14B-Q4_K_M.gguf";
      alias = "qwen3-14b-q4";
      ctxSize = 8192;
    };

    qwenFastServer = mkQwenChatServer {
      name = "qwen-fast-server";
      repo = "Qwen/Qwen3-8B-GGUF";
      file = "Qwen3-8B-Q8_0.gguf";
      alias = "qwen3-8b-q8";
      ctxSize = 16384;
    };

    qwenLargeServer = pkgs.writeShellApplication {
      name = "qwen-large-server";
      runtimeInputs = [llamaCpp];
      text = ''
        exec llama-server \
          --hf-repo ggml-org/Qwen3.8-27B-GGUF \
          --hf-file Qwen3.8-27B-Q4_K_M.gguf \
          --alias qwen3.8-27b-q4 \
          --host 127.0.0.1 \
          --port 8012 \
          --n-gpu-layers 55 \
          --flash-attn on \
          --ctx-size 4096 \
          --cache-type-k q8_0 \
          --cache-type-v q8_0 \
          --batch-size 512 \
          --ubatch-size 256 \
          --parallel 1 \
          "$@"
      '';
    };
  in {
    home.file.".pi/agent/models.json".source = (pkgs.formats.json {}).generate "pi-llama-swap-models.json" {
      providers.llama-swap = {
        baseUrl = "http://127.0.0.1:8012/v1";
        api = "openai-completions";
        apiKey = "local";
        compat = {
          supportsDeveloperRole = false;
          supportsReasoningEffort = false;
        };
        models =
          [
            {
              id = "qwen-fast";
              name = "Qwen3 8B (Hazel)";
              reasoning = false;
              contextWindow = 16384;
              maxTokens = 4096;
            }
            {
              id = "qwen-coder";
              name = "Qwen3 14B Coder (Hazel)";
              reasoning = false;
              contextWindow = 8192;
              maxTokens = 4096;
            }
          ]
          ++ lib.optionals isLinux [
            {
              id = "qwen-large";
              name = "Qwen3.8 27B (Hazel)";
              reasoning = true;
              contextWindow = 4096;
              maxTokens = 2048;
            }
          ];
      };
    };

    home.packages =
      [
        llamaSwapServer
        qwenFimServer
        qwenFimServer7b
        qwenCoderServer
        qwenFastServer
      ]
      ++ lib.optionals isLinux [
        qwenLargeServer
      ];

    systemd.user.services.llama-swap = lib.mkIf isLinux {
      Unit = {
        Description = "llama-swap model server";
        After = ["network.target"];
      };
      Service = {
        ExecStart = ["${lib.getExe llamaSwapServer}"];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
