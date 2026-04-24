# ADR-002 · Estado de salas en memoria sin base de datos

**Status:** Proposed
**Date:** 2026-04-24
**Deciders:** Pareja 3 (autores RFC) · Pareja 4 (ADRs)

## Contexto

Las salas de Planning Poker son efímeras por diseño: existen durante una sesión de refinement (1-3 horas), expiran a las 24h, y no tienen valor histórico para el MVP. La elección de dónde persistir el estado define la complejidad de infraestructura, la velocidad de acceso y el comportamiento ante reinicios del servidor.

## Decisión considerada

Opciones evaluadas:

1. **Estado en `Map<roomId, RoomState>` en memoria del proceso** · singleton en el proceso Node.js · TTL via `setTimeout`
   - pros: cero latencia de I/O · sin infra adicional · sin migraciones · implementación en ~50 líneas · alineado con el diseño efímero del producto
   - contras: un restart del servidor destruye todas las salas activas · no escala horizontalmente (múltiples instancias no comparten estado)

2. **SQLite** · archivo local · sin servidor separado · CLAUDE.md lo lista como default
   - pros: sobrevive restarts · historial potencial de sesiones para V2 · sin infra externa
   - contras: el PRD establece explícitamente "no persistent data storage" en NFRs de seguridad · agrega complejidad de esquema, migraciones y queries para cero beneficio en el MVP · las salas son efímeras por diseño

3. **Redis o base de datos distribuida** · estado compartido entre múltiples instancias del servidor
   - pros: escala horizontal · sobrevive restarts · permite clustering
   - contras: infra adicional requerida · fuera del scope del MVP · complejidad operacional injustificada para un ejercicio de taller con deploy local

## Decisión tomada

**Estado en memoria** porque las salas son efímeras por diseño del PRD, no hay datos que persistan entre sesiones, y la complejidad de SQLite o Redis no aporta valor al MVP.

## Consecuencias

### Positivas
- Cero overhead de I/O en operaciones de sala — acceso directo al `Map`
- Sin dependencias de infra — el proyecto corre con `npm run dev` sin setup adicional
- Implementación simple y legible del `RoomStore`
- TTL automático via `setTimeout` con limpieza explícita del `Map` y las conexiones WS

### Negativas / trade-offs aceptados
- Un restart del servidor destruye todas las salas activas — **comportamiento documentado y esperado**
- No escala horizontalmente sin reemplazar el store (blocker para V2 en producción real)
- Si un `setTimeout` no se cancela correctamente al cerrar una sala, hay riesgo de memory leak — mitigado con `clearTimeout` en `closeRoom` y test unitario explícito (ver RFC sección 8, Riesgo 3)

## Requiere PoC antes de implementar

☐ No · el trade-off está justificado explícitamente en el PRD (NFRs de seguridad) y en la sección 5 del RFC (Alternativa C) · el comportamiento de pérdida de estado en restart es esperado y documentado

## Referencias

- RFC fuente: `docs/02-rfc/rfc.md` — sección 4.1 (arquitectura), 4.2.1 (modelo de estado), sección 5 (Alternativa C)
- PRD negocio: `docs/01-prd/prd.md` — NFRs de seguridad ("no persistent data storage")
- RNF-06: "No se persisten datos personales — el almacenamiento es en memoria (TTL 24h)"
- Decisiones relacionadas: ADR-001 (WebSockets), ADR-004 (arquitectura híbrida)
