# ADR-003 · Frontend vanilla TypeScript + Tailwind sin framework SPA

**Status:** Proposed
**Date:** 2026-04-24
**Deciders:** Pareja 3 (autores RFC) · Pareja 4 (ADRs)

## Contexto

El frontend tiene tres páginas: landing (crear sala), sala de estimación (la app principal), y un redirect de join. La sala de estimación requiere actualizaciones de UI en respuesta a eventos WebSocket en tiempo real. La elección del approach de frontend define la complejidad del tooling, el modelo mental para manejar estado reactivo y la curva de aprendizaje del equipo.

## Decisión considerada

Opciones evaluadas:

1. **Vanilla TypeScript compilado con `tsc` + Tailwind CSS via CDN** · sin bundler · sin framework · DOM manipulation directa
   - pros: sin setup de bundler (Vite, Webpack, etc.) · compilación directa con `tsc` · alineado con CLAUDE.md default · el scope de UI no justifica un framework · máxima simplicidad operacional
   - contras: actualizaciones del DOM son manuales — cada evento WS requiere seleccionar y actualizar nodos · sin gestión de estado reactivo incorporada · no escala bien si la UI crece en complejidad (V2 blocker)

2. **React + Vite** · framework SPA con gestión de estado reactivo
   - pros: actualizaciones de UI reactivas via estado · ecosistema maduro · fácil de testear componentes
   - contras: requiere setup de Vite y configuración de bundler · el PRD no requiere complejidad de SPA · el scope del MVP es 3 páginas simples · sobre-ingeniería para el ejercicio del taller

3. **Svelte** · framework compilado con reactividad declarativa · bundle pequeño
   - pros: reactividad más simple que React · bundle pequeño · buena DX
   - contras: menos conocido en el equipo · setup adicional de compilación · mismo over-engineering que React para este scope

## Decisión tomada

**Vanilla TypeScript + Tailwind CDN** porque el scope del MVP es 3 páginas con DOM manipulation directa, el CLAUDE.md del proyecto lo define como default, y la complejidad de un framework no se justifica para el taller.

## Consecuencias

### Positivas
- Sin configuración de bundler — `tsc` compila directamente a JS que el browser consume
- Tailwind via CDN elimina el paso de build del CSS para el ejercicio
- El código del cliente es explícito y directo — sin abstracciones de framework
- Menor superficie de dependencias en `package.json`

### Negativas / trade-offs aceptados
- Las actualizaciones del DOM en `room.ts` son imperativas — cada evento WS requiere seleccionar y mutar nodos manualmente
- Sin gestión de estado reactivo — el estado de la UI se infiere de los eventos WS entrantes, no de un store
- Si la UI crece (V2: múltiples historias, analytics, integraciones), migrar a un framework requiere reescribir `room.ts`
- Tailwind via CDN no es óptimo para producción (descarga el CSS completo) — aceptable para demo en taller

## Requiere PoC antes de implementar

☐ No · el approach está validado por el CLAUDE.md del proyecto y la sección 4.2.7 del RFC · la complejidad de la UI del MVP es manejable con DOM manipulation directa

## Referencias

- RFC fuente: `docs/02-rfc/rfc.md` — sección 4.2.7 (Frontend) y sección 4.3 (stack)
- CLAUDE.md del proyecto — "Frontend · vanilla TS + Tailwind (si aplica)"
- Decisiones relacionadas: ADR-001 (WebSockets — el cliente WS vive en `room.ts`)
