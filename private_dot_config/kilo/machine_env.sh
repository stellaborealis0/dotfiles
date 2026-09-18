# Kilo Code Machine Environment - Optional per-machine override
# This template loads machine-specific environment variables.
# Values can be overridden in ~/.env.kilo.secrets for each machine.

# === Machine-specific settings ===
export KILO_MACHINE_NAME="{{ .machine_name }}"
export KILO_MACHINE_CLASS="{{ .machine_class }}"
export KILO_MACHINE_ID="{{ .machine_id }}"

# Optional: Override default settings per machine
# export KILO_MAX_PARALLEL_AGENTS={{ .machine_max_agents }}
# export KILO_AUTO_APPROVE_TIMEOUT={{ .machine_timeout }}

# Source machine-specific API keys from the same secrets file
# If you need machine-specific keys, use separate .env files:
#   ~/.env.kilo.secrets.im for IM
#   ~/.env.kilo.secrets.to for TO, etc.
# Then add appropriate logic below:
# if [ -f "$HOME/.env.kilo.secrets.im" ]; then
#     source "$HOME/.env.kilo.secrets.im"
# fi