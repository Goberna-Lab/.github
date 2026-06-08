# Security Policy — Goberna-Lab

Tomamos la seguridad en serio en todos los repos de Goberna-Lab. Esta política aplica org-wide salvo que un repo publique una propia.

## Reportar una vulnerabilidad

**No abras un issue público ni un PR para reportar una vulnerabilidad.** Un issue es visible para cualquiera y expondría el problema antes de que podamos arreglarlo.

En su lugar, reportá de forma privada por **alguno** de estos canales:

1. **GitHub Security Advisories** (preferido): en el repo afectado, pestaña **Security → Report a vulnerability** (si está habilitado el reporte privado).
2. **Email**: **proyecto@grupogoberna.com** con asunto `[SECURITY] <repo> — <resumen corto>`.

Incluí, si podés:

- Repo y versión / commit afectado.
- Tipo de vulnerabilidad y componente.
- Pasos para reproducir (PoC) y el impacto que ves.
- Cualquier mitigación temporal que conozcas.

## Qué esperar

- **Acuse de recibo** dentro de **72 horas hábiles**.
- Evaluación inicial y severidad dentro de **7 días hábiles**.
- Coordinamos con vos una **fecha de divulgación** una vez que haya fix o mitigación disponible. Pedimos divulgación coordinada: no hagas público el detalle hasta que el fix esté desplegado.
- Damos **crédito** a quien reporta, salvo que prefiera permanecer anónimo.

## Alcance

**En alcance:**

- Código y configuración en los repos de la organización Goberna-Lab.
- Vulnerabilidades en nuestros servicios desplegados que deriven de ese código (authn/authz, inyección, exposición de datos, RCE, SSRF, etc.).

**Fuera de alcance:**

- Servicios de terceros y dependencias upstream (reportalas al proyecto correspondiente; avisanos si nos afecta).
- Reportes generados solo por scanners automáticos sin impacto demostrable.
- Ingeniería social, phishing al personal, o ataques físicos.
- Denegación de servicio por fuerza bruta / volumen.

## Manejo de secretos

- **Nunca incluyas secretos reales** (tokens, claves, passwords, dumps de DB, `.env`) en issues, PRs, logs o capturas adjuntas a un reporte. Redactalos.
- Si encontrás un **secreto commiteado** en un repo: tratalo como incidente — avisá de forma privada por los canales de arriba, no abras un issue público, y asumí que el secreto está comprometido (debe rotarse y purgarse del historial).
- Los secretos de CI/CD viven en GitHub Secrets y en los `.env` de los hosts (excluidos del versionado y del rsync de deploy). Reportá cualquier exposición de estos como vulnerabilidad.

## Safe harbor

No iniciaremos acciones legales contra investigación de seguridad de buena fe que: respete esta política, evite violar la privacidad de usuarios, no degrade nuestros servicios, y nos dé tiempo razonable para responder antes de cualquier divulgación. Si tenés dudas sobre si algo está permitido, preguntá primero a proyecto@grupogoberna.com.
