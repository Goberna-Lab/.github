# Usando Claude con el sistema Goberna-Lab — playbook de prompts

> **Para el dev.** Esto asume que ya corriste el instalador (ver **[DEVELOPER.md](./DEVELOPER.md)**).
> Acá no se explica *qué* se instala, sino **cómo le hablás a Claude** para que use nuestro
> sistema: qué prompts escribir según la tarea, con un ejemplo de sesión completa al final.

---

## La idea en 30 segundos

Cuando abrís un repo de Goberna en Claude Code, **ya tenés cargado** (sin hacer nada):

- las **reglas del equipo** (`CLAUDE.md`) y el **perfil del repo** (`.claude/project-profile.md`),
- los **agentes** (`worktree-merge-supervisor`, `release-captain` + 13 especialistas),
- las **skills** (`goberna-pr`, `goberna-migrate`, `goberna-design-system`, `judgment-day`…),
- los **hooks** (te frenan si vas a romper una regla) y los **comandos** (`goberna-branch-state`…).

**No tenés que memorizar comandos.** Le decís a Claude qué querés en lenguaje natural y él elige
la herramienta. Vos te concentrás en el qué; el sistema te cubre el cómo y los guardrails.

---

## Arrancá tu sesión (en tu rama)

```bash
git switch main && git pull
git switch -c feat/lo-tuyo      # feat/  fix/  chore/  docs/  refactor/
claude                          # abrí Claude Code en el repo
```

**Primer prompt sugerido** (encuadrá la tarea antes de tocar código):

```text
Estoy en la rama feat/lo-tuyo y voy a <objetivo concreto>.
Leé el CLAUDE.md y el .claude/project-profile.md de este repo y proponé un plan
corto antes de escribir código. Si toca shared-core o migraciones, avisámelo.
```

---

## Playbook de prompts (qué escribir según la tarea)

### 🧭 Antes de abrir el PR — chequeo de colisiones (el supervisor)
```text
Antes de abrir el PR: corré `goberna-branch-state` y pasale la salida al
worktree-merge-supervisor. Quiero el veredicto SAFE / REVIEW / BLOCK sobre mi rama.
```
Detecta si tu rama pisa **shared-core** (schema, journal, router central, shell, CSS global)
con otra rama activa. Es **ayuda, no gate** — el gate real es el CI.

### 🗄️ Tocar el modelo de datos / una migración
```text
Necesito agregar <tabla/campo> al schema. Seguí el patrón del repo: modelá la tabla,
generá la migración y dejá el journal monótono. Que sea expand-only (nada destructivo).
```
Usa la skill **`goberna-migrate`** (`db:generate` → fija el `when` con `goberna-journal-set-when`
→ `db:migrate`). El journal desordenado hace que Drizzle **saltee la migración en silencio** en prod.

### 🚀 Abrir el PR
```text
Subí esto: armá el commit Conventional, pusheá la rama y abrí el PR con el checklist.
```
Usa la skill **`goberna-pr`**. (También podés invocarla directo: `/goberna-skills:goberna-pr`.)

### 🧠 Dispatch a un especialista (tarea profunda en un dominio)
```text
dispatch a postgres-pro: esta query de enrollments hace N+1, optimizala.
```
```text
que el security-auditor revise el endpoint de checkout antes del PR.
```
```text
pedile a typescript-pro que tipee bien este genérico end-to-end.
```
Hay 13: `postgres-pro`, `database-optimizer`, `backend-developer`, `api-designer`,
`typescript-pro`, `node-specialist`, `docker-expert`, `devops-engineer`, `network-engineer`,
`mcp-developer`, `code-reviewer`, `security-auditor`, `wordpress-master`.

### 🎨 UI / diseño
```text
Seguí la skill goberna-design-system para este componente: usá los tokens y patrones del equipo.
```

### 🔎 Review adversarial antes de mergear algo sensible
```text
Corré judgment-day sobre este diff: review adversarial + check de seguridad.
```

### ✂️ PR grande (>400 líneas) → partirlo
```text
Este cambio va a pasar las ~400 líneas. Proponé cómo partirlo en PRs encadenados (chained-pr),
con el orden de merge y qué depende de qué.
```

---

## Lo que el sistema te va a hacer respetar (hooks, solos)

- **`main` = producción** → nunca `git push` directo. El hook lo **bloquea**.
- **Bun, no npm/yarn** (en repos Bun) → el hook te pide confirmar.
- **Journal monótono / expand-only** → si tocás `schema.ts`/`drizzle/`, te recuerda los pasos.

Si Claude propone algo que rompe una regla, **frenálo** — o dejá que el hook lo haga.

---

## Ejemplo de sesión completa (de rama a PR)

Así se ve, de principio a fin, integrar un cambio usando el sistema:

```text
Vos:   Estoy en feat/cursos-export y voy a agregar un endpoint para exportar
       las notas de un curso a CSV. Leé el CLAUDE.md y el project-profile y proponé
       un plan antes de codear.

Claude: [lee contexto] Plan: 1) interface/grades-export.ts (Zod input) →
        2) controller con la query Drizzle → 3) router → registrar en routers/index.ts.
        No toca schema → sin migración. ¿Avanzo?

Vos:   dale.

Claude: [implementa las 3 capas]

Vos:   verificá: typecheck + test.

Claude: [corre `bun run typecheck` y `bun run test`] Verde.

Vos:   Antes del PR corré goberna-branch-state y pasáselo al worktree-merge-supervisor.

Claude: [corre el comando + analiza] Veredicto: SAFE. Tu rama solo toca el módulo grades
        y routers/index.ts (append-only, sin colisión con otras ramas activas).

Vos:   abrí el PR.

Claude: [skill goberna-pr] Commit `feat(grades): add CSV export endpoint`, rama pusheada,
        PR #57 abierto con checklist. El CI ya está corriendo.
```

Después: el **integrador** (Manuel) revisa, mergea por el camino auditado (`goberna-merge-pr`),
y el merge a `main` con CI verde **deploya a prod** automáticamente.

---

## Si algo no carga

```bash
claude plugin list        # tienen que estar los 4: goberna-agents/specialists/skills/hooks
```
En una sesión viva, tras actualizar plugins: `/reload-plugins`.
¿Dudas del flujo (branching, CI, reglas)? → **[DEVELOPER.md](./DEVELOPER.md)** y **[CONTRIBUTING.md](./CONTRIBUTING.md)**.
