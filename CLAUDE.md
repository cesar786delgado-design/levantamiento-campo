# CLAUDE.md — Contexto persistente del proyecto

> Este archivo se carga automáticamente al inicio de cada sesión de Claude
> Code en este repo. Contiene lo que no cambia sesión a sesión: stack,
> arquitectura, reglas. Lo que sí cambia (avances, pendientes, decisiones
> recientes) vive en `MEMORY.md`, no aquí.

## Qué es este proyecto

Sistema de levantamiento de campo para Grupo Jalisco (distribuidor de
cemento y mortero, rutas COLIMA / TEPIC / VALLES / YAHUALICA). 3 vendedores
capturan visitas desde el celular; Dirección analiza los datos en un
tablero.

**Esto NO es** el sistema de pedidos/CRM (el que involucra a Fortunato,
`app/js/pedidos.js`, `vendedores`, login con 4 roles, etc.). Ese es un
proyecto distinto — si en algún momento aparece contexto de ese sistema
mezclado aquí, es un error de carpeta, señalarlo y no mezclarlo.

## Stack

- **Supabase** — base de datos + RLS. Sin Supabase Auth (RLS solo controla
  insert vs. select).
- **Vercel (Hobby)** — 2 proyectos separados del mismo repo:
  - `formulario/` → público, sin login, HTTPS automático (necesario para GPS).
  - `tablero/` → protegido con Basic Auth vía función serverless
    (`tablero/api/tablero.js`), variables de entorno en Vercel.
- **GitHub** — `cesar786delgado-design/levantamiento-campo`.

## Arquitectura — decisiones que NO se reabren sin consultar a César

- **Clasificación AA/A/B/C/D es una vista SQL** (`v_prospectos`), no una
  columna fija. Razón: si cambian los criterios de puntuación, se
  reclasifica todo el histórico solo con cambiar el SQL.
- **`formulario` usa la `anon key`** (solo puede `insert`, por política RLS).
  **`tablero` usa la `service_role key`** (bypasa RLS) porque está detrás
  de su propio Basic Auth — nunca al revés.
- **Cola de sincronización offline-first** en `localStorage` (`gj_cola`),
  con `Prefer: resolution=merge-duplicates` para que reintentos no
  dupliquen folios. Reintenta en evento `online`, cada 60s, y al cargar.
- **`SB_URL` nunca lleva `/rest/v1/` incluido** — el código lo agrega al
  hacer el fetch. (Bug ya corregido una vez por escribirlo mal — cuidado
  al volver a pegar el Project URL de Supabase.)

## Reglas operativas (no negociables)

1. **No corras SQL, cambios de esquema, ni políticas de RLS directo en
   Supabase.** Proponle el SQL a César para que él lo revise y lo corra
   manualmente.
2. **No hagas commit sin OK explícito de César**, aunque el cambio parezca
   trivial.
3. Si detectas que una tarea implica una decisión de arquitectura o
   seguridad no cubierta en este archivo, dilo explícitamente antes de
   proceder — no la tomes en silencio.

## Dónde está cada cosa

- `formulario/index.html` — formulario de campo (antes `levantamiento_campo.html`).
- `tablero/` — dashboard de Dirección + función de Basic Auth.
- `01_supabase_setup.sql` — script fuente de verdad del esquema (tabla +
  vistas + RLS). Si el esquema real de Supabase diverge de este archivo,
  actualízalo para que quede sincronizado.
- `README.md` — guía de despliegue paso a paso (Supabase → GitHub → Vercel).
- `MEMORY.md` — bitácora sesión a sesión (leer con `/inicio`, actualizar con `/cierre`).
