# Fase 7b · DAG macro

**Pareja 7 (segunda parte)** · Nico Canese + Nico Cóppola

**Skill** · `/task-dependency-analyzer`

**Input** · todos los `docs/06-plans/plan-H*.md`

**Output** · `dag.md` (Mermaid) + `tasks.json` (Agents Kanban format con prompts ejecutables)

## Qué produce

El DAG analiza dependencias entre subtasks de TODAS las historias:
- Phases (paralelizables)
- Critical path
- Dependency rationale (schema, interface, infra, lógica)
- JSON con prompts ejecutables listos para Agents Kanban

## Siguiente pareja

Pareja 8 (German + Fernando) hace code review.
Nota: si alcanzamos a codear algo, va en `src/`.
