-- ============================================================
-- Grupo Jalisco · Levantamiento de campo
-- Script completo para correr en el SQL Editor de Supabase
-- Orden: correr todo de una sola vez, de arriba a abajo.
-- ============================================================


-- ------------------------------------------------------------
-- 1. TABLA PRINCIPAL
-- ------------------------------------------------------------

create table visitas (
  id                text primary key,          -- folio que genera el teléfono
  subido_en         timestamptz default now(),
  fecha             timestamptz not null,       -- cuándo se levantó
  vendedor          text not null,
  ruta              text not null,              -- COLIMA | TEPIC | VALLES | YAHUALICA
  municipio         text not null,
  negocio           text not null,
  decide            text,
  telefono          text,
  lat               double precision,
  lon               double precision,
  precision_m       numeric,
  marcas            text[],                     -- {Moctezuma,"Cruz Azul"}
  marca_principal   text,
  unidad_precio     text,                       -- bulto | tonelada
  precio_cemento    numeric,
  precio_mortero    numeric,
  toneladas         numeric,                    -- t/mes de cemento y mortero
  trailer           text,                       -- Sí | No | No sé
  pago              text,                       -- Contado | Crédito | Las dos
  interes           text,                       -- Alto | Medio | Bajo
  notas             text
);

-- Precio normalizado a tonelada, calculado por la base.
-- 1 tonelada = 20 bultos de 50 kg.
alter table visitas
  add column precio_cemento_ton numeric generated always as (
    case when precio_cemento is null then null
         when unidad_precio = 'bulto' then precio_cemento * 20
         else precio_cemento end) stored,
  add column precio_mortero_ton numeric generated always as (
    case when precio_mortero is null then null
         when unidad_precio = 'bulto' then precio_mortero * 20
         else precio_mortero end) stored;

create index on visitas (ruta, municipio);
create index on visitas (interes);


-- ------------------------------------------------------------
-- 2. PERMISOS (fase de levantamiento, 3 vendedores de confianza)
-- ------------------------------------------------------------

alter table visitas enable row level security;

create policy "vendedores insertan"
  on visitas for insert to anon with check (true);

-- El tablero lee con la service_role key (nunca va en el HTML público).
-- Nota: cuando entremos a operación real, cambiar a Supabase Auth
-- con un usuario por vendedor. No antes: frenaría el arranque.


-- ------------------------------------------------------------
-- 3. CLASIFICACIÓN DE PROSPECTOS (AA / A / B / C / D)
-- ------------------------------------------------------------
-- Vista, no columna: si cambia el criterio, se corrige el SQL
-- y toda la historia se reclasifica sola.

create or replace view v_prospectos as
select *,
  case when puntos = 5 then 'AA'
       when puntos = 4 then 'A'
       when puntos = 3 then 'B'
       when puntos = 2 then 'C'
       else 'D' end as clase
from (
  select v.*,
    (case when trailer = 'Sí' then 1 else 0 end)
  + (case when toneladas >= 36 then 1 else 0 end)
  + (case when pago in ('Contado','Las dos') then 1 else 0 end)
  + (case when interes = 'Alto' then 1 else 0 end)
  + (case when not (marcas @> array['Fortaleza']) then 1 else 0 end) as puntos
  from visitas v
) t;


-- ------------------------------------------------------------
-- 4. VISTAS PARA DIRECCIÓN
-- ------------------------------------------------------------

-- 4.1 Precios por plaza — media y moda
create or replace view v_precios as
select ruta, municipio,
  count(precio_cemento_ton)                                        as n_cemento,
  round(avg(precio_cemento_ton))                                   as cemento_media,
  mode() within group (order by precio_cemento_ton)                as cemento_moda,
  min(precio_cemento_ton)                                          as cemento_min,
  max(precio_cemento_ton)                                          as cemento_max,
  count(precio_mortero_ton)                                        as n_mortero,
  round(avg(precio_mortero_ton))                                   as mortero_media,
  mode() within group (order by precio_mortero_ton)                as mortero_moda
from visitas
group by ruta, municipio;

-- 4.2 Participación de marca por zona
create or replace view v_marcas as
select ruta, marca, count(*) as puntos_venta,
  round(100.0 * count(*) / sum(count(*)) over (partition by ruta), 1) as porcentaje
from visitas, unnest(marcas) as marca
group by ruta, marca
order by ruta, puntos_venta desc;

-- 4.3 Cuánto vale lo que tenemos identificado
create or replace view v_valor as
select ruta, clase,
  count(*)                    as prospectos,
  sum(toneladas)              as toneladas_mes,
  round(avg(toneladas))       as promedio_por_cliente,
  round(sum(toneladas) * round(avg(precio_cemento_ton))) as valor_mensual_estimado
from v_prospectos
group by ruta, clase
order by ruta, clase;


-- ============================================================
-- Fin del script. Verificar en Table Editor que aparezcan:
--   tabla:  visitas
--   vistas: v_prospectos, v_precios, v_marcas, v_valor
-- ============================================================
