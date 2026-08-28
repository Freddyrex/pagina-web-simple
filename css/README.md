# Versión: Moderna con CSS

Esta carpeta contiene la **versión moderna** del sitio web académico de **Freddy Valenzuela**, construida con **HTML semántico + CSS** bajo una estética *"Tech Dark & Clean Minimal"*.

## ¿Qué se implementó?

### Estructura y diseño (`styles.css`)
- **Paleta moderna** con variables CSS:
  - Fondo gris claro `#f1f5f9`
  - Azul marino profundo `#0f172a` (header/footer)
  - Azul cian/eléctrico `#0ea5e9` (acentos e interactivos)
  - Azul medio `#2563eb` (CTA, menú activo, detalles)
  - Ambos extremos (header y footer) **full-width** para un contraste limpio de punta a punta.
- **Tipografía**: Poppins (títulos) e Inter (cuerpo).
- **Header sticky** con logo a la izquierda, menú de navegación y botón CTA de contacto.
- **Tarjetas** (`article.card`) con sombras sutiles y borde superior de acento azul.
- **Footer oscuro** con iconos de redes sociales (LinkedIn y GitHub).

### `index.html`
- **Sobre mí**: foto de perfil circular con doble borde azul, jerarquía de título clara, texto corregido y "Datos rápidos" con iconos SVG (carrera y semestre).
- **Mi universidad**: logo alineado a la izquierda con descripción mejorada.
- **Intereses académicos**: cuadrícula de tarjetas con iconos SVG modernos (desarrollo web, bases de datos, IA, ciberseguridad, diseño de software).

### Resto de páginas
- **Header sticky compartido** con el enlace actual resaltado en azul (`class="active"`).
- **Título de página** (`page-hero`) para las páginas internas.
- **Tarjetas** para el contenido de cursos, pasatiempos, clubes y proyectos.
- **Formulario** de contacto re-estilizado.
- **Footer social** común en todas las páginas.

## Estructura

```
css/
├── index.html       (página principal)
├── courses.html
├── schedule.html
├── hobbies.html
├── clubs.html
├── projects.html
├── contact.html
├── styles.css       (hoja de estilos)
└── images/
```

## Uso local

Abre `index.html` en tu navegador. No requiere servidor ni dependencias.

---

> La **versión original de HTML puro** vive en la carpeta `html/`.
