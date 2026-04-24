# ADR-005 · Recuperación del rol Scrum Master tras desconexión

**Status:** Proposed
**Date:** 2026-04-24
**Deciders:** Pareja 3 (autores RFC) · Pareja 4 (ADRs)

## Contexto

El Scrum Master tiene permisos exclusivos sobre operaciones críticas: REVEAL, NEW_ROUND y CLOSE_ROOM. Si el SM se desconecta durante una sesión activa, la sala queda en un estado bloqueado donde nadie puede avanzar la ronda. El RFC identifica este escenario como Riesgo #2 (severidad Alta) pero no define el protocolo exacto de recuperación — es la única decisión del RFC marcada como incierta.

## Decisión considerada

Opciones evaluadas:

1. **Re-unión por nombre**: el SM se reconecta y si su nombre coincide con el `scrumMasterName` registrado, recupera el rol
   - pros: simple · sin token adicional · UX natural ("volvé a entrar con el mismo nombre")
   - contras: cualquier participante puede suplantar al SM si conoce su nombre · no hay secreto compartido que garantice identidad

2. **Re-unión por token**: al crear la sala, el servidor emite un `smToken` (UUID) que el SM guarda en `sessionStorage` · al reconectarse, envía el token para recuperar el rol
   - pros: identidad verificable sin login · el token solo vive en el browser del SM original
   - contras: si el SM cambia de browser o dispositivo, pierde el token · requiere manejo de `sessionStorage` en el cliente · agrega superficie al protocolo WS (`JOIN` necesita campo `smToken` opcional)

3. **Transferencia de rol manual**: un participante puede reclamar el rol de SM si la sala lleva >5 min sin SM conectado, con confirmación de la mayoría de participantes
   - pros: robusto ante pérdida de token y cambio de dispositivo · democrático
   - contras: protocolo complejo de coordinar en WS · requiere estado adicional en `RoomState` · over-engineering para el MVP

4. **Sin recuperación en MVP**: si el SM se desconecta, la sala queda bloqueada hasta expirar (máx 24h)
   - pros: implementación mínima · sin complejidad adicional
   - contras: Riesgo Alta según el RFC · una caída de red del SM destruye la sesión para todos

## Decisión tomada

**Sin definir en este ADR — requiere PoC antes de comprometer.** Las opciones 1 y 2 son las candidatas. La opción 1 es simple pero tiene implicaciones de seguridad. La opción 2 es más segura pero agrega superficie al protocolo. Ninguna de las dos está suficientemente validada para el scope del taller.

**Decisión provisional para MVP:** implementar opción 1 (re-unión por nombre) con la advertencia explícita de que no es segura para producción, y documentar opción 2 como el camino a V2.

## Consecuencias

### Positivas (opción 1 provisional)
- Sin cambios al modelo de `RoomState` — el `scrumMasterId` se reasigna al nuevo `participantId` del SM al reconectarse
- UX simple: "si te desconectás, volvé a entrar con el mismo nombre"
- Sin complejidad adicional en el cliente

### Negativas / trade-offs aceptados
- La recuperación por nombre es suplantable — cualquier participante que conozca el nombre del SM puede tomar el rol
- **Aceptable para el MVP del taller** (sin usuarios reales, sin datos sensibles)
- Para producción real, esta decisión debe revisarse con opción 2 (token) o 3 (transferencia con consenso)

## Requiere PoC antes de implementar

☑ **Sí** · criterio de éxito: implementar ambas opciones (nombre y token) como branches separados · medir complejidad de código adicional y UX de recuperación · decidir cuál entra en el MVP con el equipo · estimado: 2-3 horas

## Referencias

- RFC fuente: `docs/02-rfc/rfc.md` — sección 8, Riesgo #2
- Decisiones relacionadas: ADR-001 (protocolo WS — el `JOIN` es el punto de entrada para la recuperación), ADR-004 (arquitectura híbrida — la identificación del SM toca tanto REST como WS)
- PRD negocio: `docs/01-prd/prd.md` — el PRD no define el comportamiento de recuperación de SM
