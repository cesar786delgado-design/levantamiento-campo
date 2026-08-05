Vamos a cerrar la sesión. Antes de tocar `MEMORY.md`:

1. Corre `git log --oneline` desde el último hash listado en la sección
   "Commits relevantes" de `MEMORY.md` hasta ahora, para ver qué se hizo
   realmente en esta sesión.
2. Revisa si hubo cambios sin commitear (`git status`) — si los hay,
   pregúntame explícitamente si quiero commitearlos antes de cerrar, o
   dejarlos pendientes (recuerda: nunca hagas commit sin mi OK explícito).

Después, actualiza `MEMORY.md`:

- **"Dónde nos quedamos"** — reescribe con el estado real al día de hoy
  (no acumules historial ahí, es un snapshot del presente).
- **"Próximo paso"** — qué sigue lógicamente después de esta sesión.
- **"Decisiones recientes"** — agrega una entrada nueva (fecha + qué se
  decidió) solo si en esta sesión se tomó alguna decisión de arquitectura,
  seguridad, o algo que valga la pena que la próxima sesión recuerde. No
  agregues entradas por cambios triviales.
- **"Pendientes activos"** — actualiza la lista: quita lo resuelto, agrega
  lo nuevo que haya surgido.
- **"Commits relevantes"** — agrega el/los hash(es) de esta sesión si hubo
  commits.

Muéstrame el diff de `MEMORY.md` antes de guardarlo, para que lo apruebe.

Al final dame un resumen corto (3-5 líneas): qué se hizo, qué quedó
pendiente, y si algo requiere que yo lo consulte con mi estratega
(Claude Web) antes de la próxima sesión.
