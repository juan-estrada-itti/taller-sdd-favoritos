# ADR-001 · Usar `ws` nativo en vez de Socket.io o SSE

**Status:** Proposed
**Date:** 2026-04-24
**Deciders:** Pareja 3 (autores RFC) · Pareja 4 (ADRs)

## Contexto

El core del producto es votación en tiempo real con reveal simultáneo. El servidor necesita enviar eventos a todos los participantes de una sala al mismo tiempo (broadcast), y los clientes necesitan enviar votos sin polling. La elección del protocolo de comunicación define el modelo de conexión, el manejo de estado y la complejidad del servidor.

## Decisión considerada

Opciones evaluadas:

1. **`ws` nativo (Node.js)** · librería mínima sobre el protocolo WebSocket RFC 6455 · sin abstracciones
   - pros: control directo del protocolo · sin dependencias ocultas · fácil de razonar sobre el estado de cada conexión · bajo overhead
   - contras: reconexión automática no incluida (se implementa manual, ~20 líneas) · no tiene rooms/namespaces built-in · requiere implementar el broadcast manualmente

2. **Socket.io** · abstracción sobre WebSockets con fallbacks y helpers built-in
   - pros: reconexión automática · rooms/namespaces · fallback a long-polling si WS no está disponible
   - contras: abstracción sobre el protocolo dificulta el control directo · peso de dependencia mayor · el MVP no necesita ninguna de las features extra · oculta la mecánica que el taller busca enseñar

3. **Server-Sent Events (SSE)** · push unidireccional del servidor con `fetch` para envíos del cliente
   - pros: más simple de implementar en el servidor · sin handshake WS · HTTP estándar
   - contras: comunicación inherentemente unidireccional — los votos tendrían que ir por HTTP POST separados, complicando la asociación cliente↔sala y el manejo de estado de conexión

4. **Polling periódico (1-2s)** · el cliente hace GET al estado de la sala cada segundo
   - pros: implementación trivial · sin conexiones persistentes
   - contras: viola RNF-01 (<500ms latencia) · P50 ~500ms, P95 ~1000ms · 100 salas × 15 participantes × 1 req/s = 1500 req/s en idle · no escala

## Decisión tomada

**`ws` nativo** porque el protocolo de sala es bidireccional simple (5 tipos de mensajes cliente→servidor, 8 servidor→cliente), la complejidad de Socket.io no se justifica para ese scope, y la reconexión manual es ~20 líneas de código.

## Consecuencias

### Positivas
- Control directo sobre el protocolo — cada mensaje está explícitamente tipado en `WSMessage`
- Sin abstracciones que oculten la mecánica de broadcast/unicast
- Menor surface area de dependencias
- El protocolo de sala queda documentado explícitamente (ver RFC sección 4.2.3)

### Negativas / trade-offs aceptados
- La reconexión automática debe implementarse manualmente en el cliente (`room.ts`)
- El broadcast a todos los participantes de una sala es responsabilidad del código propio (`broadcaster.ts`)
- Si en V2 se necesitan namespaces o múltiples servidores, migrar a Socket.io requiere refactor

## Requiere PoC antes de implementar

☐ No · la librería `ws` tiene 8+ años de uso en producción · el protocolo es RFC 6455 · la decisión está basada en evidencia del equipo y la sección 5 del RFC

## Referencias

- RFC fuente: `docs/02-rfc/rfc.md` — sección 4.3 (stack) y sección 5 (alternativas A, B, D)
- RNF-01: latencia < 500ms — incompatible con polling
- Decisiones relacionadas: ADR-004 (arquitectura híbrida REST + WebSocket)
