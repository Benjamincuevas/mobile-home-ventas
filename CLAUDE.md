# Mobile Home Ventas — Contexto del proyecto

Sitio de venta de casas móviles (mobile homes) orientado a generación de leads por Instagram (mensaje directo `ig.me/m/{usuario}`), con diseño tipo marketplace inspirado en el inventario de Camping World (rv.campingworld.com).

## Archivos

| Archivo | Rol |
|---|---|
| `index.html` | Página pública. Single-file: HTML + CSS + JS vanilla, sin build ni dependencias. |
| `admin.html` | Panel de administración. También single-file. Gestiona el inventario completo; publica a Supabase o genera `data.js`. |
| `supabase-config.js` | Define `window.MHV_SUPABASE = { url, anonKey }`. Con campos vacíos, todo funciona en modo clásico `data.js`. |
| `supabase-setup.sql` | Script único para el SQL Editor de Supabase: tabla `site_data` (RLS: lectura pública, escritura `authenticated`), bucket público `fotos` y sus políticas, fila inicial `id=1`. |
| `data.js` | Generado por el admin (botón "Descargar data.js"). Define `window.MHV_DATA`. Modo clásico / respaldo. Si no existe y no hay Supabase, la página usa 6 unidades de muestra con ilustraciones SVG. |
| `data.ejemplo.js` | Ejemplo del contrato de datos (renombrar a `data.js` para probar). |
| `LEEME.txt` | Instrucciones de publicación para el dueño del negocio (no técnico): Vercel + dominio + Supabase. |

## Arquitectura y flujo

**Modo Supabase** (activo cuando `supabase-config.js` tiene `url` y `anonKey`):

1. El dueño abre `admin.html` y entra con correo/contraseña (Supabase Auth, grant `password` vía REST `/auth/v1/token`; tokens solo en memoria, refresh en 401).
2. El panel carga el inventario de `GET /rest/v1/site_data?id=eq.1` y al presionar "☁️ Publicar": sube las fotos que sigan siendo data-URLs a Storage (`POST /storage/v1/object/fotos/casa-{id}/...`, quedan como URLs públicas) y hace upsert del documento completo `{settings, listings}` en la columna jsonb `data` (POST con `Prefer: resolution=merge-duplicates`).
3. `index.html` al cargar hace `fetch` del mismo registro y, si trae listings, re-renderiza (prioridad: Supabase → `data.js` → muestras; si el fetch falla, la página nunca se rompe).

Todo por REST con `fetch` — **no** se usa la librería supabase-js (regla 1: sin dependencias).

**Modo clásico** (config vacía):

1. El dueño abre `admin.html` (código de acceso: constante `ADMIN_PIN`, actualmente `"2468"`).
2. Captura casas: nombre, tamaño, tipo (single/double), recámaras, baños, precio, precio anterior, ubicación, marca, año, condición (nueva/seminueva), ft², stock #, características (checkboxes + libres), descripción corta y larga, y fotos (se comprimen en canvas a máx. 1280px JPG 0.8 y se guardan como data-URLs base64).
3. Descarga `data.js` → lo sube a la misma carpeta del hosting.
4. `index.html` carga `<script src="data.js">`; si `window.MHV_DATA` existe, sus `listings` y `settings` reemplazan los datos de muestra.

## Contrato de `data.js`

```js
window.MHV_DATA = {
  settings: {
    phone: "(555) 123-4567",   // texto mostrado (elementos .js-phone)
    instagram: "@usuario",     // contacto principal: reescribe links a instagram.com y ig.me (DM)
    whatsapp: "15551234567"    // legado: se tolera en data.js viejos pero ya no se usa en la UI
  },
  listings: [{
    id: 1, name: "Modelo X", size: "16×76", type: "single|double",
    beds: 3, baths: 2, price: 52900, oldPrice: 0,   // oldPrice > price ⇒ badge "Precio Rebajado" + tachado
    badge: "disp|oport|remod", location: "", brand: "", year: 0,
    cond: "nueva|seminueva", sqft: 0, stock: "",
    desc: "corta (tarjeta)", descLong: "completa (modal)",
    features: ["Aire central", ...], photos: ["data:image/jpeg;base64,..."]
  }]
};
```

Todos los campos nuevos son opcionales; el mapeo en ambos archivos aplica defaults. Mantener retro-compatibilidad con data.js viejos.

## Funcionalidad clave en `index.html`

- Header con buscador de texto (filtra el inventario en vivo) + nav azul sticky.
- SRP: sidebar de filtros multi-select (tipo, recámaras, precio, estado) con drawer en móvil; ordenamiento; tarjetas horizontales con carrusel de fotos y favoritos.
- Modal "ficha completa" por unidad (galería, specs, características, descripción larga, CTAs).
- Estimador de pago mensual (sliders precio/enganche + plazo; tasa ilustrativa `RATE = 0.095`).
- Formulario de precalificación → muestra un resumen para copiar y abre el DM de Instagram (IG no permite pre-llenar mensajes).
- Todos los CTAs abren el mensaje directo de Instagram (helper `igDm()` → `ig.me/m/{usuario}`).
- Fallback visual: función `homeArt(c, wide)` genera ilustraciones SVG de casas cuando una unidad no tiene fotos.

## Reglas y restricciones (IMPORTANTES — no romper)

1. **Sin build, sin frameworks, sin dependencias**: todo debe seguir siendo archivos sueltos que funcionen en hosting estático barato.
2. **Compatibilidad con Safari de iOS antiguo**: NO usar `?.`, `??`, `Object.fromEntries`, ni APIs modernas sin fallback. Un error de sintaxis mata todo el script en Safari viejo. Ya se limpiaron; mantenerlo así.
3. **Sin `<form>` con submit**: los envíos de formulario se bloquean en visores con sandbox (vista previa de Claude, QuickLook). Todos los botones usan `addEventListener("click")` + Enter manual donde aplica.
4. **Sin localStorage/sessionStorage** para los datos del inventario: la persistencia es vía Supabase o exportar/importar `data.js` (decisión deliberada: las fotos base64 exceden cuotas de storage). Única excepción: `admin.html` guarda los tokens de sesión de Supabase (clave `MHV_SB_SESSION`, ~1 KB, nunca la contraseña) en localStorage para "recordar sesión", siempre envuelto en try/catch (en Safari privado falla y debe degradar a pedir login).
5. Español en toda la UI. Disclaimers legales de precios/cuotas deben conservarse (footer y calculadora).
6. `ADMIN_PIN` es solo un disuasivo del lado del cliente; la recomendación al usuario es renombrar `admin.html` a algo no adivinable o protegerlo en el servidor. No prometer seguridad real client-side.
7. Paleta actual (tipo Camping World): navy `#00305C`, azul `#0C5FA8`, amarillo CTA `#FFC629` (texto oscuro encima), rojo rebaja `#D0021B`, verde WhatsApp `#25D366`. Fuentes: Roboto + Roboto Condensed (Google Fonts).

## Cómo probar localmente

```bash
npx serve .        # o: python3 -m http.server 8000
# abrir http://localhost:3000 (index) y /admin.html
```

Probar: filtros/orden/búsqueda, carrusel y modal de fichas, calculadora, formulario, admin (PIN 2468 → agregar casa con fotos → Descargar data.js → colocarlo junto a index.html → recargar index y verificar que aparecen las casas reales y que settings reescriben teléfono/WhatsApp/Instagram). Verificar responsive (drawer de filtros < 960px).

## Backlog de ideas (no implementadas)

- Campo de video (YouTube/tour virtual) por unidad, embebido en el modal.
- Paginación o "cargar más" si el inventario crece (>15 unidades).
- Página de detalle por unidad con URL propia (query param `?casa=id`) para compartir por WhatsApp.
- Envío del formulario a un CRM/Google Sheets además de WhatsApp.
- Miniaturas separadas de fotos grandes (hoy Storage sirve la misma imagen 1280px en tarjeta y modal).
- Borrar del Storage las fotos huérfanas al eliminar casas (hoy quedan archivos sin referenciar en el bucket).
