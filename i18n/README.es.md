[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Convierte imágenes ráster generadas por IA en SVG limpios para trazado vectorial.

Este repositorio ofrece una CLI de Python que detecta bordes o formas binarias en una imagen y las guarda como rutas SVG. Está diseñada para una vectorización estilizada y apta para plotters, no para trazados fotorrealistas.

## 🧰 Resumen rapido (Matriz rapida)

| Area | Ubicacion | Proposito |
|---|---|---|
| Conversión central | [`aigi2vector.py`](aigi2vector.py) | Convierte imágenes raster/PPTX en SVG |
| Utilidades PPTX opcionales | `scripts/` | Extrae y renderiza recursos de diapositivas |
| Automatización extendida | `AutoAppDev/` | Pila de automatización externa opcional |

---

## 📚 Tabla de contenidos

- [Resumen rapido (Cuadro rapida)](#-resumen-rapido-matriz-rapida)
- [Descripción general](#-descripcion-general)
- [Características](#-caracteristicas)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Requisitos previos](#-requisitos-previos)
- [Instalacion](#-instalacion)
- [Uso](#-uso)
- [Flujo visual](#-flujo-visual)
- [Configuracion](#-configuracion)
- [Ejemplos](#-ejemplos)
- [Notas de desarrollo](#-notas-de-desarrollo)
- [Solucion de problemas](#-solucion-de-problemas)
- [Hoja de ruta](#-hoja-de-ruta)
- [Contribuciones](#-contribuciones)
- [Notas](#-notas)
- [Support](#️-support)
- [Licencia](#-licencia)

## 🧭 Resumen rapido (Mapa rapida)

| Caso de uso | Punto de entrada | Resultado |
|---|---|---|
| Convertir una imagen a SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| Ajustar nivel de detalle | Banderas CLI en [`Uso`](#-uso) (`--mode`, `--canny`, `--epsilon`, etc.) | Contornos más limpios o más densos |
| Procesar recursos PPTX | Ayudantes en `scripts/` + entorno conda opcional | Imágenes extraidas + PNG de diapositivas renderizadas |

## 🎯 Resumen

| Capa | Descripcion | Ubicacion |
|---|---|---|
| CLI principal | Convertir imágenes raster en rutas SVG con un solo comando | [`aigi2vector.py`](aigi2vector.py) |
| Utilidades PPTX | Extraer contenido de diapositivas y renderizar páginas para vectorización posterior | `scripts/` |
| Automatización opcional | Flujos de extracción y composición más grandes asistidos por IA | `AutoAppDev/`, `scripts/` |

## ✨ Descripcion general

`aigi2vector` incluye:

- Una CLI raster-a-SVG principal: [`aigi2vector.py`](aigi2vector.py)
- Utilidades PPTX opcionales para extraer imágenes incrustadas y renderizar diapositivas en PNG
- Scripts adicionales de flujo en `scripts/` para extracción de diseño, recorte y tuberias con asistencia de IA
- Un submódulo `AutoAppDev/` (herramientas externas; no requerido para la CLI principal)

| Elemento | Detalles |
|---|---|
| Objetivo principal | Convertir imágenes raster a salida de rutas SVG |
| Modo principal | CLI de Python en un solo archivo |
| Dependencias principales | `opencv-python`, `numpy` |
| Flujos opcionales | Extracción/renderizado de PPTX, tuberias de scripts asistidos por IA |

## 🚀 Características

- Convierte imágenes raster a rutas SVG usando dos modos:
  - `edges`: detección de bordes basada en Canny
  - `binary`: extracción de formas por umbral
- Controles de preprocesamiento:
  - Desenfoque gaussiano (`--blur`)
  - Inversión opcional (`--invert`)
- Simplificación de trazados mediante aproximación de Douglas-Peucker (`--epsilon`)
- Salida SVG que conserva las dimensiones de píxeles de entrada mediante `width`, `height` y `viewBox`
- Utilidades de PPTX:
  - Extraer imágenes incrustadas por diapositiva
  - Renderizar páginas a `page1.png`, `page2.png`, ...

## 🗂️ Estructura del proyecto

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Submódulo git (opcional para la CLI principal)
├── i18n/                            # Directorio de traducciones (actualmente inicial)
└── scripts/
    ├── extract_pptx_images.py
    ├── render_pptx_slides.py
    ├── render_pptx_slides.sh
    ├── setup_conda_env.sh
    ├── crop_elements_from_layout.py
    ├── crop_elements_from_layout_v2.py
    ├── extract_part_grsai.py
    ├── extract_elements_grsai_pipeline.py
    ├── extract_elements_from_prompt_json.py
    ├── run_grsai_three_step.sh
    ├── codex_describe_images_to_md.sh
    ├── codex_extract_layout_elements.sh
    ├── codex_extract_layout_elements_v2.sh
    ├── codex_generate_tikz_from_parts.sh
    ├── codex_compile_tikz_pdf.sh
    └── run_tikz_prompt_pipeline.sh
```

## 📦 Requisitos previos

### CLI principal

- Python 3
- `pip`
- Dependencias de [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Utilidades PPTX opcionales

- Para `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Para `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` o `libreoffice` en `PATH`)
  - `PyMuPDF` (`fitz`)
- Configuración auxiliar opcional:
  - Conda (para `scripts/setup_conda_env.sh`)

### Flujos avanzados opcionales

Varios scripts dentro de `scripts/` dependen de herramientas/servicios externos (por ejemplo la CLI `codex` y APIs de GRS AI). Son opcionales y no son necesarios para ejecutar `aigi2vector.py`.

## 🛠️ Instalacion

### Inicio rapido (flujo canónico actual)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Configuracion conda opcional para utilidades PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Uso

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Opciones de la CLI

| Opcion | Valor por defecto | Descripcion |
|---|---|---|
| `--mode edges|binary` | `edges` | Modo de vectorización |
| `--canny LOW HIGH` | `100 200` | Umbrales bajo/alto para el modo edges |
| `--threshold N` | `128` | Umbral binario usado en modo `binary` |
| `--invert` | off | Invierte blanco y negro antes de detectar contornos |
| `--blur K` | `3` | Tamaño del kernel para desenfoque gaussiano (entero impar) |
| `--epsilon E` | `1.5` | Simplificación de curvas; valores mayores = menos puntos |

### Como funcionan los modos

- El modo `edges` ejecuta detección de bordes con Canny y traza contornos externos.
- El modo `binary` umbraliza píxeles en escala de grises y traza los contornos externos de la máscara resultante.

## 🔧 Flujo visual

```text
Input image/PPTX slide assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (opcional)
   |
   v
Raster tracing + simplification de contornos
   |
   v
SVG output
```

## ⚙️ Configuracion

### Ajuste de parametros principales de la CLI

- `--canny LOW HIGH`:
  - Los valores bajos capturan más detalle/ruido.
  - Los valores altos producen contornos más limpios pero potencialmente más escasos.
- `--threshold` (modo binary):
  - Un umbral bajo conserva más regiones claras como primer plano.
  - Un umbral alto conserva principalmente regiones oscuras/de alto contraste.
- `--blur`:
  - Se normaliza automáticamente a un kernel impar positivo internamente.
  - Valores mayores suavizan el ruido antes de detectar contornos.
- `--epsilon`:
  - Valores mayores simplifican trazados de forma más agresiva (menos puntos).
  - Valores menores preservan más detalle de forma.

### Variables de entorno (scripts avanzados)

- `GRSAI` es requerido por scripts de extracción de GRS AI (por ejemplo `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Nota de suposicion: los scripts avanzados dependen del entorno y estan parcialmente sin documentacion en el README base actual; los comandos siguientes mantienen el comportamiento fiel al repositorio sin garantizar portabilidad entre todas las máquinas.

## 🧪 Ejemplos

### Raster a SVG

Bordes (bueno para arte de linea):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Formas binarias (bueno para logos / arte plano):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Extraccion de imagenes PPTX

Si necesitas extraer imágenes incrustadas desde un `.pptx` (por ejemplo una o dos por diapositiva), usa:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Añade `--dedupe` para omitir imagenes duplicadas entre diapositivas. Añade `--png` para guardar los archivos como `p{slide}image{index}.png`.

### Renderizar diapositivas a imagenes

Para renderizar cada diapositiva a `page1.png`, `page2.png`, ... necesitas tener LibreOffice (`soffice`) instalado:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

O usa el renderizador en Python (tambien usa LibreOffice y luego convierte paginas PDF a PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Flujos avanzados opcionales (scripts)

Estos scripts existen en el repositorio y se pueden usar para pipelines de descomposicion/reconstruccion a mayor escala:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Importante: algunos de estos scripts contienen actualmente rutas absolutas dependientes de una maquina y dependencias de servicios externos; adáptalos antes de usarlos en producción.

## 🧰 Notas de desarrollo

- La implementación principal es una CLI de Python de un solo archivo: [`aigi2vector.py`](aigi2vector.py)
- Mantén nombres de funciones/variables en `snake_case`, constantes en `UPPER_SNAKE_CASE`
- Prefiere funciones pequeñas y testeables sobre bloques monoliticos
- Actualmente no existe un conjunto formal de pruebas
- `AIGI/` es ignorado por git y destinado a assets locales

## 🛟 Solucion de problemas

- `FileNotFoundError` para imagen/PPTX de entrada:
  - Verifica que la ruta de entrada sea correcta y legible.
- `Could not read image`:
  - Confirma que el formato sea compatible con OpenCV y no esté corrupto.
- Salida SVG vacía o pobre:
  - Prueba `--mode binary` con un `--threshold` ajustado.
  - Ajusta umbrales `--canny` en modo `edges`.
  - Reduce `--epsilon` para conservar más puntos de contorno.
  - Comienza desde una imagen fuente de mayor contraste.
- `LibreOffice (soffice) not found in PATH`:
  - Instala LibreOffice y asegúrate de que `soffice` o `libreoffice` sea detectable desde tu shell.
- Faltan paquetes de Python para flujos de scripts:
  - Instala las dependencias requeridas para ese flujo de script (`python-pptx`, `Pillow`, `PyMuPDF`, etc.).
- Fallos de autenticación en scripts de GRS AI:
  - Exporta tu clave, por ejemplo: `export GRSAI=...`.

## 🗺️ Hoja de ruta

Posibles mejoras futuras:

- Añadir pruebas automatizadas bajo `tests/` con imagenes de muestra deterministas
- Publicar grupos unificados de dependencias opcionales para flujos de scripts
- Mejorar la portabilidad de pipelines de shell avanzados (eliminar rutas absolutas codificadas)
- Añadir ejemplos de entrada/salida de referencia bajo assets versionados
- Completar `i18n/` con variantes de README traducidas y mantenidas

## 🤝 Contribuciones

Las contribuciones son bienvenidas.

Proceso sugerido:

1. Haz un fork o rama desde la rama principal actual.
2. Mantén los cambios enfocados y usa mensajes de commit cortos e imperativos.
3. Ejecuta los comandos relevantes que modificaste (rutas CLI/script) y verifica la salida.
4. Actualiza las notas de uso en el README cuando cambie el comportamiento.

Si añades pruebas, ponlas en `tests/` y nombra los archivos `test_*.py`.

## 📝 Notas

- El SVG de salida usa las dimensiones de píxel de entrada. Escálalo en tu editor vectorial si es necesario.
- Para mejores resultados, parte de una imagen de alto contraste.

## Licencia

MIT


## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |
