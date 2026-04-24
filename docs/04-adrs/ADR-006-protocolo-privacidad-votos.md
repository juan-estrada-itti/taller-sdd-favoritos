# ADR-006 · Protocolo de privacidad de votos: VOTE_CAST sin valor hasta VOTES_REVEALED

**Status:** Proposed
**Date:** 2026-04-24
**Deciders:** Pareja 3 (autores RFC) · Pareja 4 (ADRs)

## Contexto

Planning Poker existe específicamente para eliminar el sesgo de ancla: si los participantes ven los votos de los demás antes de votar, su estimación se ve influenciada. Esto destruye el valor de la técnica. El diseño del protocolo WS debe garantizar que ningún participante pueda conocer el voto de otro antes del reveal, incluso interceptando los mensajes del WebSocket.

## Decisión considerada

Opciones evaluadas:

1. **`VOTE_CAST` sin valor + `VOTES_REVEALED` con todos los valores** (diseño actual del RFC)
   - El servidor recibe el voto, almacena el valor internamente, y solo emite `{ participantId, hasVoted: true }` al broadcast
   - El valor solo viaja en `VOTES_REVEALED` disparado por el SM
   - pros: un cliente malicioso que intercepte mensajes WS solo ve `hasVoted: true` · el servidor es el guardián único del valor hasta el reveal · alineado con el propósito de Planning Poker
   - contras: el servidor debe validar que el reveal solo ocurre cuando todos votaron (o el SM lo fuerza) · estado adicional en `RoundState` para distinguir "votó" de "valor del voto"

2. **`VOTE_CAST` con valor encriptado + reveal de clave**
   - El cliente encripta el voto antes de enviarlo · al reveal, el SM publica la clave de desencriptado
   - pros: incluso el servidor no conoce el valor hasta el reveal (privacidad end-to-end)
   - contras: complejidad criptográfica injustificada para el scope · el servidor necesita coordinar la distribución de claves · over-engineering para un ejercicio de taller

3. **Votos visibles en tiempo real** · el servidor emite el valor de cada voto al recibirlo
   - pros: implementación trivial · sin estado adicional
   - contras: destruye el propósito de Planning Poker — introduce sesgo de ancla · incompatible con RF-04 ("los votos están ocultos hasta que el SM dispara el reveal")

## Decisión tomada

**`VOTE_CAST` sin valor + `VOTES_REVEALED` con todos los valores** porque garantiza que ningún cliente — incluyendo uno malicioso que intercepte el tráfico WS — pueda conocer votos ajenos antes del reveal. El servidor es el único punto de verdad hasta que el SM dispara `REVEAL`.

## Consecuencias

### Positivas
- Privacidad de votos garantizada a nivel de protocolo — no requiere confianza en el cliente
- El propósito de Planning Poker (eliminar sesgo de ancla) se cumple por diseño, no por convención
- El estado de la ronda distingue claramente `voting` (votos ocultos) y `revealed` (votos públicos)
- Un participante tardío que se une y pide el estado de la sala recibe `hasVoted: true/false` por participante, nunca valores

### Negativas / trade-offs aceptados
- El `RoundState` en el servidor necesita separar la visibilidad del voto de su existencia — no es un campo `vote: CardValue | null`, sino `hasVoted: boolean` para el estado público y `vote: CardValue | null` para el estado interno
- El test de integración "votos están ocultos hasta REVEAL" debe verificar explícitamente que el payload de `VOTE_CAST` no contiene el valor (ver RFC sección 7)
- El reveal parcial (SM revela antes de que todos voten) debe estar documentado en el protocolo — el RFC permite que el SM fuerce el reveal aunque no todos hayan votado

## Requiere PoC antes de implementar

☐ No · el diseño del protocolo está completamente especificado en el RFC sección 4.2.3 · no hay incertidumbre técnica · el test de integración "votos están ocultos hasta REVEAL" es el criterio de aceptación

## Referencias

- RFC fuente: `docs/02-rfc/rfc.md` — sección 4.2.3 (Protocolo WebSocket, nota crítica sobre privacidad de votos)
- RF-04: "Los votos están ocultos para todos hasta que el SM dispara el reveal"
- RF-05: "Al revelar, todos los votos aparecen simultáneamente en pantalla"
- RF-09: "Un participante tardío no puede ver votos antes de haber votado"
- Test de integración: `it('votos están ocultos hasta REVEAL', ...)` — RFC sección 7
- Decisiones relacionadas: ADR-001 (protocolo WS), ADR-005 (identidad del SM — el reveal requiere validar que es el SM)
