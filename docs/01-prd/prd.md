# PRD · SDD Context Packager para Brownfield

**Status:** DRAFT v2 (PIVOT fundamentado en evidencia del caso AppSec Q1 2026)
**Versión:** v0.2 · 2026-04-24
**Autor:** Juan Estrada (con Claude Opus 4.7 vía `/create-prd`)
**Supersedes:** PRD v0.1 (health check pasivo · archivado)
**Input:** `docs/00-discovery/discovery.md` + investigación sobre caso AppSec + análisis de inputs de las 8 skills del pipeline
**Output esperado:** alimenta `docs/02-rfc/rfc.md` (Pareja 3)

---

## ⚠️ Nota sobre el pivot

Durante `/create-prd` el autor identificó que el problema real no es "detectar gap de documentación retrospectiva" sino **"no sé qué contexto meterle a las skills SDD para que los RFCs y ADRs salgan buenos"**. La investigación posterior sobre el único caso end-to-end funcional de la org (AppSec Q1 2026) confirmó que el cuello de botella es el contexto inyectado en los prompts, no la adopción del pipeline.

Evidencia canónica — **L-017 del caso AppSec**: la regla "Security Filters NO se instancian con @Bean" existía como comentario en `SecurityConfig.java` líneas 31-35. Los agentes IA no la vieron → generaron código con @Bean → response already committed. Fix: mover la regla a `CLAUDE.md`. **Contexto explícito > contexto implícito** es el principio central que justifica este MVP.

---

## 1. Contactos

| Stakeholder | Rol | Autoridad de decisión | Notas |
|---|---|---|---|
| Juan Estrada | Lead plataforma de skills · itti-digital | Autor del MVP · owner del pipeline SDD | Decide scope |
| Tech lead de academy | Usuario target primario | Beneficiario directo | `[No validado con entrevista · asignación office-hours pendiente]` |
| Tech lead de ittilab | Usuario target secundario | Beneficiario directo | `[No validado]` |
| Equipo de 5 expertos | Co-diseñadores del way of work · co-usuarios del MVP | Fuente de verdad de qué contexto necesitan las skills | Consultar para patrón del context pack |
| Alejo | Rol pedagógico · coordinador Taller 2 | Facilitación | Contexto workshop |

---

## 2. Problema

**Quién:** cualquier persona (tech lead, builder, miembro del equipo de Juan) que quiere correr una skill del pipeline SDD (`/office-hours`, `/create-prd`, `/rfc-builder`, `/rfc-to-adr`, `/contract-define`, `/user-story-builder`, `/story-to-plan`) sobre un proyecto brownfield como academy o ittilab.

**Pain real:** las skills del pipeline piden inputs de contexto (CLAUDE.md, ADRs previos, api-contract, patrones del codebase, journeys del dominio) que **en brownfields no existen en forma utilizable**. Sin ese contexto, las skills producen outputs genéricos que no se aterrizan en el proyecto real → los artefactos generados son decorativos, no ejecutables, o contradicen el código existente → la gente pierde confianza en el pipeline y vuelve a codear sin proceso.

**Evidencia:**
- **Análisis de inputs de las 8 skills del pipeline**: 5 tipos de contexto aparecen repetidos como input (CLAUDE.md, ADRs, api-contract, codebase, PRD). En un brownfield sin pipeline previo, ninguno existe formalizado.
- **Caso AppSec Q1 2026 · learning L-017**: la regla "security filters con `new`, no @Bean" estaba como comentario en código → los agentes no la vieron → generaron código roto. Se arregló **moviendo la regla a `CLAUDE.md`**. La lección explícita: contexto implícito falla, contexto explícito funciona.
- **Caso AppSec Q1 2026 · learning L-016**: `tasks.json` generado sin spec-engine produjo prompts sin TDD ni plan → agentes generaron código que no seguía patrones del repo. Fix: usar spec-engine para inyectar contexto concreto (journeys + CLAUDE.md + patrones del código) en los prompts.
- **Discovery (Juan, textual)**: *"para crear buenos RFCs y ADRs se necesita buen contexto y no sé qué es ese contexto"*. El lead del way of work reconoce que el problema del contexto está sin resolver.

**Workaround actual:** la gente que sí intenta correr el pipeline en un brownfield, alimenta a las skills con el prompt que puede (a veces nada, a veces pega un README viejo). El output es de calidad variable, a menudo genérico. Los que no intentan, simplemente saltean el pipeline.

**Impacto si no se resuelve:**
- Las skills existentes del equipo se subutilizan porque "no dan buen output en proyectos reales"
- La inversión en el way of work (8 skills + documentación + caso AppSec) no escala a academy/ittilab
- El equipo de 5 expertos sigue siendo cuello de botella (único grupo que puede aportar el contexto mentalmente)

**Validación:** `[Problema validado indirectamente vía caso AppSec (N=1 aplicación real) + análisis de inputs de skills. Validación directa con usuarios brownfield pendiente.]`

---

## 3. Hipótesis

- **Si** generamos automáticamente un "paquete de contexto" (CLAUDE.md + journeys + patrones + ADRs retrospectivos + api-contract) para un proyecto brownfield, extraído del código existente,
- **Entonces** cualquier persona del equipo podrá correr las skills SDD sobre ese brownfield y obtener outputs aterrizados y específicos — no genéricos — porque las skills consumen contexto explícito en vez de inferir sobre la marcha,
- **Medido por** una comparación ciega: 3 skills del pipeline corridas sobre el mismo brownfield con y sin el context pack. Se puntúa calidad del output (1-5) usando criterios de `/code-review`. Target: el output "con pack" puntúa ≥1.5 puntos por encima del "sin pack" en promedio.

**Caso de falsificación:** si el context pack generado automáticamente no levanta la calidad de los outputs de skills en ≥1.5 puntos, O si genera un pack que el propio equipo experto rechaza como "no refleja el proyecto real", la hipótesis se cae → se descarta el MVP.

---

## 4. User Stories

### JTBD por segmento

| Usuario | Job to be Done | Why | Desired Outcome |
|---|---|---|---|
| Persona que va a correr una skill SDD sobre un brownfield | Tener a mano el contexto específico del proyecto en un formato que las skills entiendan | Para que los outputs de las skills se aterricen al proyecto real y no salgan genéricos | Un paquete de archivos "pegables" en el prompt de cualquier skill · cero archaeology manual |
| Tech lead de un brownfield | Tener documentación mínima del proyecto que antes no existía | Onboarding más rápido, menos preguntas repetidas, contexto para decisiones nuevas | `CLAUDE.md` + journeys + ADRs retrospectivos existiendo como documentación viva |
| Equipo de 5 expertos | Bajar el costo de "cargar el contexto mentalmente" cada vez que ayudan a otro equipo | Dejar de ser cuello de botella · transferir conocimiento implícito a artefacto explícito | El equipo escribe el context pack una vez, se actualiza semi-automáticamente, cualquiera lo usa |

---

### User Stories v1

**Story 1 · Arrancar un context pack desde cero en un brownfield**
> Como builder/lead/experto que va a correr una skill SDD sobre un brownfield, quiero ejecutar un comando único sobre los repos del proyecto y obtener un paquete de contexto completo, para poder pegárselo al prompt de cualquier skill sin hacer archaeology manual.

Criterios de aceptación:
- [ ] Un comando `sdd-context pack --project=academy` lee un manifiesto yaml con la lista de repos
- [ ] En <10 minutos genera un directorio `academy-context-pack/` con los 5 archivos core
- [ ] El directorio es autocontenido: se puede `cat academy-context-pack/*.md | pbcopy` y pegar al prompt
- [ ] El comando es idempotente: correrlo dos veces sobre el mismo proyecto genera el mismo output (o actualiza consistentemente si el código cambió)

---

**Story 2 · Generar CLAUDE.md explícito desde codebase implícito**
> Como usuario del context pack, quiero que el MVP infiera y escriba un `CLAUDE.md` del proyecto brownfield con convenciones, stack, patrones y reglas críticas detectadas en el código, para convertir conocimiento tribal en documento consumible por las skills.

Criterios de aceptación:
- [ ] Detecta el stack (lenguaje, framework, testing library, DB) leyendo `package.json`, `pom.xml`, `build.gradle`, etc.
- [ ] Infiere patrones recurrentes (ej: "usa el patrón hexagonal en X% de los módulos", "todos los endpoints validan con Zod")
- [ ] Flagea reglas críticas de estilo si aparecen en comments consistentes del código (estilo L-017 del caso AppSec)
- [ ] Output sigue la plantilla de CLAUDE.md del caso AppSec (126 líneas, secciones conocidas)
- [ ] Permite edición humana: genera un `CLAUDE.md.draft` + deja los puntos inferidos marcados con `[inferred]` para que un experto los valide antes de promocionarlos

---

**Story 3 · Inferir journeys del dominio desde controllers/endpoints**
> Como usuario del context pack, quiero que el MVP genere un archivo `journeys/*.md` por cada flujo de negocio principal detectado (auth, user management, contenido, etc), para que las skills que escriben stories o PRDs tengan los flujos reales del dominio como input y no tengan que inventar.

Criterios de aceptación:
- [ ] Agrupa endpoints/controllers por módulo/bounded context
- [ ] Para cada grupo, infiere un journey markdown con: actores, pasos, inputs, outputs, errores conocidos
- [ ] Marca como `[inferred · needs review]` los pasos que dedujo sin evidencia fuerte
- [ ] Si existen docs previos (READMEs, comentarios de módulos) los usa como input para enriquecer

---

**Story 4 · Detectar ADRs retrospectivos desde el código**
> Como usuario del context pack, quiero que el MVP escriba un ADR retrospectivo por cada decisión arquitectónica observable en el código (elección de stack, patrón dominante, librería de auth, etc), para que las skills tengan una base de decisiones previas que no se pueden contradecir en el nuevo RFC.

Criterios de aceptación:
- [ ] Detecta las "decisiones visibles" (stack, auth library, DB, framework de testing, patrón dominante)
- [ ] Para cada una, genera un ADR en formato Nygard (Contexto / Decisión / Consecuencias)
- [ ] Marca el `Status` como `Observed · retrospective` (no `Accepted` — porque no fue una decisión tomada hoy)
- [ ] Numerar incrementalmente (ADR-001, ADR-002...)

---

**Story 5 · Reverse-engineer api-contract.md** (incremento v1.5)
> Como usuario del context pack, quiero que el MVP genere un `api-contract.md` inicial escaneando los endpoints existentes, para que las skills de contratos y stories consuman un contrato real en vez de inventar.

Criterios de aceptación:
- [ ] Detecta endpoints HTTP (ruta + método)
- [ ] Extrae schemas de request/response si están declarados (Zod, OpenAPI inline, TypeScript types)
- [ ] Agrupa por recurso
- [ ] Marca huecos con `[schema desconocido · requiere inspección manual]`

---

**Stories explícitamente NO incluidas en v1:**
- ❌ "Generar el pack en múltiples proyectos a la vez" → multi-tenant post-validación
- ❌ "Dashboard web del estado del pack" → overkill antes de probar valor
- ❌ "Auto-update del pack cuando se pushea código" → webhooks = v2
- ❌ "Generación de RFCs/ADRs nuevos a partir del pack" → ese es el valor downstream (las skills lo hacen), no el MVP
- ❌ "Edición colaborativa del pack" → archivo markdown simple es suficiente

---

## 5. Diseño

**Status:** sin wireframes (no hay UI gráfica). El "diseño" es la estructura de archivos del output + la experiencia CLI.

**Output estructural del MVP:**

```
academy-context-pack/
├── README.md                        # qué es este pack, cuándo se regeneró, qué repos cubre
├── CLAUDE.md                        # convenciones, stack, reglas críticas, patrones
├── journeys/
│   ├── 01-auth.md
│   ├── 02-user-management.md
│   ├── 03-content.md
│   └── ...                          # uno por bounded context detectado
├── patterns.md                      # patrones recurrentes extraídos del código
├── adrs-retrospectivos/
│   ├── ADR-001-stack.md
│   ├── ADR-002-auth.md
│   ├── ADR-003-database.md
│   └── ...                          # uno por decisión observable
├── api-contract.md                  # endpoints + schemas (reverse-engineered)
└── inferred-items.md                # lista de cosas que el pack marcó `[inferred]` para review humana
```

**CLI flow:**

```
$ sdd-context pack --project=academy
> Leyendo manifiesto en manifests/academy.yaml...
> 4 repos detectados: academy-web, academy-api, academy-mobile, academy-cms
> Clonando repos...
> Analizando stack de cada repo...
> Inferindo patrones...
> Detectando decisiones arquitectónicas observables...
> Inferindo journeys por bounded context...
> Reverse-engineering api-contract...
>
> ✓ Pack generado en: ./academy-context-pack/
> ⚠ 23 items marcados como [inferred] · revisar en inferred-items.md
> Tamaño del pack: 87 KB (pegable en un prompt de Claude sin problema)
```

**Fuera de scope del diseño del MVP:**
- UI web, dashboard
- Edición in-app
- Integraciones con Notion/Confluence/etc.
- Localización

---

## 6. Scope

### V1 (MVP — este release)

- CLI `sdd-context pack --project=<nombre>` que lee manifiesto yaml
- Soporta 1 proyecto piloto (academy o ittilab)
- Genera los 5 archivos core del pack:
  - `CLAUDE.md` (Story 2)
  - `journeys/*.md` (Story 3)
  - `adrs-retrospectivos/*.md` (Story 4)
  - `api-contract.md` (Story 5 · incluido en v1)
  - `patterns.md` (derivado de Stories 2 y 3)
- Archivo `inferred-items.md` con todo lo que se marcó `[inferred]` para review humana
- Ejecución <10 min
- Output idempotente

### Futuro (NO en MVP — gated por validación)

- Multi-proyecto (academy + ittilab simultáneo) — post-validación con 1 proyecto
- Auto-update on push (webhooks) — post-validación de uso sostenido
- Detección de drift del pack (el código cambió, el pack está desactualizado) — post-PMF
- Edición colaborativa del pack — si emerge demanda
- Integración con Notion/Confluence — si alguien lo pide explícitamente
- Packs especializados (ej: pack solo para seguridad, pack solo para performance) — post-PMF

---

## 7. Métricas y Baseline

**Métrica central · calidad de output del pipeline con/sin pack:**

| Métrica | Baseline (sin pack) | Target (con pack, 1 mes) | Cómo medir | Owner |
|---|---|---|---|---|
| Calidad del output de `/rfc-builder` sobre un brownfield (escala 1-5, criterios `/code-review`) | `[Baseline pendiente · medir en academy antes de generar pack]` | ≥ baseline + 1.5 | A/B blind review: 1 RFC con pack, 1 RFC sin pack, revisa experto que no sabe cuál es cuál | Juan + 1 experto |
| % de ADRs retrospectivos marcados `[inferred]` que sobreviven review humano sin cambios | N/A (no existen hoy) | ≥60% | Review manual del equipo de 5 expertos | Equipo experto |
| Tiempo de "cargar contexto mental" para ayudar a un brownfield | `[Baseline pendiente · encuesta al equipo de 5 expertos]` | −50% reportado cualitativamente | Encuesta 1:1 antes y después | Juan |
| Adopción: ¿cuántas veces se corrió el CLI? ¿cuántas personas distintas? | 0 | ≥3 personas distintas en 2 semanas post-release | Logs del CLI (simple counter file) | Juan |
| Outputs del pipeline que referencian explícitamente archivos del pack | 0 | ≥1 RFC o PRD que cite `academy-context-pack/CLAUDE.md` | Grep en outputs generados | Juan |

**Criterio de falsificación (kill switch):**
- Si al mes no se cumple el target de calidad (output con pack ≤ baseline + 1.0), la hipótesis central se cae → se archiva el MVP.
- Si el equipo experto rechaza el pack como "no refleja el proyecto" (≥30% de los ADRs inferidos se descartan), el MVP necesita repensar el algoritmo de inferencia.

---

## 8. NFRs

- **Performance:** generación del pack en <10 minutos para un proyecto de ≤10 repos. Paralelizar por repo.
- **Fiabilidad:** si falla el análisis de 1 repo, el pack se genera igual con el resto + reporta el fallo en `inferred-items.md`.
- **Determinismo:** el pack debe ser **idempotente** — correrlo dos veces sobre el mismo estado del código genera output byte-identical (importante para versionar el pack en git).
- **Costo:** depende de si usa LLM inferencia.
  - **Opción A (sin LLM · solo reglas estáticas):** cero costo recurrente. Inferencia más débil.
  - **Opción B (con LLM para inferir journeys y patterns):** costo por corrida. Estimar ≤USD 0.50 por pack usando Claude Haiku para tareas de síntesis y Sonnet para el CLAUDE.md.
  - Decisión del método: RFC (Pareja 3).
- **Seguridad:** el CLI solo necesita `read` sobre los repos del manifiesto. No toca base de datos, no lee secrets, no manda nada a servicios externos salvo el LLM (si se usa) con la policy de datos ya acordada en itti.
- **Privacidad:** si el código es privado, el pack debe generarse local o en infra de la org — no mandar código full a servicios externos no contratados.
- **Mantenibilidad:** los templates de salida (CLAUDE.md, ADR, journey) son archivos markdown con placeholders — editables sin tocar código.
- **Compatibilidad:** corre en Node 20+ / bun, Linux y macOS. Stack default del repo del taller.

---

## Validaciones pendientes (pre-build)

1. **Entrevista de 30 min con tech lead de academy o ittilab** (asignación original del office-hours · sigue vigente): validar que "el problema del contexto" es un dolor reconocido, no solo diagnóstico del lead.
2. **Workshop con el equipo de 5 expertos**: consensuar la plantilla del `CLAUDE.md` inferido y los criterios de cuándo marcar algo `[inferred]` vs `[observed]`.
3. **Elegir proyecto piloto**: academy o ittilab. Criterio sugerido: el que tenga un tech lead más dispuesto a revisar el pack generado y dar feedback honesto.
4. **Decisión de método de inferencia (estático vs LLM)**: esto lo define el RFC, pero impacta costos y velocidad. Si se elige LLM, confirmar presupuesto y data policy.
5. **Definir la métrica de baseline**: antes de generar el primer pack, correr `/rfc-builder` sobre el proyecto piloto SIN pack y documentar el output — ese es el baseline de calidad contra el que se compara.

---

## Trazabilidad al caso AppSec Q1 2026

Este MVP no es idea nueva — es la generalización de lo que ya funcionó:

| Elemento del pack | Corresponde a | En el caso AppSec estuvo |
|---|---|---|
| `CLAUDE.md` | Convenciones del proyecto | 126 líneas con stack + hexagonal + bounded contexts |
| `journeys/*.md` | Flujos del dominio | `docs/journeys/01-auth.md`, `02-user.md`, `07-xapi.md` |
| `patterns.md` | Patrones observables | Patrones hexagonales mencionados en lessons L-004 |
| `adrs-retrospectivos/*.md` | Decisiones visibles | L-017 retroactivamente escrito en `CLAUDE.md` |
| `api-contract.md` | Puente FE/BE | No se ejecutó `/contract-define` en AppSec · gap reconocido |

**El MVP convierte lo que en AppSec se hizo manualmente (y parcialmente) en algo automatizable para cualquier brownfield.**

---

## Anexo · Referencias

- Discovery source: `docs/00-discovery/discovery.md`
- PRD v0.1 archivado (health check pasivo): git history de este archivo, commit previo a v0.2
- Caso AppSec Q1 2026: `/Users/juan.estrada/projects/agents/docs/case-appsec-q1-2026/`
  - `lessons.md` · L-015, L-016, L-017 son evidencia central de este PRD
  - `plan.md`, `stories.md` · ejemplo de outputs de alta calidad que usaron contexto explícito
- Análisis de inputs de las 8 skills: `/Users/juan.estrada/projects/tech_emergentes_skills/*/SKILL.md`
- CLAUDE.md del taller: convenciones + pipeline
