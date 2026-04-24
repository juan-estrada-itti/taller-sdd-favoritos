# ADR-004 · Arquitectura híbrida REST + WebSocket: REST para lifecycle, WS para protocolo in-room

**Status:** Proposed
**Date:** 2026-04-24
**Deciders:** Pareja 3 (autores RFC) · Pareja 4 (ADRs)

## Contexto

El sistema tiene dos categorías de operaciones claramente distintas: (1) operaciones de lifecycle de sala — crear, verificar existencia, obtener metadata — que son request/response puntuales; y (2) el protocolo de sala — join, vote, reveal, new_round, close — que ocurre en tiempo real con múltiples participantes y requiere broadcast. La decisión de cómo exponer estas operaciones define los límites del contrato API y la complejidad del servidor.

## Decisión considerada

Opciones evaluadas:

1. **REST para lifecycle + WebSocket para protocolo in-room (híbrido)**
   - `POST /api/rooms` crea la sala · `GET /api/rooms/:id` verifica existencia
   - Todo lo que ocurre dentro de una sala va por WS: JOIN, VOTE, REVEAL, NEW_ROUND, CLOSE_ROOM
   - pros: separación clara de responsabilidades · el lifecycle es stateless (HTTP) · el protocolo in-room es stateful (WS) · facilita testing de cada capa por separado · el contrato REST es minimal y estable
   - contras: dos protocolos distintos que el cliente debe manejar · la creación de sala (HTTP) y la conexión WS son pasos separados que el cliente debe coordinar

2. **WebSocket puro desde el inicio**
   - La creación de sala también ocurre por WS — primer mensaje `CREATE_ROOM` devuelve el roomId
   - pros: un solo protocolo · sin coordinación entre HTTP y WS en el cliente
   - contras: la URL de la sala no puede ser compartida antes de conectarse por WS · el lifecycle (crear, verificar) no es RESTful — dificulta integraciones futuras · el contrato API es más difícil de documentar y versionar · testing más complejo (todo requiere un WS client)

3. **REST puro con polling**
   - Todas las operaciones via HTTP · el cliente hace polling para ver actualizaciones
   - pros: un solo protocolo · sin conexiones persistentes
   - contras: viola RNF-01 (<500ms latencia) — ya descartado en ADR-001

## Decisión tomada

**Arquitectura híbrida REST + WebSocket** porque el lifecycle de sala es inherentemente request/response (HTTP es el protocolo correcto), y el protocolo in-room es inherentemente bidireccional y en tiempo real (WebSocket es el protocolo correcto). Cada protocolo se usa donde es natural.

## Consecuencias

### Positivas
- El contrato REST es minimal (2 endpoints) y estable — fácil de documentar en `api-contract.md`
- La sala se puede crear y compartir la URL antes de que el Scrum Master conecte el WS
- Testing separado: las rutas REST se testean con `supertest`; el protocolo WS con un `ws` client en tests de integración
- La arquitectura refleja claramente los dos modos de interacción del sistema

### Negativas / trade-offs aceptados
- El cliente debe coordinar dos pasos al cargar la sala: verificar existencia via `GET /api/rooms/:id` y luego conectar el WS
- Dos superficies de protocolo distintas para documentar en el contrato API
- Un error en cualquiera de los dos pasos (404 en REST o fallo en WS handshake) requiere handling separado en el cliente

## Requiere PoC antes de implementar

☐ No · el patrón híbrido REST + WS es standard para aplicaciones de colaboración en tiempo real · la separación de responsabilidades está documentada en la sección 4.2.2 del RFC

## Referencias

- RFC fuente: `docs/02-rfc/rfc.md` — sección 4.2.2 (API REST) y sección 4.2.3 (Protocolo WebSocket)
- Decisiones relacionadas: ADR-001 (elección de `ws` nativo), ADR-002 (estado en memoria)
- Pareja 5 usará este ADR como input para `/contract-define`
