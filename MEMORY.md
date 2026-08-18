# MEMORY.md — Memoria de sesión a sesión

> Este archivo lo lee Claude Code al inicio (`/inicio`) y lo actualiza al
> cierre (`/cierre`) de cada sesión. Es la continuidad entre una sesión y
> la siguiente. Lo permanente (stack, reglas, arquitectura) vive en
> `CLAUDE.md`, no aquí.

---

## Dónde nos quedamos

**Formulario:** operativo con la nueva publishable key (`sb_publishable_...`)
commiteada en `formulario/index.html`.

**Tablero:** operativo. Se resolvieron dos bugs en esta sesión:
1. `SUPABASE_SERVICE_KEY` en Vercel tenía la key 3 veces (SyntaxError) → corregido manualmente en Vercel.
2. Las nuevas `sb_secret_...` keys son rechazadas por Supabase cuando el request viene de un browser (detectado por user-agent) → se migró a patrón **proxy BFF**: `tablero/api/tablero.js` proxea las 4 vistas server-side; el HTML ya no lleva ninguna key.

**Filtros del tablero:** ahora aplican a todas las secciones (Prospectos,
Precios, Marcas, Valor de mercado). Antes solo filtraban Prospectos porque
las otras 3 venían pre-agregadas de vistas SQL. Ahora se calculan en JS
a partir de `v_prospectos`, que tiene granularidad individual.

**KPIs de cabecera** (Visitas totales, AA+A, Toneladas, Plazas): muestran
totales generales SIN filtrar — comportamiento intencional acordado con César.

**Legacy keys:** aún activas en Supabase. Pendiente desactivarlas.

## Próximo paso

1. Desactivar las **legacy keys** en Supabase Settings → API (JWT secret
   legacy / anon + service_role JWT) una vez confirmado que todo funciona
   con las nuevas publishable/secret keys.
2. Borrar registros de prueba de la tabla `visitas` (ver SQL en Pendientes).
3. Prueba de punta a punta con usuario real: formulario → Supabase → tablero.
4. Checklist completo de campo (modo avión, GPS negado, etc.).

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

## Pendientes activos

- 🟠 **Borrar registros de prueba** — correr en Supabase SQL editor:
  ```sql
  DELETE FROM visitas
  WHERE id IN ('curl-test-1','curl-test-rotacion','curl-test-pub',
               'VMSHT64IA','VMSHT8CKT');
  ```
  Los últimos 2 son de "Fortunato Arce Cantú" — visitas de prueba del
  hoy (2026-08-06), no corresponden a vendedor real del proyecto.
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

---

## Prompt sugerido para la próxima sesión

```
/inicio

Después del reporte: desactivar las legacy keys en Supabase,
borrar registros de prueba, y correr la prueba de punta a punta.
```
