# Contributing — Goberna-Lab (org-wide)

> Esta es la guía **org-wide**. Se propaga por defecto a todos los repos de Goberna-Lab que no tengan su propio `CONTRIBUTING.md`. Un repo puede **sobrescribirla** con uno propio cuando tenga particularidades (ej. el LMS Escuela tiene reglas extra de migraciones y journal).
>
> Donde veas **[por-repo]**, el detalle exacto (rutas, comandos, nombres de paquete, integradores) **lo define cada repo** en su README o en su `CONTRIBUTING.md` propio.

## Quickstart

**¿Recién entrás? Empezá por [`DEVELOPER.md`](./DEVELOPER.md)** — es el tutorial paso a paso (instalar plugins, primera rama, primer PR). Este `CONTRIBUTING.md` es la **referencia** de reglas; `DEVELOPER.md` es el **walkthrough**.

Las **reglas duras** que no se negocian:

- **`main` = PRODUCCIÓN.** Nunca pushees ni commitees directo a `main`. El merge lo decide el integrador y dispara deploy a prod.
- **Bun, no npm/yarn.** Monorepo de workspaces Bun. Comandos: `bun install --frozen-lockfile`, `bun run typecheck`, `bun run test`.
- **Siempre rama + PR.** Branch `feat/…` `fix/…` `chore/…` `docs/…`, Conventional Commits, y se integra **solo vía PR**.
- **Migraciones monótonas + expand-only.** El `when` del journal debe ser monótono vs `origin/main` (si no, el deploy **saltea la migración en silencio**); las migraciones son **aditivas** (solo `ADD` — `DROP`/`RENAME`/`SET NOT NULL`/`ALTER TYPE` van en un deploy posterior).
- **Verificá antes del PR.** `typecheck` + `test` verdes en local antes de decir "listo".
- **PR ≤ 400 líneas reales.** Más grande → partilo en chained PRs.

## `main` = PRODUCCIÓN (en los repos que deployan)

Muchos repos de la org tienen CD: **un merge a `main` deploya a producción**. No asumas que hay staging entre `main` y los usuarios reales.

- **NUNCA pushees directo a `main`.** Se integra **solo vía PR**.
- El **camino de merge** es el comando auditado `goberna-merge-pr` (`REPO=owner/repo`): aborta si los checks no están verdes o el PR no está `APPROVED`, y mergea con `--squash`. Junto con `goberna-branch-state` (read-only; colisiones de shared-core pre-PR) y `goberna-journal-set-when` (arregla el `when` del journal), viene en el plugin **`goberna-agents`** y queda en el PATH tras instalar — no hace falta clonar `platform`.
- **Never auto-push a prod.** La promoción a prod (`workflow_dispatch target=prod`) la autoriza solo quien el repo designe como responsable de release. **[por-repo]**
- Los repos que **no** deployan (librerías, configs, docs) igual usan PRs, pero `main` no implica producción ahí.

## Estado de enforcement (sé honesto)

Estamos en **GitHub plan FREE**. En repos privados de ese plan **no hay branch protection** (la API responde `Upgrade to GitHub Pro/Team`). Distinguimos lo que **una máquina garantiza** de lo que es **una regla de equipo** (best-effort, falsificable):

**ENFORCED hoy (máquina — no se puede saltear sin romper el deploy):**

- **CI en cada PR** (workflow reutilizable de [`platform`](https://github.com/Goberna-Lab/platform)): el job se llama exactamente `ci`. Orden fail-fast.
- **Gate del CD**: antes de deployar verifica vía `gh api` que el SHA tenga el check-run `ci` en verde **y** que el SHA sea ancestro de `origin/main`. **Falla cerrado**: sin `ci` verde, **aborta**.

**NO enforced en plan free (REGLAS DE EQUIPO — best-effort, dependen de disciplina):**

- Branch protection / required reviews / required checks sobre `main`.
- **`CODEOWNERS`** — no aplica como default org-wide: GitHub **no** propaga `CODEOWNERS` desde el repo `.github` a otros repos, y en plan Free **no es enforcing** en repos privados. Si un repo lo quiere, debe agregar su propio `CODEOWNERS` (y aun así será no-op hasta GitHub Team). Por eso **este repo no incluye uno**.
- Que nadie pushee directo a `main`.

> La cura completa de lo social es **GitHub Team**: convierte estas reglas en rulesets enforced. Mientras tanto, lo único garantizado es el **CI del PR** y el **gate del CD**.

## Branching

Trunk-based con feature branches **cortas**.

- `main` siempre deployable. Se integra **solo vía PR**.
- Feature branches: `feat/<modulo>-<detalle-corto>` (ej: `feat/auth-jwt`).
- Fixes: `fix/<descripcion>`. Chore/infra: `chore/<descripcion>`. Refactors: `refactor/<descripcion>`.
- `integration/*` está reservado al integrador y **nunca** va a `main`. **[por-repo]**
- Borrá la rama después de mergear (el script de merge lo hace con `--delete-branch`).
- **PR objetivo ≤ 400 líneas reales** (excluyendo `*.lock` y artefactos generados). Más grande → partilo en chained PRs.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/):

```
feat(cursos): add listing endpoint with pagination
fix(auth): reject expired JWT before hitting DB
chore(ci): cache install step
```

Tipos: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `perf`.

## Antes de abrir un PR — checklist

1. **Rebase** sobre `origin/main`: `git fetch origin && git rebase origin/main` (rebase, no merge — history lineal).
2. **CI verde local** con los comandos del repo (típicamente `typecheck` + `test`, y el `build` si tocaste frontend). **[por-repo]**
3. **Merge auditado:** una vez aprobado, usá `goberna-merge-pr`. **Jamás push directo a `main`.**

## Pull Requests

- **1 reviewer** (otro dev) antes de mergear.
- Completá el **template de PR** (se propaga org-wide desde este repo).
- "Squash and merge" para mantener `main` lineal y limpio.
- Linkeá el issue relacionado si existe (`Closes #N`).
- **CI tiene que pasar** (el gate del CD lo exige igual).

## Repos con base de datos (migraciones)

Si el repo tiene migraciones (ej. Drizzle + Postgres), el orden de cambios de schema y el manejo del journal de migraciones es **crítico y específico del repo**. Seguí el `CONTRIBUTING.md` propio de ese repo. **[por-repo]**

> Regla transversal que sí aplica siempre: cambios de schema → generá la migración, commiteá la carpeta de migraciones **completa** (SQL + snapshots), y no calcules timestamps/secuencias del journal a mano (usá `goberna-journal-set-when`).

## Reglas duras de CI (transversales)

Vienen de bugs reales en CI/prod y aplican a **cualquier** repo que corra sobre los runners self-hosted de la org:

- **PROHIBIDO ejecutar `bun <archivo>.ts` en un step de CI.** El runner sin AVX **segfaultea** (exit 132). Usá siempre binarios: `bun x vitest`, `tsc`, `vite`, o bash+jq.
- **`bun --filter '<pkg>' exec vitest ...` NO funciona** en este Bun (`No packages matched the filter`, exit 1) y bricka el CI. Para tests usá `bun x vitest run <path>`. (El patrón `bun --filter '<pkg>' build` **sí** funciona.)

## Convenciones de código

- **TypeScript estricto** (`strict: true`) en backend y frontend.
- Validación de input **siempre con Zod** antes de tocar la DB.
- Nombres de archivos: `kebab-case.ts` para módulos, `PascalCase.tsx` para componentes React.
- **No commitear `.env`** (gitignored). Agregá variables nuevas a `.env.example` (el deploy excluye `.env` del rsync).

## Secretos

Nunca commitear tokens, claves o passwords. Si descubrís uno en el repo → **avisá al resto, rotá el secreto, y purgalo del historial** si el repo estaba expuesto. Para vulnerabilidades, seguí [`SECURITY.md`](./SECURITY.md) — **no abras un issue público con el detalle**.

## CI/CD y agentes

El CI reutilizable, el workflow de deploy y los agentes/plugins de Claude Code viven centralizados en el repo [**`platform`**](https://github.com/Goberna-Lab/platform). Cada repo consume esos workflows vía `workflow_call` y adopta los plugins vía su `settings.json`. Las herramientas de flujo (`goberna-branch-state`, `goberna-journal-set-when`, `goberna-merge-pr`) se shippean en el plugin **`goberna-agents`** y quedan en el PATH tras instalar — no hay que clonar `platform` para usarlas. Ver el README de `platform` para el contrato exacto.
