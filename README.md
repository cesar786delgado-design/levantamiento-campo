# Levantamiento de campo — Grupo Jalisco

Este repo tiene dos sitios independientes que se despliegan como **dos
proyectos de Vercel separados**, apuntando cada uno a su carpeta:

```
formulario/   → el que usan los vendedores en el celular (público, sin login)
tablero/      → el que usa Dirección (protegido con usuario y contraseña)
```

---

## 1. Supabase (hacer primero)

1. Entra a tu proyecto de Supabase → **SQL Editor** → pega y corre
   `01_supabase_setup.sql` completo (te lo pasé antes; créalo en la raíz de
   este repo o corre el que ya tienes).
2. Ve a **Project Settings → API** y copia:
   - **Project URL**
   - **anon public key**
   - **service_role key** (esta es secreta, no la compartas ni la subas a git)

---

## 2. Formulario (`formulario/index.html`)

Antes de subir el repo, edita `formulario/index.html` y reemplaza:

```js
const SB_URL  = "https://TUPROYECTO.supabase.co";
const SB_KEY  = "TU_ANON_KEY";
```

con tu **Project URL** y tu **anon public key**. Esta key es pública a
propósito — solo puede insertar (`insert`), no leer, por la política de RLS
del paso 1. Es seguro que quede en el código.

---

## 3. Tablero (`tablero/`)

No edites nada aquí — las credenciales se inyectan en Vercel como variables
de entorno, no van escritas en el código.

---

## 4. Subir a GitHub

Desde esta carpeta, en tu máquina:

```bash
git init
git add .
git commit -m "Levantamiento de campo: formulario y tablero"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git push -u origin main
```

(Crea el repo vacío en GitHub primero, sin README, para que el push no truene.)

---

## 5. Desplegar en Vercel — dos proyectos del mismo repo

### Proyecto 1 · Formulario

1. Vercel → **Add New → Project** → importa el repo.
2. **Root Directory**: `formulario`
3. Framework Preset: **Other**
4. Build Command / Output Directory: dejar vacíos (no hay build).
5. Deploy.
6. Vercel te da HTTPS automático — el GPS del formulario va a funcionar sin
   nada extra que configurar.

### Proyecto 2 · Tablero

1. Vercel → **Add New → Project** → importa el **mismo repo otra vez**
   (Vercel te deja crear un segundo proyecto sobre el mismo repo).
2. **Root Directory**: `tablero`
3. Framework Preset: **Other**
4. Antes de darle deploy (o justo después, en **Settings → Environment
   Variables**), agrega:

   | Variable | Valor |
   |---|---|
   | `TABLERO_USER` | el usuario que va a usar Dirección |
   | `TABLERO_PASS` | la contraseña |
   | `SUPABASE_URL` | el Project URL de Supabase |
   | `SUPABASE_SERVICE_KEY` | la **service_role key** (la secreta) |

5. Deploy (o **Redeploy** si ya lo habías corrido antes de poner las
   variables — las variables de entorno solo aplican a partir del deploy en
   el que ya existían).
6. Al entrar a la URL del tablero, el navegador va a pedir usuario y
   contraseña (Basic Auth) antes de mostrar nada.

---

## 6. Publicar el link a los vendedores

Igual que en el brief original: mandar el link del **formulario** por
WhatsApp con la instrucción de "Agregar a pantalla de inicio" y dar permiso
de ubicación.

El link del **tablero** solo se comparte con Dirección, junto con el usuario
y la contraseña que hayas puesto en `TABLERO_USER` / `TABLERO_PASS`.
