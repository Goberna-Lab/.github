# DEVELOPER — de cero a PR mergeado (Goberna-Lab)

> **EMPEZÁ ACÁ.** Si sos dev nuevo en Goberna-Lab, este es el único arranque que necesitás.
> Te lleva de máquina vacía a tu primer PR mergeado. Concreto, sin vueltas.

`main` = **PRODUCCIÓN**. Un merge a `main` deploya a usuarios reales. Por eso nunca trabajás
directo sobre `main`: rama feature + PR, siempre. El merge lo decide el integrador (Manuel).

---

## 1. Setup (una sola vez por máquina)

Instalá la config de Claude Code de la empresa con una línea. Aplica a **todos** tus repos:

```bash
curl -fsSL https://raw.githubusercontent.com/Goberna-Lab/.github/main/install-claude.sh | bash
```

Para que los plugins se actualicen solos, agregá tu token a `~/.zshrc` / `~/.bashrc`:

```bash
export GH_TOKEN=<tu_token_de_github>
```

Verificá que quedó:

```bash
claude plugin list      # tienen que aparecer goberna-agents, goberna-skills, goberna-hooks
```

### Qué te queda instalado

Tres plugins a nivel usuario:

- **goberna-agents** — `worktree-merge-supervisor` (detecta colisiones de shared-core /
  migraciones / contratos antes del PR) y `release-captain` (orquesta la cola de merges;
  **advisory**, nunca pushea a `main`).
- **goberna-skills** — skills compartidas de la empresa (`goberna-migrate`, `goberna-pr`…).
- **goberna-hooks** — guardrails automáticos. **Solo se activan en repos de Goberna-Lab.**

### Qué hacen los hooks (solos, sin que te acuerdes)

- **Al abrir Claude** (`SessionStart`): te **inyecta las reglas** del equipo (main = prod,
  Bun no npm, journal monótono, AVX, PR ≤400 líneas).
- **Antes de un Bash** (`PreToolUse`): **BLOQUEA** `git push` directo a `main`/`master` y te
  pide confirmar si usás `npm`/`yarn` en lugar de `bun`.
- **Después de editar** (`PostToolUse`): si tocaste `schema.ts` o `drizzle/`, te **recuerda los
  pasos de migración**.

Si actualizaste plugins en una sesión viva: `/reload-plugins`.

### Comandos que te quedan en el PATH

Tras instalar, el plugin **goberna-agents** deja 3 comandos disponibles en cualquier repo (operan sobre el cwd):

- **`goberna-branch-state`** — read-only; detecta colisiones de shared-core entre ramas activas antes de abrir el PR.
- **`goberna-journal-set-when`** — arregla el `when` del último registro del journal Drizzle (lo deja monótono vs `origin/main`).
- **`goberna-merge-pr`** — merge con gates (mergeable + checks verdes + approval); lo usa el integrador, nunca pushea `main` directo.

---

## 2. Empezar una tarea

Cloná el repo, instalá dependencias y **creá tu rama feature** (nunca trabajes en `main`):

```bash
git clone https://github.com/Goberna-Lab/platform.git   # o el repo que toque (ej. escuela)
cd <repo>
bun install --frozen-lockfile
git switch -c feat/cursos-listado                        # feat/... fix/... chore/... docs/...
```

---

## 3. Mientras desarrollás

- **Bun, no npm/yarn.** El stack es un monorepo Bun (workspaces `@goberna/escuela-backend`
  y `@goberna/escuela-frontend`). Si usás npm/yarn el hook te frena para confirmar.
- **Si tocás `backend/src/schema.ts`** (la fuente única del modelo) → usá la skill de migración,
  no lo hagas a mano:

  ```text
  /goberna-skills:goberna-migrate
  ```

  Te corre `bun run db:generate`, te ajusta el `when` del journal (monótono), corre
  `bun run db:migrate` local y deja `backend/drizzle/` listo para commitear. Ver la regla
  **expand-only** en la tabla de abajo.

- **Verificá antes de subir** (tienen que dar verde, es lo mismo que corre el CI):

  ```bash
  bun run typecheck
  bun run test
  ```

---

## 4. Subir los cambios

La forma fácil — la skill arma el commit Conventional, pushea la rama y abre el PR:

```text
/goberna-skills:goberna-pr
```

A mano, si preferís:

```bash
git add -A
git commit -m "feat(cursos): add listing endpoint with pagination"
git push -u origin feat/cursos-listado
gh pr create --fill
```

### Qué pasa después

1. **CI** corre en el runner self-hosted **vps1** (el check aparece como **`ci / ci`**).
   Pasos fail-fast: **journal-guard → typecheck → test → build**.
2. El **integrador revisa y mergea** (squash, borra la rama).
3. El merge a `main` con CI verde **dispara deploy automático a PROD** vía `deploy-reusable@v1`,
   con gates: `pg_dump` pre-migración → `migrate` (expand) → health-gate.

Deploy manual (si hace falta): **Actions → Deploy → Run workflow** con `target = prod|staging`
y `ref = main`.

---

## 5. Lo que NO hay que hacer

| ❌ No hagas esto | ✅ En su lugar | Por qué |
|---|---|---|
| `git push` a `main`/`master` | Rama feature + PR | `main` es prod. El hook lo bloquea igual. |
| `npm install` / `yarn` | `bun install --frozen-lockfile` | El stack es Bun. |
| `bun <archivo>.ts` en un step de CI | `bun x vitest`, `tsc`, `vite` (binarios) | El runner vps1 no tiene AVX → **segfault** (exit 132). |
| Journal con `when` no-monótono | `goberna-migrate` (usa `goberna-journal-set-when`) | Drizzle **saltea la migración en silencio** en prod. |
| `DROP` / `RENAME` / `SET NOT NULL` en el mismo PR que el código que lo usa | Cambio **aditivo** ahora, el destructivo en un deploy **posterior** | El deploy migra **antes** de levantar el código nuevo (expand-only). |

---

## Links

- **[CONTRIBUTING.md](./CONTRIBUTING.md)** — convenciones de equipo (branching, commits, PRs, reglas de CI).
- **[Goberna-Lab/platform](https://github.com/Goberna-Lab/platform)** — CI/CD reutilizable, deploy y agentes.
- **[ONBOARDING.md de platform](https://github.com/Goberna-Lab/platform/blob/main/ONBOARDING.md)** — instalación detallada de Claude Code y los guardrails.
