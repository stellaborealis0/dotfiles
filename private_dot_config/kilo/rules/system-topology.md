# System Topology (operational truth)

These are the verified facts about this system. Do NOT assume a different
topology. If something contradicts these, verify before acting.

## Nodos principales

- **TO** (`100.68.1.180`, user `eviwork`): control plane 24/7. Hosts the
  Agent Framework (FastAPI + Redis + Postgres 16). UI/dashboard:
  `http://100.68.1.180:8780` (Tailscale only). Health: `/healthz`, and
  `/api/health` (auth required).
- **NVIDIA API** (`https://integrate.api.nvidia.com/v1`): PRIMARY inference
  backend. Default model `nvidia/meta/llama-3.1-70b-instruct` (large) and
  `nvidia/meta/llama-3.1-8b-instruct` (small). Credentials via `NVIDIA_API_KEY`.
- **WS** (`100.68.1.160`): OUT of the critical path for inference. Do not treat
  it as the default model backend. Only use it if explicitly asked.
- **IM** (`gerardo`, this machine): primary human development/operation host.
  Runs Kilo (CLI + extension).
- **MI** (`100.68.1.52`, hostname `MI.local`, user `gerardo`): Mac Mini M4
  (Apple M4, 10 cores, 16 GB RAM, GPU integrada Apple M4, Metal 4). Rol:
  punto de UI y coordinación. OS: macOS 26.5.2. SSH desde IM/MB con clave
  pública. Ejecuta VSC, Zoo Code y otras herramientas de desarrollo.
- **MB** (`stellaborealis`): lightweight Tailscale console client only.
- **IV** / **EV**: OFFLINE / outside the tailnet. Treat as UNAVAILABLE; never
  assume they are reachable or use them.

## Proveedores y servicios

- **LiteLLM on TO**: degraded/unreliable. Do NOT use it as a proxy until its
  health is explicitly verified.
- **Google MCP**: not operational (only placeholders). Do NOT enable or use it.
- **ClawRouter / other TO services** on ports 8000/8080 are separate concerns;
  the Agent Framework uses 8700/8780.

## Notas operativas

- MI e IM son máquinas separadas. MI no es un alias de IM.
- MI tiene IPs LAN (`192.168.1.169`, `192.168.1.170`) y Tailscale (`100.68.1.52`, `100.111.44.35`).
- MB no puede ejecutar Kilo localmente por limitación de CPU (Intel Core2 Duo).
- Para ejecutar herramientas en MB desde MI, usar SSH.

When in doubt about topology, check the TO dashboard health or ask — do not guess.
