# Guía del integrador — Goberna-Lab

Para quien revisa y **mergea PRs a `main`** (= producción) y coordina los deploys.
Si sos dev y solo querés subir cambios, mirá **[DEVELOPER.md](./DEVELOPER.md)**.

---

## 1. Instalar (1 sola vez, ~2 min)

**Requisito:** Claude Code instalado (el comando `claude` en la terminal).

```bash
# Token de GitHub para auto-update del marketplace privado (pegar en ~/.zshrc o ~/.bashrc):
export GH_TOKEN=<tu_token_de_github>

# Instalar agentes + skills + hooks de Goberna-Lab (una línea):
curl -fsSL https://raw.githubusercontent.com/Goberna-Lab/.github/main/install-claude.sh | bash

# Verificar:
claude plugin list
```

Queda todo a nivel usuario (aplica a **todos** tus repos). Al abrir Claude en un repo de la org:
te **inyecta las reglas**, **bloquea** `git push` a `main`, y te **recuerda** las migraciones.

Además te quedan en el **PATH** estos comandos (en cualquier repo):

| Comando | Qué hace |
|---|---|
| `goberna-branch-state` | Read-only. Colisiones de shared-core entre ramas antes de mergear. |
| `goberna-journal-set-when` | Arregla el `when` del journal de Drizzle (monótono vs `main`). |
| `goberna-merge-pr <PR#>` | **Único camino de merge** (valida mergeable + checks verdes + approval, squash). Nunca pushea `main` directo. |

---

## 2. Primer paso por repo — adoptar la plataforma

La primera vez, cada repo reemplaza su CI/deploy inline por los **reusables** de `platform`.
En **escuela** ya está listo en el **PR #39** (CI verde):
👉 https://github.com/Goberna-Lab/goberna-escuela/pull/39

```bash
gh pr merge 39 --repo Goberna-Lab/goberna-escuela --squash --delete-branch   # o: goberna-merge-pr 39
gh pr close 38 --repo Goberna-Lab/goberna-escuela                            # #38 quedó superseded
```

Al mergear: corre CI sobre `main` → si verde → **deploy automático a PROD con gates**
(backup `pg_dump` + migrate expand + health-gate). Verificá en **Actions** que se encadene
`CI → Deploy`. Si Deploy no arranca solo la 1ra vez: **Actions → Deploy → Run workflow → `target=prod`** (rama `main`).

---

## 3. Día a día

| Acción | Cómo |
|---|---|
| Revisar un PR | El check **`ci / ci`** tiene que estar verde. |
| Ver colisiones / orden de merge | `goberna-branch-state`, o pedile a Claude el agente **`release-captain`**. |
| **Mergear a `main`** (= prod) | `goberna-merge-pr <PR#>` (o la UI). Nunca `git push origin main`. |
| Deploy manual | Actions → **Deploy** → Run workflow → `target` prod/staging (rama `main`). |

**Recuperación si un deploy falla el health-gate:** el backend se **detiene** (no sirve roto).
Re-deployás el último SHA verde: Actions → Deploy → Run workflow → `target=prod`. Si la
migración tocó datos: `pg_restore` del dump en `/srv/backups/prod-<ts>.dump`.

**Regla que hacés cumplir:** las migraciones son **expand-only** (solo `ADD`). Los
`DROP`/`RENAME`/`SET NOT NULL` van en un PR/deploy **posterior** (porque el deploy migra
*antes* de levantar el código nuevo).

---

## 4. Onboardear al equipo

Pasales una línea y el link a la guía:

```bash
curl -fsSL https://raw.githubusercontent.com/Goberna-Lab/.github/main/install-claude.sh | bash
```
📖 [DEVELOPER.md](./DEVELOPER.md) — su "de cero a PR mergeado".

El loop de ellos: instalan → raman → programan (`/goberna-skills:goberna-migrate` si tocan
schema) → **`/goberna-skills:goberna-pr`** los lleva al PR verde → vos revisás y mergeás.
Los hooks los frenan si se equivocan (push a main, npm en vez de bun, migración fuera de orden).
