# CLAUDE.md · Convenciones del repo taller-sdd-favoritos

Este archivo es leído por agentes AI (Claude Code, Cursor, Copilot) cuando trabajan en este repo.

**V3 del way of work** · archivo obligatorio antes de generar código en cualquier iniciativa.

---

## Qué es este repo

Workspace compartido del **Taller 2 SDD** · relay de 8 parejas recorriendo el pipeline end-to-end con el ejemplo ficticio *"favoritos de skills"*.

**Proyecto greenfield** · no hay código previo · no hay usuarios reales · es un ejercicio de aprendizaje.

---

## Estructura · qué va dónde

```
docs/
├── 00-discovery/     · Pareja 1 · discovery.md (6 preguntas YC)
├── 01-prd/           · Pareja 2 · prd.md (QUÉ + POR QUÉ)
├── 02-rfc/           · Pareja 3 · rfc.md (CÓMO · técnico)
├── 04-adrs/          · Pareja 4 · ADR-001 a ADR-N (1 decisión por ADR)
├── 03-contracts/     · Pareja 5 · api-contract.md · data-model.md · events.md
├── 05-stories/       · Pareja 6 · stories.md (historias INVEST)
├── 06-plans/         · Pareja 7a · plan-H<N>.md (vertical slice por historia)
├── 07-dag/           · Pareja 7b · dag.md + tasks.json (DAG + Agents Kanban JSON)
└── 08-reviews/       · Pareja 8 · review.md (validación contra specs)

src/                  · código (si alcanzamos a esa fase · próxima sesión)
```

---

## Stack sugerido (lo define Pareja 3 en el RFC · acá son defaults razonables)

- **Backend** · Node 20+ · Express · TypeScript
- **Base de datos** · SQLite (local, sin infra)
- **Frontend** · vanilla TS + Tailwind (si aplica)
- **Auth** · header simple `x-user: <nombre>` (sin login real, ejercicio)
- **Testing** · vitest
- **CI** · ninguno (ejercicio · sin deploy)

Estos defaults **se pueden cambiar** · los define la Pareja 3 en el RFC.

---

## Convenciones de estilo

### Markdown (artefactos del pipeline)

- H1/H2/H3 · nada de H4+
- Tablas para comparaciones > 3 items
- Code blocks con language hint (```bash · ```yaml · ```typescript)
- Separadores `---` entre secciones largas
- Tono castellano · directo · sin consultor-speak
- Cita relevante · `**key**` en negrita · evitar emojis decorativos

### Artefactos específicos

**ADR (formato Nygard)**
```markdown
# ADR-<NNN> · <título imperativo · ≤10 palabras>

**Status:** Proposed | Accepted | Superseded by ADR-XXX
**Date:** YYYY-MM-DD
**Deciders:** [lista]

## Contexto
## Decisión considerada (2-3 opciones)
## Decisión tomada
## Consecuencias (positivas + negativas)
## Requiere PoC (☐ Sí / ☐ No · criterio de éxito)
## Referencias
```

**Plan-H<N>.md (vertical slice)**
- Cada subtask declara `consume` + `produce` con namespaces (`schema.*` · `endpoint.*` · `file.*` etc.)
- Archivos concretos a tocar
- Validación medible por subtask
- Rol: DB | BE | FE | Tests

**Historia INVEST**
- Formato · *"Como [rol] quiero [acción] para [beneficio]"*
- Criterios aceptación en bullets
- Cumple los 6 criterios INVEST

---

## Reglas del way of work (no negociables)

- **V1** · PRD técnico nunca reduce alcance del PRD de negocio
- **V2** · validar cada paso contra PRD hasta el RFC
- **V3** · este archivo (CLAUDE.md) obligatorio antes de codear · ✓ cumplido
- **V4** · si el RFC tiene >5 decisiones arquitectónicas · partirlo en ADRs (Pareja 4 lo hace)
- **V5** · plan micro (`/story-to-plan`) antes del DAG macro (`/task-dependency-analyzer`)

---

## Pipeline SDD · skills a usar en orden

| Fase | Skill | Lee | Escribe |
|---|---|---|---|
| 1 | `/office-hours` | idea cruda | `docs/00-discovery/discovery.md` |
| 2 | `/create-prd` | discovery | `docs/01-prd/prd.md` |
| 3 | `/rfc-builder` | PRD | `docs/02-rfc/rfc.md` |
| 4 | `/rfc-to-adr` | RFC | `docs/04-adrs/ADR-*.md` |
| 5 | `/contract-define` | PRD + RFC + ADRs | `docs/03-contracts/*` |
| 6 | `/user-story-builder` | contrato + PRD | `docs/05-stories/stories.md` |
| 7a | `/story-to-plan` | 1 historia + ADRs + contrato + este CLAUDE.md | `docs/06-plans/plan-H<N>.md` |
| 7b | `/task-dependency-analyzer` | N plan-Hi.md | `docs/07-dag/dag.md` + `tasks.json` |
| 8 | [código] | plan + DAG + contrato + CLAUDE.md | `src/` + commits + PR |
| 9 | `/code-review` | PR + specs | `docs/08-reviews/review-PR<N>.md` |

---

## Flujo de git

- **Branch** · cada pareja trabaja en `main` directo (ejercicio corto · evitamos fricción de PRs)
- **Commits** · mensaje con prefijo de fase: `discovery: ...` · `prd: ...` · `rfc: ...` · `code: ...`
- **Pull antes de push** · `git pull --rebase` si otra pareja pusheó en el medio
- **Si hay conflicto** · Alejo ayuda a resolver

---

## Artefactos con `consume` / `produce` declarativo (Pareja 7a · plan-H<N>.md)

Cada subtask del plan debe declarar al menos 1 `consume` y 1 `produce` con estos namespaces:

| Namespace | Qué referencia |
|---|---|
| `schema.*` | Tablas · índices · tipos |
| `endpoint.*` | Rutas HTTP con método |
| `contract.*` | Secciones de api-contract.md |
| `event.*` | Eventos del sistema |
| `file.*` | Archivos concretos |
| `adr.*` | Decisiones arquitectónicas |
| `interface.*` | Funciones · clases · componentes |
| `test.*` | Tests |
| `env.*` | Variables de entorno |

Esto permite que `/task-dependency-analyzer` (Pareja 7b) haga matching literal entre consume/produce de distintos planes · detecta dependencias cross-historia.

---

## Qué NO hacer en este repo

- No hagas commit de secretos o API keys · aunque sea ejercicio
- No borres lo que pusheó otra pareja · `git revert` si hace falta y avisá en Slack
- No cambies nombres de carpetas del pipeline · las skills los asumen

---

## Referencias

- Herramientas · `https://github.com/juan-estrada-itti/way-of-work-tools`
- Pipeline completo · `https://github.com/juan-estrada-itti/way-of-work-tools/blob/main/pipeline/pipeline-greenfield.md`
- Glosario · `https://github.com/juan-estrada-itti/way-of-work-tools/blob/main/pipeline/glosario.md`
- Guía de instalación del kit · `https://github.com/juan-estrada-itti/way-of-work-tools/blob/main/kit/INSTALL.md`

---

**Última actualización** · 2026-04-22 · Juan Estrada

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. The
skill has multi-step workflows, checklists, and quality gates that produce better
results than an ad-hoc answer. When in doubt, invoke the skill. A false positive is
cheaper than a false negative.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke /office-hours
- Strategy, scope, "think bigger", "what should we build" → invoke /plan-ceo-review
- Architecture, "does this design make sense" → invoke /plan-eng-review
- Design system, brand, "how should this look" → invoke /design-consultation
- Design review of a plan → invoke /plan-design-review
- Developer experience of a plan → invoke /plan-devex-review
- "Review everything", full review pipeline → invoke /autoplan
- Bugs, errors, "why is this broken", "wtf", "this doesn't work" → invoke /investigate
- Test the site, find bugs, "does this work" → invoke /qa (or /qa-only for report only)
- Code review, check the diff, "look at my changes" → invoke /review
- Visual polish, design audit, "this looks off" → invoke /design-review
- Developer experience audit, try onboarding → invoke /devex-review
- Ship, deploy, create a PR, "send it" → invoke /ship
- Merge + deploy + verify → invoke /land-and-deploy
- Configure deployment → invoke /setup-deploy
- Post-deploy monitoring → invoke /canary
- Update docs after shipping → invoke /document-release
- Weekly retro, "how'd we do" → invoke /retro
- Second opinion, codex review → invoke /codex
- Safety mode, careful mode, lock it down → invoke /careful or /guard
- Restrict edits to a directory → invoke /freeze or /unfreeze
- Upgrade gstack → invoke /gstack-upgrade
- Save progress, "save my work" → invoke /context-save
- Resume, restore, "where was I" → invoke /context-restore
- Security audit, OWASP, "is this secure" → invoke /cso
- Make a PDF, document, publication → invoke /make-pdf
- Launch real browser for QA → invoke /open-gstack-browser
- Import cookies for authenticated testing → invoke /setup-browser-cookies
- Performance regression, page speed, benchmarks → invoke /benchmark
- Review what gstack has learned → invoke /learn
- Tune question sensitivity → invoke /plan-tune
- Code quality dashboard → invoke /health
