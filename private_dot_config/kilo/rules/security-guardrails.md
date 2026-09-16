# Security Guardrails

- NEVER edit or write secrets into `.env`, `*.env`, `kilo.json`, `kilo.jsonc`,
  or any committed file.
- NEVER suggest pasting PATs / API keys / tokens directly into config files.
  Prefer environment variables or a secret manager. If a token is needed,
  reference it via an env var (e.g. `{env:VAR_NAME}`) — do not inline it.
- Do NOT commit secrets. If a file containing secrets is about to be staged,
  stop and warn.
- Treat `.kilo/env.sh`, `~/.kilo/*`, and `/etc/agent-framework/secrets.env` as
  secret stores (perms 0600); never print or echo their contents.
- Prefer read-only operations. For any bash/external command that writes,
  deletes, or touches credentials, ASK before executing (auto-approve is off).
- Before any action involving credentials (API calls, SSH, token use), confirm
  the target and warn the user.
- Do not create new repositories or assume paths that were not given.
