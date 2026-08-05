# MEMORY.md — Memoria de sesión a sesión

> Este archivo lo lee Claude Code al inicio (`/inicio`) y lo actualiza al
> cierre (`/cierre`) de cada sesión. Es la continuidad entre una sesión y
> la siguiente. Lo permanente (stack, reglas, arquitectura) vive en
> `CLAUDE.md`, no aquí.

---

## Dónde nos quedamos

Formulario y tablero desplegados en producción (Vercel, 2 proyectos).
Supabase con esquema y RLS corridos. Se encontró y corrigió un bug
bloqueante: `SB_URL` en `formulario/index.html` tenía `/rest/v1/` incluido
dos veces, causando 404 silencioso en toda sincronización.

## Próximo paso

Ejecutar la prueba de punta a punta: llenar una visita de prueba desde el
celular → confirmar que llega a la tabla `visitas` en Supabase → confirmar
que aparece en el tablero. Después, correr el checklist completo del
brief original (modo avión, folios duplicados, permisos de GPS negados).

## Decisiones recientes

- (2026-08-05) Se limpiaron del proyecto archivos de otro sistema
  (`DEUDA_TECNICA.md`, `MEMORY.md` viejo, `index.html`, `tablero.js`,
  `vercel.json` de un CRM de pedidos no relacionado). Confirmado por César
  que fue un cruce accidental de carpetas — ese sistema se lleva aparte.

## Pendientes activos

- 🟠 Prueba de punta a punta sin ejecutar todavía.
- 🟡 Checklist completo de pruebas de campo (brief original) sin correr.

## Commits relevantes

> El historial completo está en `git log`. Esta sección solo referencia
> los commits que marcan hitos, para que `/cierre` tenga base de
> comparación.

- `7c38906` — commit inicial: formulario + tablero + SQL.
- *(agregar aquí el hash del fix de `SB_URL` cuando se confirme el commit)*

---

## Prompt sugerido para la próxima sesión

```
/inicio

Después del reporte, vamos a correr la prueba de punta a punta
(formulario → Supabase → tablero) y luego el checklist de campo.
```
