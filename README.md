# Página Web Simple - My University Website

Sitio web académico personal de **Freddy Valenzuela**, estudiante de Ciencias de la Computación en la Universidad Yachay Tech.

El proyecto está construido **únicamente con HTML puro** (sin CSS ni JavaScript), usando atributos clásicos como `bgcolor`, `<font>` y tablas para la presentación, con un estilo inspirado en la Web 1.0.

🔗 **Ver en línea:** https://pagina-web-simple-9v.vercel.app/

## Páginas

| Página | Descripción |
|---|---|
| `index.html` | Inicio: sobre mí, mi universidad e intereses académicos |
| `courses.html` | Materias del semestre actual |
| `schedule.html` | Horario semanal de clases |
| `hobbies.html` | Pasatiempos |
| `clubs.html` | Clubes estudiantiles |
| `projects.html` | Proyectos académicos y personales |
| `contact.html` | Formulario de contacto |

## Uso local

No requiere dependencias ni servidor. Solo abre `index.html` en tu navegador.

Opcionalmente, puedes desplegarlo en Apache local con HTTPS:

```bash
./deploy.sh --project "$PWD" --domain aplicaciones-web.local --no-open
```
