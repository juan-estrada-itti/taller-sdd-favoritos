# Taller SDD · Favoritos de Skills

**Workspace compartido del Taller 2 SDD** · viernes 24/4/2026 · 16:30-18:00 Paraguay · relay de 8 parejas · proyecto greenfield.

---

## El proyecto (ficticio)

**Feature** · marcar skills de Claude Code como favoritas · aparecen arriba cuando apretás `/`.

**Usuario** · los 20 del equipo tech emergentes · cada uno usa decenas de skills · busca las mismas varias veces al día.

**Meta del feature** · bajar tiempo de invocación de skill de ~3s a ~1s.

**Greenfield** · no hay código previo · no hay usuarios · todo se decide en el pipeline.

---

## Cómo se usa este repo · durante el taller

Las 8 parejas del relay van llenando este repo, una fase por vez:

```
docs/
├── 00-discovery/     · Pareja 1 · /office-hours
├── 01-prd/           · Pareja 2 · /create-prd
├── 02-rfc/           · Pareja 3 · /rfc-builder
├── 04-adrs/          · Pareja 4 · /rfc-to-adr
├── 03-contracts/     · Pareja 5 · /contract-define
├── 05-stories/       · Pareja 6 · /user-story-builder
├── 06-plans/         · Pareja 7a · /story-to-plan
├── 07-dag/           · Pareja 7b · /task-dependency-analyzer
└── 08-reviews/       · Pareja 8 · /code-review
```

### Flujo por pareja

1. `git pull` · bajás el output de la pareja anterior
2. Abrís Claude Code en este repo
3. Corrés tu skill correspondiente (la skill lee los artefactos de fases previas)
4. La skill produce el artefacto en tu carpeta
5. `git add docs/<tu-fase>/ && git commit -m "<tu fase>: <resumen>" && git push`
6. Show & tell al grupo · *"lo que más nos sorprendió fue ___"*
7. Pareja siguiente arranca

### Si te trabás

- Slack `#way-of-work` · Juan responde · Alejo observa dinámica
- Último recurso · escribí algo razonable a mano · se valida en review post-taller

---

## Asignación de parejas

| # | Driver · Navigator | Fase | Skill | Output |
|---|---|---|---|---|
| 1 | Juan Manuel · Stephany | Discovery | `/office-hours` | `docs/00-discovery/discovery.md` |
| 2 | Sergio · Javier | PRD | `/create-prd` | `docs/01-prd/prd.md` |
| 3 | Fede · Andrés | RFC | `/rfc-builder` | `docs/02-rfc/rfc.md` |
| 4 | Hugo · Juan Pa | ADRs | `/rfc-to-adr` | `docs/04-adrs/ADR-*.md` |
| 5 | Luciano · Ana | Contratos | `/contract-define` | `docs/03-contracts/api-contract.md` |
| 6 | Leo · Carlos | Historias | `/user-story-builder` | `docs/05-stories/stories.md` |
| 7 | Nico Canese · Nico Cóppola | Plan + DAG | `/story-to-plan` + `/task-dependency-analyzer` | `docs/06-plans/plan-H*.md` + `docs/07-dag/tasks.json` |
| 8 | German · Fernando | Code Review | `/code-review` | `docs/08-reviews/review.md` |

---

## Setup antes del taller · los 16

1. **Kit instalado** · ver `https://github.com/juan-estrada-itti/way-of-work-tools/blob/main/kit/INSTALL.md`
2. **Este repo clonado** ·
   ```bash
   git clone https://github.com/juan-estrada-itti/taller-sdd-favoritos.git
   cd taller-sdd-favoritos
   ```
3. **1 idea greenfield en la cabeza** · por si la Pareja 1 la necesita como backup

---

## El pipeline SDD

El pipeline completo que vamos a recorrer:

```
/office-hours → discovery.md
      ↓
/create-prd → prd.md
      ↓
/rfc-builder → rfc.md
      ↓
/rfc-to-adr → docs/04-adrs/ADR-*.md     (V4 · si RFC >5 decisiones)
      ↓
/contract-define → api-contract.md
      ↓
/user-story-builder → stories.md
      ↓
/story-to-plan → plan-H<N>.md            (1 por historia)
      ↓
/task-dependency-analyzer → DAG + tasks.json
      ↓
[código]                                 (próxima sesión)
      ↓
/code-review → review.md
```

Detalle completo · `https://github.com/juan-estrada-itti/way-of-work-tools/blob/main/pipeline/pipeline-greenfield.md`

---

## Reglas del way of work aplicables

- **V1** · el PRD técnico no puede reducir alcance del PRD de negocio
- **V2** · hasta el RFC, validamos cada paso contra el PRD
- **V3** · `CLAUDE.md` obligatorio antes de codear (ya está)
- **V4** · RFC con >5 decisiones → ADRs obligatorios
- **V5** · plan micro (`/story-to-plan`) antes de DAG macro

---

## Después del taller

Este repo queda como:
- **Caso de estudio** · sirve para onboarding de nuevos
- **Posible implementación real** · si el feature cobra sentido, Sergio + Fede pueden codearlo en la semana siguiente
- **Demo para futuros talleres** · los próximos ven este relay como ejemplo

---

**Última actualización** · 2026-04-22 · Juan Estrada
