# RFC - Planning Poker: sala temporal con votación en tiempo real vía WebSockets

- **Estado:** BORRADOR
- **Fecha de creación:** 2026-04-24
- **Canal de comunicación:** [Taller SDD · Slack]
- **Referentes:** Sergio (PRD Owner) · Javier (PRD Navigator)

### Revisores y autores

| Nombre | Rol | Estado | Fecha de Revisión |
|--------|-----|--------|-------------------|
| Pareja 3 | Autores | N/A | - |
| Pareja 4 (ADRs) | Aprobador | Pendiente | - |
| Pareja 5 (Contrato) | Aprobador | Pendiente | - |

---

## 1. Contexto y problema

### Estado actual

No existe codebase previo. Los equipos ágiles utilizan herramientas dispares para la estimación: PlanningPokerOnline.com para la votación, Jira para gestionar el backlog, y una herramienta de videollamada por separado. No hay integración entre ellas.

El flujo actual de un Scrum Master es:
1. Abrir 3-4 tabs por separado (Jira, herramienta de poker, videollamada, Slack)
2. Copiar manualmente el ID y título de cada historia desde Jira a la sala de estimación
3. Al terminar, actualizar story points en Jira manualmente, historia por historia
4. Cuando alguien se desconecta o llega tarde, re-explicar el contexto de la historia en curso

### Problema a resolver

**El overhead manual consume 15-25 minutos por sesión de estimación.** Los equipos hacen refinement/planning 1-2 veces por semana con 5-15 historias por sesión. El impacto acumulado es alto: errores de sincronización (stories con puntos incorrectos en Jira), fatiga del facilitador, y pérdida de tiempo que podría dedicarse a la discusión técnica real.

El principal dolor es la ausencia de una herramienta enfocada exclusivamente en la mecánica de Planning Poker — sin fricciones de login, sin configuración, sin dependencias de integración para el MVP.

### Por qué ahora

Este RFC es el siguiente paso del pipeline SDD en el taller de aprendizaje. El PRD (Pareja 2) definió el qué y el por qué. Este RFC define el cómo técnico para que las Parejas 4-8 puedan continuar con ADRs, contrato API, historias INVEST, planes y código.

---

## 2. Impacto y métricas de éxito

### Impacto esperado

- Los Scrum Masters podrán crear una sala de estimación en menos de 30 segundos, sin cuenta, con un link compartible listo para enviar por Slack
- Los equipos verán todos los votos revelados simultáneamente, eliminando el sesgo de ancla que ocurre cuando los votos se muestran de a uno
- El overhead de la sesión de estimación se reduce de 15-25 min a menos de 5 min

### KPIs

| Métrica | Valor Actual | Target | Cómo se mide |
|---------|-------------|--------|---------------|
| Overhead de sesión | 15-25 min/sesión | < 5 min/sesión | Cronometraje en sesiones piloto |
| Tiempo de creación de sala | N/A | < 30 segundos | Performance tracking (Date.now()) |
| Latencia de reveal de votos | N/A | < 500 ms | WebSocket message roundtrip |
| Participantes concurrentes por sala | N/A | 15+ sin degradación | Load test con k6 o Artillery |
| Salas concurrentes soportadas | N/A | 100+ | Test de carga a nivel de servidor |

---

## 3. Objetivos y requerimientos

### Objetivos

1. Implementar creación instantánea de salas temporales con URL única y no adivinable
2. Implementar votación en tiempo real con WebSockets nativos (`ws`) y reveal simultáneo controlado por el Scrum Master
3. Soportar participantes sin registro — acceso solo con nombre de display
4. Implementar expiración automática de salas a las 24h y cierre manual
5. Soportar el flujo completo: crear → compartir → votar → revelar → re-votar (máx 2) → resultado final

### Requerimientos funcionales

| ID | Requerimiento |
|----|---------------|
| RF-01 | El Scrum Master puede crear una sala con un click y recibir una URL única (ej. `/room/abc123`) |
| RF-02 | Cualquier persona con la URL puede unirse ingresando solo su nombre de display |
| RF-03 | El sistema soporta escala Fibonacci: 1, 2, 3, 5, 8, 13, 21, ? |
| RF-04 | Los votos están ocultos para todos hasta que el Scrum Master dispara el reveal |
| RF-05 | Al revelar, todos los votos aparecen simultáneamente en pantalla |
| RF-06 | El sistema detecta consenso (todos votan igual) y dispersión (varianza alta) |
| RF-07 | El Scrum Master puede iniciar re-votación; máximo 2 re-votos por historia |
| RF-08 | Los participantes que se unen tarde ven el estado actual de la sala (historia en curso, si la ronda está abierta) |
| RF-09 | Un participante tardío puede votar si la ronda está abierta; no puede ver votos antes de haber votado |
| RF-10 | Las salas expiran automáticamente a las 24h de creación o cuando el Scrum Master las cierra manualmente |
| RF-11 | Las URLs de sala son únicas y no predecibles (no secuenciales) |

### Requerimientos no funcionales

| ID | Requerimiento |
|----|---------------|
| RNF-01 | Latencia de actualización en tiempo real < 500 ms (WebSocket message delivery) |
| RNF-02 | Creación y join de sala < 3 segundos (incluye carga de página) |
| RNF-03 | Soporte para 15+ participantes simultáneos por sala sin degradación |
| RNF-04 | Soporte para 100+ salas concurrentes en el servidor |
| RNF-05 | El servidor maneja desconexiones y reconexiones de participantes sin perder el estado de la ronda actual |
| RNF-06 | No se persisten datos personales — el almacenamiento es en memoria (TTL 24h) |
| RNF-07 | Las URLs de sala usan IDs generados con `crypto.randomUUID()` o similar (no secuenciales) |

### Fuera de alcance

- Integración con Jira, Linear o cualquier sistema externo (V2)
- Autenticación de usuarios y cuentas persistentes (V2)
- Historial de sesiones y analytics (V2)
- Escalas de votación personalizadas (V2)
- Estimación de múltiples historias en batch con importación (V2)
- Deploy en producción con dominio propio (ejercicio de taller)
- Persistencia en base de datos (el estado vive en memoria del servidor)

---

## 4. Propuesta de solución

### 4.1 Arquitectura de alto nivel

```
┌─────────────────────────────────────────────────────────────┐
│  Cliente (Navegador)                                         │
│  ┌──────────────────┐    ┌───────────────────────────────┐  │
│  │  Página Inicio   │    │  Sala de Estimación           │  │
│  │  (crear sala)    │    │  (votar · ver reveal)         │  │
│  └────────┬─────────┘    └──────────────┬────────────────┘  │
│           │ HTTP POST /rooms            │ WebSocket          │
└───────────┼─────────────────────────────┼────────────────────┘
            │                             │
┌───────────▼─────────────────────────────▼────────────────────┐
│  Servidor Node.js / Express / TypeScript                      │
│  ┌────────────────┐   ┌──────────────────────────────────┐   │
│  │  REST Routes   │   │  WebSocket Server (ws)           │   │
│  │  POST /rooms   │   │  Gestión de salas en memoria     │   │
│  │  GET  /rooms/:id│  │  Broadcast de eventos            │   │
│  └────────────────┘   └──────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  RoomStore (Map<roomId, RoomState>) · en memoria        │ │
│  │  TTL automático via setTimeout (24h)                    │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

**No hay base de datos.** El estado de todas las salas vive en un `Map` en memoria del proceso Node.js. Esto es intencional para el MVP: sin infra, sin migraciones, sin latencia de I/O de DB. La consecuencia es que un restart del servidor destruye todas las salas activas — aceptable para un ejercicio y sesiones efímeras.

### 4.2 Diseño detallado

#### 4.2.1 Modelo de estado en memoria

```typescript
// Tipos centrales — definen el contrato interno del servidor

type CardValue = 1 | 2 | 3 | 5 | 8 | 13 | 21 | '?';

interface Participant {
  id: string;           // UUID generado al conectar por WS
  name: string;         // Nombre ingresado por el usuario
  vote: CardValue | null; // null = no votó aún
  connected: boolean;
}

interface Round {
  roundNumber: number;
  status: 'voting' | 'revealed';
  votes: Record<string, CardValue | null>; // participantId → vote
}

interface RoomState {
  roomId: string;           // UUID v4
  createdAt: Date;
  expiresAt: Date;          // createdAt + 24h
  scrum Master Id: string;  // participantId del creador
  participants: Map<string, Participant>;
  currentRound: Round;
  roundHistory: Round[];
  revoteCount: number;      // 0, 1 o 2 (máx 2 re-votos)
}

// Singleton en el proceso
const rooms = new Map<string, RoomState>();
```

#### 4.2.2 API REST

Solo dos endpoints REST — el resto del protocolo ocurre por WebSocket:

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/api/rooms` | Crea una sala nueva. Devuelve `{ roomId, url }` |
| `GET` | `/api/rooms/:roomId` | Verifica que la sala existe y no expiró. Devuelve metadata básica. |

`POST /api/rooms` response:
```json
{
  "roomId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "url": "/room/f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "expiresAt": "2026-04-25T14:30:00.000Z"
}
```

#### 4.2.3 Protocolo WebSocket — Eventos

El cliente se conecta a `ws://host/room/:roomId`. Una vez conectado, toda la comunicación es mensajes JSON con el esquema:

```typescript
interface WSMessage {
  type: string;
  payload: unknown;
}
```

**Eventos: Cliente → Servidor**

| Tipo | Payload | Descripción |
|------|---------|-------------|
| `JOIN` | `{ name: string }` | Participante se une o re-une a la sala |
| `VOTE` | `{ vote: CardValue }` | Emite un voto (ronda debe estar en `voting`) |
| `REVEAL` | `{}` | Solo Scrum Master — revela todos los votos |
| `NEW_ROUND` | `{}` | Solo Scrum Master — inicia re-voto (máx 2) |
| `CLOSE_ROOM` | `{}` | Solo Scrum Master — cierra la sala manualmente |

**Eventos: Servidor → Cliente(s)**

| Tipo | Destinatario | Payload | Descripción |
|------|-------------|---------|-------------|
| `ROOM_STATE` | 1 cliente (join) | `RoomStateDTO` | Estado completo de la sala al conectarse |
| `PARTICIPANT_JOINED` | Broadcast | `{ participantId, name }` | Alguien se unió |
| `PARTICIPANT_LEFT` | Broadcast | `{ participantId }` | Alguien se desconectó |
| `VOTE_CAST` | Broadcast | `{ participantId, hasVoted: true }` | Alguien votó (SIN revelar el valor) |
| `VOTES_REVEALED` | Broadcast | `{ votes: Record<string, CardValue> }` | Reveal simultáneo de todos los votos |
| `NEW_ROUND_STARTED` | Broadcast | `{ roundNumber, revoteCount }` | Ronda reiniciada |
| `ROOM_CLOSED` | Broadcast | `{}` | Sala cerrada — clientes deben redirigir a home |
| `ERROR` | 1 cliente | `{ code, message }` | Error en la acción (ej. no es SM, ronda no abierta) |

**Nota crítica sobre privacidad de votos:** `VOTE_CAST` solo informa que el participante votó, nunca el valor. El valor solo viaja en `VOTES_REVEALED`. Un cliente malicioso que intercepte los mensajes WS solo verá `hasVoted: true` hasta el reveal.

#### 4.2.4 Flujo de secuencia: sesión completa

```
SM Browser          Server              Participant Browser
    │                  │                       │
    │─── POST /api/rooms ──▶│                  │
    │◀── { roomId, url } ───│                  │
    │                  │                       │
    │─── WS CONNECT ───▶│                      │
    │─── JOIN(name) ────▶│                     │
    │◀── ROOM_STATE ────│                      │
    │                  │                       │
    │                  │◀─── WS CONNECT ───────│
    │                  │◀─── JOIN(name) ────────│
    │                  │─── ROOM_STATE ────────▶│
    │◀── PARTICIPANT_JOINED ─│                  │
    │                  │                       │
    │─── VOTE(5) ───────▶│                     │
    │                  │─── VOTE_CAST ─────────▶│
    │                  │◀─── VOTE(8) ───────────│
    │◀── VOTE_CAST ─────│                      │
    │                  │                       │
    │─── REVEAL() ──────▶│                     │
    │◀── VOTES_REVEALED(SM=5, P=8) ─│──────────▶│
    │                  │                       │
    │─── NEW_ROUND() ───▶│                     │
    │◀── NEW_ROUND_STARTED ─│──────────────────▶│
    │                  │                       │
```

#### 4.2.5 Detección de consenso (server-side)

Al hacer `REVEAL`, el servidor calcula:

```typescript
function detectConsensus(votes: Record<string, CardValue>): ConsensusResult {
  const values = Object.values(votes).filter(v => v !== '?');
  const unique = new Set(values);
  
  return {
    hasConsensus: unique.size === 1,
    average: values.length > 0 
      ? values.reduce((a, b) => a + Number(b), 0) / values.length 
      : null,
    suggestion: nearestFibonacci(average)  // para la UI
  };
}
```

Este resultado se incluye en el payload de `VOTES_REVEALED`.

#### 4.2.6 Expiración de salas

Al crear una sala, se registra un `setTimeout` de 24h:

```typescript
function createRoom(): RoomState {
  const room = buildInitialState();
  rooms.set(room.roomId, room);
  
  setTimeout(() => {
    const r = rooms.get(room.roomId);
    if (r) {
      broadcastToRoom(room.roomId, { type: 'ROOM_CLOSED', payload: {} });
      closeAllConnections(room.roomId);
      rooms.delete(room.roomId);
    }
  }, 24 * 60 * 60 * 1000);
  
  return room;
}
```

#### 4.2.7 Frontend: vanilla TypeScript + Tailwind

Tres páginas estáticas servidas por Express:

| Ruta | Archivo | Descripción |
|------|---------|-------------|
| `/` | `index.html` | Landing con botón "Crear sala" |
| `/room/:roomId` | `room.html` | Sala de estimación — la app principal |
| `/join/:roomId` | (redirect a room) | URL alternativa para participantes |

El JS del cliente es vanilla TypeScript compilado con `tsc` (sin bundler para simplificar). La lógica WebSocket vive en `room.ts`:
- Conectar al WS al cargar la página
- Enviar `JOIN` con el nombre (guardado en `sessionStorage`)
- Actualizar el DOM en respuesta a cada evento del servidor

No se usa ningún framework de frontend — el PRD no lo requiere y el CLAUDE.md especifica vanilla TS + Tailwind como default.

### 4.3 Stack tecnológico

| Componente | Tecnología | Justificación |
|-----------|------------|---------------|
| Runtime | Node.js 20+ | LTS vigente · CLAUDE.md default |
| Framework HTTP | Express 4 | CLAUDE.md default · minimal overhead |
| Lenguaje | TypeScript 5 | Type safety · CLAUDE.md default |
| WebSockets | `ws` 8.x | Librería nativa sin abstracciones · decisión explícita del equipo |
| Generación de IDs | `crypto.randomUUID()` (Node built-in) | Sin dependencias externas · V4 UUID no predecible |
| Frontend | Vanilla TS + Tailwind CSS CDN | CLAUDE.md default · sin bundler para simplificar |
| Testing | vitest | CLAUDE.md default |
| Persistencia | Ninguna (estado en memoria) | Salas efímeras · sin infra · MVP |
| Servidor estático | Express `static` middleware | Sirve el HTML/JS compilado del frontend |

**No se usa SQLite** pese a estar en el stack default del CLAUDE.md — no hay datos que persistan entre sesiones. Esta decisión debe capturarse como ADR.

### 4.4 Modelo de datos (tipos TypeScript canónicos)

```typescript
// src/types/room.ts

export type CardValue = 1 | 2 | 3 | 5 | 8 | 13 | 21 | '?';

export type RoundStatus = 'voting' | 'revealed';

export interface Participant {
  id: string;
  name: string;
  vote: CardValue | null;
  connected: boolean;
  isScrum Master: boolean;
}

export interface Round {
  roundNumber: number;
  status: RoundStatus;
  revealedAt?: Date;
}

export interface ConsensusResult {
  hasConsensus: boolean;
  average: number | null;
  suggestion: CardValue | null;
  votes: Record<string, CardValue>;
}

export interface RoomState {
  roomId: string;
  createdAt: Date;
  expiresAt: Date;
  scrumMasterId: string;
  participants: Map<string, Participant>;
  currentRound: Round;
  roundHistory: ConsensusResult[];
  revoteCount: number;
}
```

### 4.5 Estructura de directorios propuesta

```
src/
├── server.ts              # Entry point · Express + WS server setup
├── types/
│   └── room.ts            # Tipos canónicos (ver 4.4)
├── store/
│   └── roomStore.ts       # Map<roomId, RoomState> + CRUD + TTL
├── routes/
│   └── rooms.ts           # POST /api/rooms · GET /api/rooms/:id
├── ws/
│   ├── handler.ts         # Dispatch de mensajes WS entrantes
│   └── broadcaster.ts     # Helpers para broadcast/unicast
├── logic/
│   ├── consensus.ts       # Detección de consenso + suggestion
│   └── roomLifecycle.ts   # createRoom · closeRoom · expireRoom
└── frontend/              # Servido estáticamente
    ├── index.html
    ├── room.html
    ├── index.ts           # JS para la landing
    └── room.ts            # Lógica WS del cliente
```

---

## 5. Alternativas consideradas

### Alternativa A: Socket.io en lugar de `ws` nativo

Socket.io ofrece reconexión automática, rooms/namespaces built-in, y fallback a long-polling.

**Descartada porque:** El equipo decidió explícitamente usar WebSockets nativos (`ws`) para tener control directo sobre el protocolo y evitar la abstracción. Para el scope del MVP (salas temporales, mensajes simples), la complejidad de socket.io no se justifica. La reconexión manual con `ws` es ~20 líneas de código.

### Alternativa B: Server-Sent Events (SSE) en lugar de WebSockets

SSE simplifica el modelo de comunicación: solo push del servidor, el cliente usa fetch para enviar eventos.

**Descartada porque:** El protocolo requiere comunicación bidireccional real (cliente envía votos, servidor envía reveals a todos). Con SSE, los votos tendrían que ir por HTTP POST separados, complicando el manejo de estado de conexión y la asociación cliente↔sala. WebSockets encapsula todo en una sola conexión.

### Alternativa C: Estado en SQLite en lugar de memoria

SQLite permitiría sobrevivir restarts del servidor y recuperar salas en curso.

**Descartada porque:** El PRD establece explícitamente "no persistent data storage (beyond session)" en los NFRs de seguridad. Las salas son efímeras por diseño. SQLite agregaría complejidad de esquema, migraciones y queries para cero beneficio en el MVP. Si en V2 se necesita historial, se puede agregar entonces.

### Alternativa D: Polling periódico (cada 1-2s) en lugar de WebSockets

Implementación más simple: el cliente hace GET al servidor cada segundo para obtener el estado.

**Descartada porque:** Viola el NFR de <500ms de latencia. Con polling de 1s, el P50 de latencia visible sería ~500ms y el P95 ~1000ms. También aumenta innecesariamente la carga del servidor: 100 salas × 15 participantes × 1 req/s = 1500 requests/s en estado idle. WebSockets tienen overhead de conexión inicial pero prácticamente cero en estado idle.

---

## 6. Plan de implementación

### Plan de sprints

| Sprint | Duración | Entregable |
|--------|----------|------------|
| 1 | 1 semana | Setup del proyecto (tsconfig, Express, ws server, tipos) + `POST /api/rooms` + `GET /api/rooms/:id` + lógica de store en memoria con TTL |
| 2 | 1 semana | Protocolo WebSocket completo: JOIN, VOTE, REVEAL, NEW_ROUND, CLOSE_ROOM + toda la lógica de broadcasting + detección de consenso |
| 3 | 1 semana | Frontend: landing (crear sala) + sala de estimación (votar, ver estado, reveal) + estilos Tailwind |
| 4 | 0.5 semana | Testing (unit + integration), load test básico, pulido de UX y manejo de edge cases (desconexión, reconexión, expiración) |

### Estimación

- **Equipo:** 1-2 ingenieros
- **Duración total:** 3.5 semanas
- **Dependencias externas:** Ninguna (greenfield, sin integraciones)

### Feature flags

No se implementan feature flags en el MVP — el scope es fijo y no hay rollout gradual en un ejercicio de taller.

### Plan de rollout

1. **Local dev:** `npm run dev` — servidor en `localhost:3000`
2. **Demo en taller:** servidor corriendo en la máquina del presentador, accesible en la red local

No hay plan de deploy en producción en el scope de este ejercicio.

### Plan de rollback

Al ser un ejercicio de taller sin deploy en producción, el "rollback" es volver al commit anterior con `git revert`. El estado de salas activas se pierde con cualquier restart — comportamiento esperado y documentado.

---

## 7. Testing y validación

### Estrategia de testing

| Tipo | Herramienta | Cuándo | Qué verifica |
|------|-------------|--------|--------------|
| Unit | vitest | Cada commit (pre-push hook) | Lógica de consenso · roomStore CRUD · lifecycle · generación de IDs únicos |
| Integration | vitest + `ws` client en test | PR merge | Flujo completo WS: JOIN → VOTE → REVEAL · manejo de desconexiones · expiración de sala |
| E2E manual | Navegador | Antes de demo | Flujo completo con 2+ tabs · late joiner · re-voto · cierre de sala |

### Tests unitarios clave (ejemplos)

```typescript
// consensus.test.ts
describe('detectConsensus', () => {
  it('detecta consenso cuando todos votan igual', ...)
  it('no hay consenso con votos dispersos', ...)
  it('sugiere el Fibonacci más cercano al promedio', ...)
  it('ignora votos "?" en el cálculo del promedio', ...)
})

// roomStore.test.ts
describe('roomStore', () => {
  it('crea sala con UUID v4 no secuencial', ...)
  it('elimina sala al expirar el TTL', ...)
  it('rechaza operaciones en sala expirada', ...)
  it('no permite más de 2 re-votos', ...)
})
```

### Tests de integración clave

```typescript
// room.integration.test.ts
describe('WebSocket room flow', () => {
  it('SM crea sala y se une, participante se une, ambos reciben PARTICIPANT_JOINED', ...)
  it('votos están ocultos hasta REVEAL', ...)
  it('REVEAL falla si lo intenta un no-SM', ...)
  it('participante tardío recibe ROOM_STATE con estado actual', ...)
  it('servidor maneja desconexión y notifica con PARTICIPANT_LEFT', ...)
})
```

### Criterios de aceptación (pre-demo)

- [ ] Sala creada en < 3 segundos (medido con `Date.now()`)
- [ ] Votos revelados en < 500 ms desde REVEAL (medido en los tests de integración)
- [ ] 15 clientes WS concurrentes en una sala sin errores (test de carga con Artillery o `Promise.all` de 15 conexiones)
- [ ] Sala expirada no acepta nuevas conexiones WS
- [ ] Un participante tardío que se une en mitad de una ronda abierta puede votar
- [ ] Un participante tardío no puede ver los votos de los demás antes de votar

---

## 8. Riesgos y mitigaciones

| # | Riesgo | Severidad | Mitigación |
|---|--------|-----------|------------|
| 1 | Estado en memoria se pierde con restart del servidor | Media | Documentado explícitamente como comportamiento esperado en el MVP. En V2, agregar persistencia opcional. |
| 2 | El Scrum Master se desconecta y nadie puede hacer REVEAL | Alta | Al reconectarse con el mismo nombre en la misma sala, recuperar el rol de SM. Si la sala queda sin SM conectado por > 5 min, cualquier participante puede tomar el rol con un comando especial. |
| 3 | Memory leak si se crean muchas salas y los `setTimeout` no se limpian correctamente | Media | Asegurar que `closeRoom` siempre cancela el timeout con `clearTimeout`. Test unitario que verifica que la sala se elimina del Map. |
| 4 | WebSocket connection handling bajo carga inesperada | Baja | El servidor Node.js single-thread puede ser un cuello de botella con 100+ salas × 15+ participantes. Mitigación: load test en Sprint 4; si hay problemas, ajustar el `maxPayload` de `ws` y agregar rate limiting en mensajes. |
| 5 | Sala con URL adivinable permite "espiar" sesiones | Media | URLs generadas con `crypto.randomUUID()` — 122 bits de entropía — prácticamente no adivinable. No hay listado público de salas. |
| 6 | Participante malicioso envía REVEAL o NEW_ROUND sin ser SM | Alta | Cada mensaje WS incluye validación de `isScrumMaster` antes de procesar. Test de integración explícito para este caso. |

---

## 9. Glosario

| Término | Definición |
|---------|-----------|
| Planning Poker | Técnica de estimación ágil donde los participantes votan simultáneamente con cartas para evitar el sesgo de ancla |
| Fibonacci (escala) | Secuencia 1, 2, 3, 5, 8, 13, 21 usada para story points — la distancia entre números refleja la incertidumbre creciente |
| Reveal | Acción de mostrar todos los votos simultáneamente, disparada por el Scrum Master |
| Scrum Master (SM) | Facilitador de la sesión — tiene permisos exclusivos para REVEAL, NEW_ROUND y CLOSE_ROOM |
| Re-voto | Ronda adicional de votación cuando no hay consenso — máximo 2 por historia |
| Sala temporal | Espacio de sesión con TTL de 24h, sin persistencia en base de datos |
| RoomState | Estructura de datos en memoria que representa el estado completo de una sala en un momento dado |
| Broadcast | Envío de un mensaje WS a todos los participantes conectados de una sala |
| Consenso | Estado donde todos los participantes votaron el mismo valor |
| Dispersión | Estado donde hay alta varianza en los votos — señal de que el equipo necesita discusión |
| JTBD | Jobs To Be Done — framework para definir el problema del usuario en términos de la tarea que busca completar |
| TTL | Time To Live — duración máxima de una sala (24h) tras la cual se elimina automáticamente |

---

**Document Owner:** Pareja 3  
**Upstream:** `docs/01-prd/prd.md` (Pareja 2)  
**Next Phase:** Pareja 4 → extraer ADRs con `/rfc-to-adr` · Pareja 5 → contrato API con `/contract-define`  
**Last Updated:** 2026-04-24
