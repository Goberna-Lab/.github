#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Bootstrap de Claude Code para devs de Goberna-Lab.
#
# Instala, a nivel USUARIO (aplica a TODOS tus repos), el marketplace de la
# empresa y sus plugins: agentes + skills + hooks de buenas practicas.
#
# Uso (una linea):
#   curl -fsSL https://raw.githubusercontent.com/Goberna-Lab/.github/main/install-claude.sh | bash
#
# Requisitos:
#   - Claude Code instalado (el CLI 'claude' en el PATH).
#   - Acceso git/gh a la org (sos miembro de Goberna-Lab). El marketplace vive en
#     el repo privado Goberna-Lab/platform; se baja con tus credenciales de git.
# ----------------------------------------------------------------------------
set -euo pipefail

MARKET_REPO="Goberna-Lab/platform"   # repo que hostea el marketplace
MARKET_NAME="goberna-tools"          # 'name' dentro de .claude-plugin/marketplace.json
PLUGINS="goberna-agents goberna-skills goberna-hooks"

command -v claude >/dev/null 2>&1 || {
  echo "ERROR: no encuentro el CLI 'claude'. Instala Claude Code primero: https://claude.com/claude-code" >&2
  exit 1
}

echo "==> Agregando el marketplace privado $MARKET_REPO ..."
claude plugin marketplace add "$MARKET_REPO"

for p in $PLUGINS; do
  echo "==> Instalando $p@$MARKET_NAME (scope user) ..."
  claude plugin install "$p@$MARKET_NAME"
done

cat <<'EOF'

OK. Listo. Los 3 plugins quedaron instalados a nivel usuario (aplican a TODOS tus repos):
  - goberna-agents : worktree-merge-supervisor + release-captain
  - goberna-skills : skills compartidas de la empresa
  - goberna-hooks  : guardrails automaticos (solo se activan en repos de Goberna-Lab)

Auto-update del marketplace privado (recomendado): agrega a tu ~/.zshrc o ~/.bashrc:
  export GH_TOKEN=<tu_token_de_github>

Verifica:           claude plugin list
En una sesion viva: /reload-plugins
EOF
