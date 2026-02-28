[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Konvertiere KI-generierte Rasterbilder in saubere Vektor-Plot-SVGs.

Dieses Repository stellt eine Python-CLI bereit, die Kanten oder binäre Formen in einem Bild erkennt und als SVG-Pfade ausgibt. Sie ist für stilisierte, plotterfreundliche Vektorisierung statt fotorealistisches Tracing ausgelegt.

## ✨ Überblick

`aigi2vector` enthält:

- Eine Raster-zu-SVG-CLI als Kern: [`aigi2vector.py`](aigi2vector.py)
- Optionale PPTX-Helfer zum Extrahieren eingebetteter Bilder und Rendern von Folien zu PNG
- Zusätzliche Workflow-Skripte unter `scripts/` für Layout-Extraktion, Cropping und KI-gestützte Pipelines
- Ein `AutoAppDev/`-Submodul (externes Tooling; für die Haupt-CLI nicht erforderlich)

| Eintrag | Details |
|---|---|
| Kernzweck | Rasterbilder in SVG-Pfadausgabe umwandeln |
| Primärer Modus | Single-File-Python-CLI |
| Kernabhängigkeiten | `opencv-python`, `numpy` |
| Optionale Workflows | PPTX-Extraktion/-Rendering, KI-gestützte Skript-Pipelines |

## 🚀 Features

- Konvertierung von Rasterbildern in SVG-Pfade mit zwei Modi:
  - `edges`: Canny-basierte Kantenerkennung
  - `binary`: Schwellenwertbasierte Formextraktion
- Vorverarbeitungsoptionen:
  - Gaussian Blur (`--blur`)
  - Optionale Invertierung (`--invert`)
- Pfadvereinfachung mit Douglas-Peucker-Approximation (`--epsilon`)
- SVG-Ausgabe, die Pixelmaße der Eingabe über `width`, `height` und `viewBox` beibehält
- PPTX-Bildwerkzeuge:
  - Eingebettete Bilder folienweise extrahieren
  - Folienseiten als `page1.png`, `page2.png`, ... rendern

## 🗂️ Projektstruktur

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (optional for core CLI)
├── i18n/                            # Translation directory (currently scaffold/empty)
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

## 📦 Voraussetzungen

### Kern-CLI

- Python 3
- `pip`
- Abhängigkeiten aus [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Optionale PPTX-Helfer

- Für `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Für `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` oder `libreoffice` in `PATH`)
  - `PyMuPDF` (`fitz`)
- Optionales Helper-Setup:
  - Conda (für `scripts/setup_conda_env.sh`)

### Optionale erweiterte Pipelines

Mehrere Skripte unter `scripts/` hängen von externen Tools/Diensten ab (zum Beispiel `codex` CLI und GRS AI APIs). Diese sind optional und nicht erforderlich, um `aigi2vector.py` auszuführen.

## 🛠️ Installation

### Quick Start (bestehender kanonischer Ablauf)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Optionales Conda-Setup für PPTX-Utilities

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Nutzung

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI-Optionen

| Option | Standard | Beschreibung |
|---|---|---|
| `--mode edges|binary` | `edges` | Vektorisierungsmodus |
| `--canny LOW HIGH` | `100 200` | Niedrige/hohe Schwellenwerte für den `edges`-Modus |
| `--threshold N` | `128` | Binärer Schwellenwert im `binary`-Modus |
| `--invert` | aus | Schwarz/Weiß vor der Konturerkennung invertieren |
| `--blur K` | `3` | Kernelgröße für Gaussian Blur (ungerade Ganzzahl) |
| `--epsilon E` | `1.5` | Kurvenvereinfachung; höher = weniger Punkte |

### Funktionsweise der Modi

- Der Modus `edges` führt Canny-Kantenerkennung aus und traced externe Konturen.
- Der Modus `binary` thresholdet Graustufenpixel und traced externe Konturen der resultierenden Maske.

## ⚙️ Konfiguration

### Tuning der Haupt-CLI-Parameter

- `--canny LOW HIGH`:
  - Niedrigere Werte erfassen mehr Details/Rauschen.
  - Höhere Werte liefern sauberere, aber potenziell dünnere Konturen.
- `--threshold` (binary mode):
  - Ein niedrigerer Schwellenwert behält mehr helle Bereiche als Vordergrund.
  - Ein höherer Schwellenwert behält überwiegend dunkle/kontrastreiche Bereiche.
- `--blur`:
  - Wird intern automatisch auf einen positiven ungeraden Kernel normalisiert.
  - Größere Werte glätten Rauschen vor der Konturerkennung.
- `--epsilon`:
  - Größere Werte vereinfachen Pfade aggressiver (weniger Punkte).
  - Kleinere Werte erhalten mehr Formdetails.

### Umgebungsvariablen (erweiterte Skripte)

- `GRSAI` ist für GRS-AI-Extraktionsskripte erforderlich (zum Beispiel `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Hinweis zur Annahme: Erweiterte Skripte sind umgebungsspezifisch und in der aktuellen README-Basis teilweise undokumentiert; die folgenden Befehle behalten repository-genaues Verhalten bei, ohne Portabilität über alle Maschinen hinweg zu garantieren.

## 🧪 Beispiele

### Raster zu SVG

Edges (gut für Line Art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binäre Formen (gut für Logos / Flat Art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX-Bildextraktion

Wenn du eingebettete Bilder aus einer `.pptx` extrahieren musst (z. B. ein oder zwei Bilder pro Folie), verwende:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Füge `--dedupe` hinzu, um doppelte Bilder über Folien hinweg zu überspringen. Füge `--png` hinzu, um Dateien als `p{slide}image{index}.png` zu speichern.

### Folien zu Bildern rendern

Um jede Folie als `page1.png`, `page2.png`, ... zu rendern, muss LibreOffice (`soffice`) installiert sein:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Oder verwende den Python-Renderer (nutzt ebenfalls LibreOffice und konvertiert anschließend PDF-Seiten zu PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optionale erweiterte Workflows (Skripte)

Diese Skripte sind im Repository vorhanden und können für größere Zerlegungs-/Rekonstruktionspipelines verwendet werden:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Wichtig: Einige dieser Skripte enthalten aktuell maschinenspezifische absolute Pfade und Abhängigkeiten von externen Diensten; passe sie vor dem Produktiveinsatz an.

## 🧰 Entwicklungshinweise

- Die Hauptimplementierung ist eine Single-File-Python-CLI: [`aigi2vector.py`](aigi2vector.py)
- Funktions-/Variablennamen in `snake_case`, Konstanten in `UPPER_SNAKE_CASE` halten
- Kleine, testbare Funktionen gegenüber monolithischen Blöcken bevorzugen
- Aktuell ist keine formale Test-Suite vorhanden
- `AIGI/` wird von git ignoriert und ist für lokale Assets gedacht

## 🛟 Fehlerbehebung

- `FileNotFoundError` für Eingabebild/PPTX:
  - Prüfe, ob der Eingabepfad korrekt ist und gelesen werden kann.
- `Could not read image`:
  - Prüfe, ob das Dateiformat von OpenCV unterstützt wird und die Datei nicht beschädigt ist.
- Leere oder schlechte SVG-Ausgabe:
  - Versuche `--mode binary` mit angepasstem `--threshold`.
  - Passe `--canny`-Schwellenwerte im `edges`-Modus an.
  - Reduziere `--epsilon`, um mehr Konturpunkte beizubehalten.
  - Starte mit einem kontrastreicheren Quellbild.
- `LibreOffice (soffice) not found in PATH`:
  - Installiere LibreOffice und stelle sicher, dass `soffice` oder `libreoffice` in deiner Shell gefunden wird.
- Fehlende Python-Pakete für Skript-Workflows:
  - Installiere die benötigten Abhängigkeiten für den jeweiligen Skriptpfad (`python-pptx`, `Pillow`, `PyMuPDF` usw.).
- GRS-AI-Skripte schlagen mit Auth-Fehlern fehl:
  - Exportiere deinen Schlüssel, zum Beispiel: `export GRSAI=...`.

## 🗺️ Roadmap

Potenzielle nächste Verbesserungen:

- Automatisierte Tests unter `tests/` mit deterministischen Beispielbildern hinzufügen
- Einheitliche optionale Abhängigkeitsgruppen für Skript-Workflows veröffentlichen
- Portabilität erweiterter Shell-Pipelines verbessern (hartcodierte absolute Pfade entfernen)
- Referenz-Ein-/Ausgabe-Beispiele unter versionierten Sample-Assets hinzufügen
- `i18n/` mit gepflegten übersetzten README-Varianten füllen

## 🤝 Mitwirken

Beiträge sind willkommen.

Vorgeschlagener Ablauf:

1. Forke oder branche vom aktuellen Hauptzweig.
2. Halte Änderungen fokussiert und nutze kurze, imperative Commit-Messages.
3. Führe die relevanten von dir geänderten Befehle (CLI/Skriptpfad) aus und verifiziere die Ausgabe.
4. Aktualisiere README-Nutzungshinweise, wenn sich das Verhalten ändert.

Wenn du Tests hinzufügst, lege sie unter `tests/` ab und benenne Dateien als `test_*.py`.

## 📝 Hinweise

- Die ausgegebene SVG nutzt die Pixelmaße der Eingabe. Skaliere bei Bedarf in deinem Vektoreditor.
- Für die besten Ergebnisse starte mit einem kontrastreichen Bild.

## License

MIT
