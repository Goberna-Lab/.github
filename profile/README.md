# Goberna-Lab

**Software, datos y educación digital.** Goberna-Lab es el brazo de ingeniería de Grupo Goberna: construimos y operamos plataformas web, sistemas LMS y herramientas internas para nuestros clientes y para la organización.

## Qué hacemos

- **Plataformas educativas (LMS)** — sistemas de cursos, evaluación y seguimiento de alumnos en producción.
- **Aplicaciones web a medida** — backends de API, paneles de administración y frontends para clientes.
- **Hosting y operación** — infraestructura multi-tenant (WordPress + apps propias) sobre VPS gestionados.
- **Tooling interno** — automatización de CI/CD, agentes y plugins que estandarizan el desarrollo en toda la org.

## Stack principal

| Capa | Tecnologías |
|---|---|
| Backend | Node 22 · TypeScript (ESM) · Express · tRPC |
| Datos | PostgreSQL · Drizzle ORM |
| Frontend | React · Vite · Astro · GrapesJS |
| Runtime / tooling | Bun · Docker · GitHub Actions (self-hosted runners) |
| Infra | VPS (Ubuntu, systemd) · HestiaCP · WordPress multi-tenant |

## Cómo trabajamos

- **Trunk-based** con feature branches cortas y PRs revisados.
- En los repos que deployan, **`main` = producción**: el merge dispara el deploy.
- **CI/CD reutilizable y agentes** centralizados en el repo [`platform`](https://github.com/Goberna-Lab/platform).
- Guías de contribución, seguridad y plantillas de PR propagadas org-wide desde [`.github`](https://github.com/Goberna-Lab/.github).

## Contribuir

Leé la [**guía de contribución**](https://github.com/Goberna-Lab/.github/blob/main/CONTRIBUTING.md) antes de abrir un PR. Para reportar una vulnerabilidad, seguí la [**política de seguridad**](https://github.com/Goberna-Lab/.github/blob/main/SECURITY.md).

## Contacto

- Web: [grupogoberna.com](https://grupogoberna.com)
- Email: proyecto@grupogoberna.com
