# Fase 7a · Planes por historia

**Pareja 7 (primera parte)** · Nico Canese + Nico Cóppola

**Skill** · `/story-to-plan`

**Input** · 1 historia INVEST (de `docs/05-stories/stories.md`) + ADRs + contrato + CLAUDE.md

**Output** · `plan-H<N>.md` · 1 por historia · subtasks verticales FE+BE+DB+tests

**Clave** · cada subtask declara `consume` y `produce` con namespaces (schema.* · endpoint.* · adr.* · etc.) · así Pareja 7b puede armar el DAG sin ambigüedad.

## Siguiente paso · misma pareja

Con los N plan-H<N>.md listos, pasás a la Fase 7b · DAG macro.
