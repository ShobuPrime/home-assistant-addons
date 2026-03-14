# MuninnDB Add-on for Home Assistant

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Cognitive database with memory primitives — Ebbinghaus decay, Hebbian learning, Bayesian confidence, and semantic triggers as engine-native features.

## About

[MuninnDB](https://muninndb.com) is the world's first cognitive database. Rather than storing rows or documents, it stores engrams — memory traces that score by recency and frequency, learn associations via Hebbian learning, and trigger notifications when they become relevant. It's MCP-native and ships as a single binary with zero external dependencies.

This add-on integrates MuninnDB into Home Assistant, providing persistent cognitive memory storage accessible via REST, gRPC, MBP, and MCP protocols.

## Features

- Ebbinghaus decay — memories naturally fade when unused, stay strong with use
- Hebbian learning — associations automatically strengthen between co-retrieved engrams
- Bayesian confidence — reliability scores update through reinforcement and contradiction
- Semantic triggers — subscribe to context strings with push notifications
- MCP-native — 35 MCP tools for AI tool integration (Claude, Cursor, VS Code, etc.)
- Web dashboard with decay charts, relationship graphs, and activation logs
- Ingress support for seamless sidebar integration
- Persistent data storage included in backups

## Installation

1. Add this repository to your Home Assistant instance
2. Search for "MuninnDB" in the add-on store
3. Click Install
4. Configure the add-on options (embedding providers, memory limits, etc.)
5. Start the add-on
6. Click "OPEN WEB UI" or access via the sidebar

## Configuration

### Option: `log_level`

The `log_level` option controls the level of log output by the addon:

- `trace`: Show every detail
- `debug`: Shows detailed debug information
- `info`: Normal (usually) interesting events (default)
- `warning`: Exceptional occurrences that are not errors
- `error`: Runtime errors
- `fatal`: Critical errors

### SSL / TLS

To enable HTTPS on all MuninnDB ports, set both:
- `ssl_certfile` — Certificate filename in `/ssl/` (e.g., `fullchain.pem`)
- `ssl_keyfile` — Private key filename in `/ssl/` (e.g., `privkey.pem`)

When configured, all ports (REST, Web UI, gRPC, MCP) serve over TLS. Access the Web UI at `https://[your-ip]:8476`.

### Option: `mem_limit_gb`

Memory limit in gigabytes. Set to `0` for no limit (default). Useful for constraining resource usage.

### Option: `local_embed`

Enable or disable the bundled local embedder (ONNX Runtime). Default: `true`. Disable if using an external embedding provider exclusively.

### Embedding and Enrichment Providers

API keys and URLs for embedding and LLM enrichment providers (all optional, alphabetical):

- `anthropic_key` — Anthropic API key for LLM enrichment (used with `enrich_url`)
- `cohere_key` — Cohere embeddings
- `enrich_url` — LLM enrichment endpoint URL (e.g., `anthropic://claude-haiku-4-5-20251001`)
- `google_key` — Google (Gemini) embeddings
- `jina_key` — Jina AI embeddings
- `mistral_key` — Mistral AI embeddings
- `ollama_url` — Ollama service URL for embeddings (e.g., `http://homeassistant.local:11434`)
- `openai_key` — OpenAI API key for embeddings
- `openai_url` — Optional OpenAI-compatible endpoint override (e.g., `http://localhost:8080/v1`)
- `voyage_key` — Voyage AI embeddings

## Folder Access

This addon has access to the following Home Assistant directories:

- `/ssl` - SSL certificates (read-only)
- `/data` - Addon persistent data (read/write)
- `/media` - Home Assistant media folder (read/write)
- `/share` - Home Assistant share folder (read/write)

## First Time Setup

1. Start the add-on
2. Open the Web UI (port 8476) via ingress or directly
3. Log in with default credentials: `root` / `password`
4. **Change the default password immediately**
5. Create vaults for your AI agents or applications
6. Connect your AI tools via the MCP endpoint (port 8750)

## Support

Got questions or found a bug? Please open an issue on the GitHub repository.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

## Version

Currently running MuninnDB 0.4.1-alpha
