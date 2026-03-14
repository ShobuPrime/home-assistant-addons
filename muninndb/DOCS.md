# MuninnDB Documentation

## Overview

MuninnDB is a cognitive database that stores engrams — memory traces with built-in decay, association learning, and confidence scoring. This add-on runs MuninnDB as a Home Assistant service, providing persistent cognitive memory accessible via multiple protocols.

## Configuration

### Option: `log_level`

The `log_level` option controls the level of log output by the addon:
- `trace`: Show every detail
- `debug`: Shows detailed debug information
- `info`: Normal (usually) interesting events (default)
- `warning`: Exceptional occurrences that are not errors
- `error`: Runtime errors
- `fatal`: Critical errors

### Option: `local_embed`

Controls the bundled ONNX Runtime embedder. When enabled (default), MuninnDB can generate embeddings locally without external API calls. Disable if you exclusively use an external provider.

### Option: `ollama_url`

URL for an Ollama instance (e.g., `http://homeassistant.local:11434`). When configured, MuninnDB uses Ollama for embedding generation. This is useful if you already run Ollama on your network.

### Option: `openai_key`

OpenAI API key for cloud-based embeddings. Stored as a password field.

### Option: `mem_limit_gb`

Constrains MuninnDB's memory usage. Set to `0` (default) for unlimited. Useful on resource-constrained systems.

### Embedding Provider Keys

- `voyage_key` — Voyage AI embeddings
- `cohere_key` — Cohere embeddings
- `gemini_key` — Google Gemini embeddings
- `jina_key` — Jina AI embeddings
- `mistral_key` — Mistral AI embeddings

## Access Methods

1. **Via Sidebar**: Click the brain icon in Home Assistant (uses ingress)
2. **Direct HTTP**: `http://[your-ip]:8476`
3. **REST API**: `http://[your-ip]:8475`
4. **gRPC**: `[your-ip]:8477`
5. **MBP Protocol**: `[your-ip]:8474` (lowest latency, for production agents)
6. **MCP**: `[your-ip]:8750` (for AI tool integration)

## Port Information

| Port | Protocol | Use Case |
|------|----------|----------|
| 8474 | MBP | Production agents — lowest latency (<10ms ACK) |
| 8475 | REST | HTTP/JSON — testing, integration, health checks |
| 8476 | Web UI | Dashboard with decay charts and relationship graphs |
| 8477 | gRPC | Polyglot team support |
| 8750 | MCP | AI tool integration (Claude, Cursor, VS Code, etc.) |

## Data Persistence

All data is stored in `/data/muninndb` and included in Home Assistant backups.

MuninnDB stores:
- Engram data (memory traces with concepts, content, confidence, and relevance scores)
- Vault definitions and configurations
- Association weights (Hebbian learning state)
- Trigger subscriptions

## Core Concepts

### Engrams

The fundamental storage unit. Each engram contains:
- **Concept**: The topic or category
- **Content**: The actual memory data
- **Confidence**: Bayesian posterior (0.0–1.0) tracking reliability
- **Relevance**: Temporal priority score computed at query time

### Vaults

Namespaces for engrams. Typically one vault per AI agent or user. Use vaults to isolate memory contexts.

### ACTIVATE

The primary query mechanism. Accepts a context string and returns the N most cognitively relevant engrams, ranked by a combination of recency, frequency, confidence, and semantic similarity.

## First Time Setup

1. Start the add-on and open the Web UI
2. Log in with default credentials: `root` / `password`
3. **Change the default password immediately** via the dashboard
4. Create a vault for your use case
5. Connect AI tools via the MCP endpoint at port 8750
6. Optionally configure an embedding provider for semantic search

## Security Considerations

- **Default Credentials**: The default login is `root`/`password` — change this immediately
- **AppArmor**: Custom profile restricts addon permissions appropriately
- **API Keys**: Embedding provider keys are stored as password fields and not displayed in the UI
- **Network Access**: All ports are exposed on the host — consider firewall rules if needed

## Troubleshooting

### MuninnDB Not Starting

**Symptoms:**
- Add-on fails to start
- Logs show binary not found or permission errors

**Solution:**
1. Check addon logs for specific error messages
2. Verify architecture compatibility (amd64/aarch64 only)
3. Try reinstalling the addon

### Web UI Not Accessible

**Symptoms:**
- Cannot reach port 8476
- Ingress shows blank page

**Solution:**
1. Check that the addon is running (green status)
2. Try direct access via `http://[your-ip]:8476`
3. Check addon logs for binding errors

### Memory Usage High

**Symptoms:**
- System running slow
- MuninnDB consuming excessive RAM

**Solution:**
1. Set `mem_limit_gb` to constrain memory usage
2. Disable `local_embed` if not using local embeddings
3. Monitor engram count and prune unused vaults

## Updating

The addon automatically tracks releases. Updates appear in the Home Assistant UI when available.

## External Resources

- [MuninnDB Documentation](https://muninndb.com/docs)
- [MuninnDB GitHub](https://github.com/scrypster/muninndb)
- [MuninnDB Getting Started](https://muninndb.com/getting-started)
