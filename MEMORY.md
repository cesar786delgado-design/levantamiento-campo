# MEMORY.md — Memoria de sesión a sesión

> Este archivo lo lee Claude Code al inicio (`/inicio`) y lo actualiza al
> cierre (`/cierre`) de cada sesión. Es la continuidad entre una sesión y
> la siguiente. Lo permanente (stack, reglas, arquitectura) vive en
> `CLAUDE.md`, no aquí.

---

## Dónde nos quedamos

**Legacy keys:** desactivadas en Supabase (2026-08-18). Confirmado con curl
— responden `401 UNAUTHORIZED_DISABLED_LEGACY_KEY`. Formulario y tablero
corren exclusivamente con publishable/secret keys.

**Soft delete implementado:**
- Columna `activo boolean NOT NULL DEFAULT true` agregada a `visitas`.
- Vistas `v_prospectos`, `v_precios` y `v_marcas` actualizadas con
  `WHERE activo = true`; `v_valor` hereda el filtro transitivamente.
- Tablero: botón "Ocultar" por fila en la tabla de prospectos. Llama a
  `POST /?accion=ocultar` en el BFF, que hace PATCH a Supabase server-side.
- `01_supabase_setup.sql` sincronizado con el esquema real.

**Estado:** todo commiteado y pusheado a `origin/main` (`e777bed`).
Deploy de Vercel verificado (2026-08-19) — botón "Ocultar" visible y operativo.

## Próximo paso

1. Prueba de punta a punta con usuario real: formulario → Supabase → tablero.
2. Checklist completo de campo (modo avión, GPS negado, etc.).

## Decisiones recientes

- (2026-08-05) Se limpiaron del proyecto archivos de otro sistema
  (`DEUDA_TECNICA.md`, `MEMORY.md` viejo, `index.html`, `tablero.js`,
  `vercel.json` de un CRM de pedidos no relacionado). Confirmado por César
  que fue un cruce accidental de carpetas — ese sistema se lleva aparte.
- (2026-08-06) Migración a nuevo sistema de API keys de Supabase
  (publishable + secret) en vez de rotar el JWT secret legacy.
- (2026-08-06) Patrón proxy BFF en tablero: secret key nunca sale al browser.
- (2026-08-06) Filtros del tablero ahora aplican a todas las secciones;
  KPIs de cabecera muestran totales generales sin filtrar (intencional).
- (2026-08-18) Soft delete via columna `activo` — registros ocultos
  permanecen en la tabla base y pueden reactivarse con un UPDATE manual.
- (2026-08-18) Endpoint de escritura en el BFF (`POST /?accion=ocultar`)
  protegido por Basic Auth; CSRF documentada como deuda técnica baja.

## Pendientes activos

- 🟠 Prueba de punta a punta con usuario real sin ejecutar todavía.
- 🟡 Checklist completo de pruebas de campo (brief original) sin correr.
- 🟡 **Deuda técnica — sincronizar() en batch:** Un 409 marca toda la cola
  como sincronizada aunque solo una visita sea el duplicado, arriesgando
  pérdida silenciosa de las demás. Fix futuro: sincronizar registro por
  registro, o reintentar individualmente ante un 409 en batch. No urgente
  mientras la cola sea pequeña.
- 🟡 **Deuda técnica — CSRF en endpoint ocultar:** El endpoint
  `POST /?accion=ocultar` no tiene protección CSRF — Basic Auth no la incluye
  nativamente. Riesgo bajo (requiere condiciones específicas, daño reversible),
  pero si en el futuro se agregan más acciones de escritura al tablero, vale la
  pena migrar a un login con cookie + token CSRF.

## Deudas resueltas

- ✅ **(2026-08-18) Legacy JWT keys desactivadas** — Legacy JWT keys (anon/service_role)
  desactivadas en Supabase (Settings → API). Confirmado con curl que ahora responden
  `401 UNAUTHORIZED_DISABLED_LEGACY_KEY`. Cierra el incidente de la service_role key
  filtrada durante la sesión anterior. Formulario y tablero corren con
  publishable/secret keys exclusivamente.

## Commits relevantes

> El historial completo está en `git log`. Esta sección solo referencia
> los commits que marcan hitos, para que `/cierre` tenga base de
> comparación.

- `7c38906` — commit inicial: formulario + tablero + SQL.
- `0096082` — fix SB_URL: quitado `/rest/v1/` de la constante para evitar path doble.
- `52abeb8` — fix 401: quitado `Prefer: resolution=merge-duplicates` (requería UPDATE en RLS para anon); 409 tratado como éxito.
- `985274b` — migración a publishable key en formulario (legacy anon JWT reemplazada).
- `7d1ea00` — proxy BFF en tablero: secret key nunca va al browser; sbGet usa `/?vista=`.
- `bf022f5` — filtros aplican a todas las secciones; precios/marcas/valor calculados en JS desde v_prospectos.
- `ebc7aac` — cierre de sesión anterior (actualización MEMORY.md).
- `e777bed` — soft delete: columna activo en visitas, vistas filtradas, botón Ocultar en tablero.

---

## Prompt sugerido para la próxima sesión

```
/inicio

Después del reporte: verificar deploy de Vercel (botón Ocultar visible)
y correr la prueba de punta a punta.
```
