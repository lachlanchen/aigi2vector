[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Convierte imágenes ráster generadas por IA en SVG vectoriales limpios y aptos para plotter.

Este repositorio proporciona una CLI en Python que detecta bordes o formas binarias en una imagen y las escribe como rutas SVG. Está diseñado para una vectorización estilizada y compatible con plotters, en lugar de un trazado fotorrealista.

## ✨ Resumen

`aigi2vector` incluye:

- Una CLI principal de conversión ráster a SVG: [`aigi2vector.py`](aigi2vector.py)
- Utilidades opcionales para PPTX que extraen imágenes incrustadas y renderizan diapositivas a PNG
- Scripts de flujo de trabajo adicionales en `scripts/` para extracción de layout, recorte y pipelines asistidos por IA
- Un submódulo `AutoAppDev/` (herramienta externa; no requerido para la CLI principal)

| Elemento | Detalles |
|---|---|
| Propósito principal | Convertir imágenes ráster a rutas SVG |
| Modo principal | CLI de Python en un solo archivo |
| Dependencias principales | `opencv-python`, `numpy` |
| Flujos opcionales | Extracción/renderizado de PPTX, pipelines de scripts asistidos por IA |

## 🚀 Características

- Convierte imágenes ráster en rutas SVG usando dos modos:
  - `edges`: detección de bordes basada en Canny
  - `binary`: extracción de formas por umbral
- Controles de preprocesamiento:
  - Desenfoque gaussiano (`--blur`)
  - Inversión opcional (`--invert`)
- Simplificación de rutas con aproximación de Douglas-Peucker (`--epsilon`)
- Salida SVG que conserva las dimensiones en píxeles de la entrada mediante `width`, `height` y `viewBox`
- Utilidades de imágenes PPTX:
  - Extraer imágenes incrustadas por diapositiva
  - Renderizar páginas de diapositivas en `page1.png`, `page2.png`, ...

## 🗂️ Estructura del proyecto

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Submódulo Git (opcional para la CLI principal)
├── i18n/                            # Directorio de traducciones (actualmente scaffold/vacío)
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

### Utilidades opcionales para PPTX

- Para `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Para `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` o `libreoffice` en `PATH`)
  - `PyMuPDF` (`fitz`)
- Configuración auxiliar opcional:
  - Conda (para `scripts/setup_conda_env.sh`)

### Pipelines avanzados opcionales

Varios scripts en `scripts/` dependen de herramientas/servicios externos (por ejemplo, la CLI `codex` y APIs de GRS AI). Son opcionales y no se requieren para ejecutar `aigi2vector.py`.

## 🛠️ Instalación

### Inicio rápido (flujo canónico existente)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Configuración opcional con Conda para utilidades PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Uso

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Opciones de la CLI

| Opción | Predeterminado | Descripción |
|---|---|---|
| `--mode edges|binary` | `edges` | Modo de vectorización |
| `--canny LOW HIGH` | `100 200` | Umbrales bajo/alto para el modo `edges` |
| `--threshold N` | `128` | Umbral binario usado en modo `binary` |
| `--invert` | desactivado | Invierte blanco/negro antes de detectar contornos |
| `--blur K` | `3` | Tamaño del kernel gaussiano (entero impar) |
| `--epsilon E` | `1.5` | Simplificación de curvas; mayor = menos puntos |

### Cómo funcionan los modos

- El modo `edges` ejecuta detección de bordes Canny y traza contornos externos.
- El modo `binary` aplica umbral a la escala de grises y traza contornos externos de la máscara resultante.

## ⚙️ Configuración

### Ajuste de parámetros de la CLI principal

- `--canny LOW HIGH`:
  - Valores más bajos capturan más detalle/ruido.
  - Valores más altos producen contornos más limpios, aunque potencialmente más escasos.
- `--threshold` (modo binario):
  - Un umbral más bajo conserva más regiones claras como primer plano.
  - Un umbral más alto conserva sobre todo regiones oscuras/de alto contraste.
- `--blur`:
  - Se normaliza automáticamente internamente a un kernel impar positivo.
  - Valores más grandes suavizan ruido antes de detectar contornos.
- `--epsilon`:
  - Valores más grandes simplifican rutas de forma más agresiva (menos puntos).
  - Valores más pequeños preservan más detalle de forma.

### Variables de entorno (scripts avanzados)

- `GRSAI` es requerido por los scripts de extracción con GRS AI (por ejemplo, `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Nota de suposición: los scripts avanzados dependen del entorno y están parcialmente sin documentar en la base actual del README; los comandos siguientes mantienen un comportamiento fiel al repositorio sin garantizar portabilidad en todas las máquinas.

## 🧪 Ejemplos

### Ráster a SVG

Bordes (bueno para line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Formas binarias (bueno para logotipos / arte plano):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Extracción de imágenes PPTX

Si necesitas extraer imágenes incrustadas de un `.pptx` (por ejemplo, una o dos imágenes por diapositiva), usa:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Añade `--dedupe` para omitir imágenes duplicadas entre diapositivas. Añade `--png` para guardar archivos como `p{slide}image{index}.png`.

### Renderizar diapositivas a imágenes

Para renderizar cada diapositiva como `page1.png`, `page2.png`, ... necesitas LibreOffice (`soffice`) instalado:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

O usa el renderizador en Python (también usa LibreOffice y luego convierte páginas PDF a PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Flujos avanzados opcionales (scripts)

Estos scripts existen en el repositorio y pueden usarse para pipelines más grandes de descomposición/reconstrucción:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Importante: algunos de estos scripts contienen actualmente rutas absolutas específicas de una máquina y dependencias de servicios externos; adáptalos antes de usarlos en producción.

## 🧰 Notas de desarrollo

- La implementación principal es una CLI de Python en un solo archivo: [`aigi2vector.py`](aigi2vector.py)
- Mantén nombres de funciones/variables en `snake_case` y constantes en `UPPER_SNAKE_CASE`
- Prefiere funciones pequeñas y comprobables frente a bloques monolíticos
- Actualmente no existe una suite formal de pruebas
- `AIGI/` está ignorado por git y pensado para activos locales

## 🛟 Solución de problemas

- `FileNotFoundError` para imagen/PPTX de entrada:
  - Verifica que la ruta de entrada sea correcta y legible.
- `Could not read image`:
  - Confirma que el formato sea compatible con OpenCV y que el archivo no esté corrupto.
- Salida SVG vacía o de baja calidad:
  - Prueba `--mode binary` ajustando `--threshold`.
  - Ajusta los umbrales `--canny` en modo `edges`.
  - Reduce `--epsilon` para conservar más puntos de contorno.
  - Empieza con una imagen fuente de mayor contraste.
- `LibreOffice (soffice) not found in PATH`:
  - Instala LibreOffice y asegúrate de que `soffice` o `libreoffice` sea detectable en tu shell.
- Faltan paquetes Python para flujos de scripts:
  - Instala las dependencias requeridas para esa ruta de script (`python-pptx`, `Pillow`, `PyMuPDF`, etc.).
- Los scripts GRS AI fallan con errores de autenticación:
  - Exporta tu clave, por ejemplo: `export GRSAI=...`.

## 🗺️ Hoja de ruta

Posibles mejoras siguientes:

- Añadir pruebas automatizadas en `tests/` con imágenes de muestra deterministas
- Publicar grupos unificados de dependencias opcionales para flujos de scripts
- Mejorar la portabilidad de pipelines shell avanzados (eliminar rutas absolutas codificadas)
- Añadir ejemplos de entrada/salida de referencia en activos de muestra versionados
- Completar `i18n/` con variantes de README traducidas y mantenidas

## 🤝 Contribuir

Las contribuciones son bienvenidas.

Proceso sugerido:

1. Haz un fork o crea una rama desde la línea principal actual.
2. Mantén cambios enfocados y usa mensajes de commit cortos en modo imperativo.
3. Ejecuta los comandos relevantes que cambiaste (ruta CLI/script) y verifica la salida.
4. Actualiza las notas de uso del README cuando cambie el comportamiento.

Si añades pruebas, colócalas en `tests/` y nombra los archivos `test_*.py`.

## 📝 Notas

- El SVG de salida usa las dimensiones en píxeles de la entrada. Escálalo en tu editor vectorial si hace falta.
- Para mejores resultados, empieza con una imagen de alto contraste.

## License

MIT
