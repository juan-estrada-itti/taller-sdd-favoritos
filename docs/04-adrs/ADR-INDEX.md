# ADRs · Planning Poker · sala temporal + votación WebSockets

| # | Decisión | Status | Requiere PoC | Link |
|---|----------|--------|--------------|------|
| 001 | Usar `ws` nativo en vez de Socket.io o SSE | Proposed | No | [ADR-001](./ADR-001-websockets-nativos-ws.md) |
| 002 | Estado de salas en memoria sin base de datos | Proposed | No | [ADR-002](./ADR-002-estado-en-memoria-sin-persistencia.md) |
| 003 | Frontend vanilla TypeScript + Tailwind sin framework SPA | Proposed | No | [ADR-003](./ADR-003-frontend-vanilla-ts-tailwind.md) |
| 004 | Arquitectura híbrida REST + WebSocket | Proposed | No | [ADR-004](./ADR-004-arquitectura-hibrida-rest-websocket.md) |
| 005 | Recuperación del rol Scrum Master tras desconexión | Proposed | ⚠️ Sí | [ADR-005](./ADR-005-recuperacion-rol-scrum-master.md) |
| 006 | Protocolo de privacidad de votos: VOTE_CAST sin valor | Proposed | No | [ADR-006](./ADR-006-protocolo-privacidad-votos.md) |

---

## PoCs pendientes (antes de implementar)

- **ADR-005** · Recuperación del rol Scrum Master · estimado: 2-3 horas · criterio de éxito: implementar opción 1 (nombre) y opción 2 (token) en branches separados · medir complejidad de código y UX de recuperación · el equipo elige cuál entra en el MVP

---

## Resumen ejecutivo

El RFC define una arquitectura híbrida REST + WebSocket donde REST maneja el lifecycle de sala (crear, verificar) y WebSocket maneja todo el protocolo in-room en tiempo real. Las decisiones centrales priorizan simplicidad operacional sobre robustez: `ws` nativo sobre Socket.io, estado en memoria sobre SQLite, vanilla TS sobre un framework SPA. El único punto de incertidumbre real es la recuperación del rol Scrum Master tras desconexión, que requiere un spike antes de comprometerse a una implementación. El protocolo de privacidad de votos — `VOTE_CAST` sin valor hasta `VOTES_REVEALED` — es la decisión de diseño más importante del sistema: garantiza que Planning Poker cumpla su propósito de eliminar el sesgo de ancla.

---

**Fuente:** `docs/02-rfc/rfc.md`
**Próximo paso:** Pareja 5 → `/contract-define` usando estos ADRs como input de governance
**Last Updated:** 2026-04-24
