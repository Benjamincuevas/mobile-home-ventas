# 🏡 Mobile Home Ventas

Sitio web de venta de casas móviles (mobile homes) enfocado en generación de clientes por WhatsApp, con diseño tipo marketplace (inspirado en el inventario de Camping World) y panel de administración propio.

## Demo local

```bash
npx serve .
# o: python3 -m http.server 8000
```

## Estructura

| Archivo | Descripción |
|---|---|
| `index.html` | Página pública: inventario con filtros laterales, buscador, carrusel de fotos, ficha de detalles, estimador de pagos y formulario de precalificación. |
| `admin.html` | Panel de administración: alta/edición de casas con fotos, características y toda la ficha del producto. Publica a Supabase (botón ☁️) o genera `data.js`. |
| `supabase-config.js` | URL y anon key del proyecto Supabase. Con los campos vacíos, el sitio funciona en modo `data.js` clásico. |
| `supabase-setup.sql` | Script para el SQL Editor de Supabase: crea la tabla `site_data`, el bucket `fotos` y sus políticas. Se corre una sola vez. |
| `data.js` | Datos del inventario en modo clásico (lo genera el panel — no editar a mano). |
| `data.ejemplo.js` | Ejemplo del contrato de datos. |
| `CLAUDE.md` | Contexto del proyecto para Claude Code (arquitectura, reglas, backlog). |
| `LEEME.txt` | Instrucciones de publicación para el dueño del negocio. |

## Flujo de contenido

**Con Supabase (recomendado):** `admin.html` → login con correo/contraseña (Supabase Auth) → editar casas → **☁️ Publicar en la página**. Las fotos suben al bucket `fotos` de Storage y el inventario se guarda en la tabla `site_data`; `index.html` lo lee al cargar y la página se actualiza sola.

**Modo clásico (sin Supabase):** `admin.html` (PIN) → **Descargar data.js** → subirlo junto a `index.html`. Sin datos, la página usa unidades de muestra ilustradas. Orden de prioridad en `index.html`: Supabase → `data.js` → muestras.

## Publicación

**Vercel (con dominio propio):** importar el repo en vercel.com (framework "Other", sin build) → Settings → Domains → agregar el dominio. Cada push a `main` re-despliega solo.

**GitHub Pages:** Settings → Pages → *Deploy from a branch* → `main` / root. El sitio queda en `https://TU-USUARIO.github.io/NOMBRE-DEL-REPO/` y el panel en `.../admin.html`.

Pasos detallados (no técnicos) en `LEEME.txt`; preparación de la base de datos en `supabase-setup.sql`.

## Reglas técnicas

Sin frameworks ni build (hosting estático puro), JavaScript compatible con Safari de iOS antiguo (sin `?.`/`??`), sin `<form>` submit, persistencia por exportación de `data.js`. Detalles completos en `CLAUDE.md`.
