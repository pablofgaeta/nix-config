# Lark

Lark uses `nix-darwin` for declarative macOS configuration.

## Local Neovim FIM

Run `qwen-fim-server` before opening Neovim to serve the base Qwen2.5-Coder 14B `Q4_K_M` model through llama.cpp. Use `qwen-fim-server-7b` for the smaller 7B model. The first run downloads the selected model into the Hugging Face cache.

The server uses Metal, an 8912-token context, quantized KV cache, and prompt-cache reuse to fit 16 GB of unified memory. Neovim connects through `llama.vim`:

- `<leader>llf`: request a completion
- `<Tab>`: accept a completion
- `:LlamaToggleAutoFim`: toggle automatic requests

Check readiness and stop the foreground server with `Ctrl-C`:

```bash
curl http://127.0.0.1:8012/health
```
