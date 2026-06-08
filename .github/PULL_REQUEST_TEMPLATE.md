## Qué cambia

<!-- Descripción breve en 1-3 bullets -->

## Por qué

<!-- Motivación / issue relacionado -->

Closes #

## Flags

<!-- Marcá con [x] lo que corresponda. Si tu repo no aplica alguno, dejalo en "no". -->

- migration: yes / no  <!-- ¿Toca el schema o las migraciones de la DB? -->
- contract-change: yes / no  <!-- ¿Cambia una interfaz/API de forma NO aditiva (renombrar/borrar)? Si sí, migrá los consumidores en este mismo PR. -->
- deploys-to-prod: yes / no  <!-- ¿Este repo deploya a prod al mergear a main? -->

## Cómo lo probé

- [ ] `typecheck` pasa
- [ ] `test` pasa
- [ ] `build` pasa (si toqué frontend)
- [ ] Si `migration: yes` → migración generada, carpeta de migraciones commiteada completa y journal fijado por el script del repo (NO a mano)
- [ ] Probado localmente (describir)

## Checklist

- [ ] Rebaseado sobre `origin/main` (rebase, no merge)
- [ ] Branch name + Conventional Commits según la convención (`feat/`, `fix/`, `chore/`, `refactor/`)
- [ ] PR ≤ 400 líneas reales (o partido en chained PRs)
- [ ] Si agrega env var → `.env.example` actualizado (el deploy excluye `.env` del rsync)
- [ ] Sin secretos en el diff

---

> Recordatorio: en los repos que deployan, **no pushees a `main`** (es producción). El merge se hace con el script auditado del repo (`scripts/merge-pr.sh <PR#>` donde exista). La promoción a prod la autoriza el responsable de release del repo. Ver [CONTRIBUTING.md](../CONTRIBUTING.md).
