[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Wandle KI-generierte Rasterbilder in saubere, plotterfreundliche SVG-Vektoren um.

Dieses Repository bietet eine Python-CLI, die Kanten oder Binärformen in einem Bild erkennt und als SVG-Pfade ausgibt. Es ist für stilisierte, plotterfreundliche Vektorisierung ausgelegt und nicht für photorealistische Spurverfolgung.

## 🧰 Auf einen Blick (Schnellmatrix)

| Bereich | Ort | Zweck |
|---|---|---|
| Kern-Konvertierung | [`aigi2vector.py`](aigi2vector.py) | Raster-/PPTX-extrahierte Bilder in SVG umwandeln |
| Optionale PPTX-Helfer | `scripts/` | Folien-Assets extrahieren und rendern |
| Erweiterte Automatisierung | `AutoAppDev/` | Optionaler externer Automatisierungs-Stack |

---

## 📚 Inhaltsverzeichnis

- [Auf einen Blick](#-auf-einen-blick-schnellmatrix)
- [Übersicht](#-übersicht)
- [Merkmale](#-merkmale)
- [Projektstruktur](#-projektstruktur)
- [Voraussetzungen](#-voraussetzungen)
- [Installation](#-installation)
- [Verwendung](#-verwendung)
- [Visueller Workflow](#-visueller-workflow)
- [Konfiguration](#-konfiguration)
- [Beispiele](#-beispiele)
- [Entwicklungsnotizen](#-entwicklungshinweise)
- [Fehlerbehebung](#-fehlerbehebung)
- [Roadmap](#-roadmap)
- [Mitwirken](#-mitwirken)
- [Hinweise](#-hinweise)
- [Support](#️-support)
- [Lizenz](#lizenz)

## 🧭 Auf einen Blick (Schnellkarte)

| Anwendungsfall | Einstiegspunkt | Ausgabe |
|---|---|---|
| Ein Bild in SVG konvertieren | `python aigi2vector.py input.png output.svg` | `output.svg` |
| Ausgabedetails anpassen | CLI-Flags in [`Verwendung`](#-verwendung) (`--mode`, `--canny`, `--epsilon` usw.) | Sauberere oder dichte Konturen |
| PPTX-Assets verarbeiten | `scripts/`-Hilfen + optionale Conda-Umgebung | Extrahierte Bilder + gerenderte Folien-PNGs |

## 🎯 Auf einen Blick

| Ebene | Beschreibung | Ort |
|---|---|---|
| Kern-CLI | Rasterbilder per Single-Command in SVG-Pfade umwandeln | [`aigi2vector.py`](aigi2vector.py) |
| PPTX-Helfer | Folieninhalte entnehmen und Seiten für die nachgelagerte Vektorisierung rendern | `scripts/` |
| Optionale Automatisierung | Größere KI-gestützte Workflows für Extraktion und Komposition | `AutoAppDev/`, `scripts/` |

## ✨ Überblick

`aigi2vector` umfasst:

- Eine zentrale Raster-zu-SVG-CLI: [`aigi2vector.py`](aigi2vector.py)
- Optionale PPTX-Helfer zum Extrahieren eingebetteter Bilder und Rendern von Folien zu PNG
- Zusätzliche Workflow-Skripte in `scripts/` für Layout-Extraktion, Zuschneiden und KI-gestützte Pipelines
- Ein `AutoAppDev/`-Submodul (externes Tooling; nicht für die Kern-CLI erforderlich)

| Punkt | Details |
|---|---|
| Hauptzweck | Rasterbilder in SVG-Pfad-Output konvertieren |
| Primärmodus | Einzeldateien-Python-CLI |
| Kernabhängigkeiten | `opencv-python`, `numpy` |
| Optionale Workflows | PPTX-Extraktion/Rendering, KI-gestützte Skript-Pipelines |

## 🚀 Merkmale

- Rasterbilder mit zwei Modi in SVG-Pfade konvertieren:
  - `edges`: Canny-basierte Kantenerkennung
  - `binary`: Schwellwertbasierte Formextraktion
- Vorverarbeitungs-Optionen:
  - Gauß-Weichzeichnen (`--blur`)
  - Optionale Invertierung (`--invert`)
- Pfadvereinfachung mit Douglas-Peucker-Approximation (`--epsilon`)
- SVG-Ausgabe, die die Eingangspixelmaße über `width`, `height` und `viewBox` beibehält
- PPTX-Bildwerkzeuge:
  - Eingebettete Bilder pro Folie extrahieren
  - Folienseiten als `page1.png`, `page2.png`, ... rendern

## 🗂️ Projektstruktur

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git-Submodul (optional für die Kern-CLI)
├── i18n/                            # Übersetzungsverzeichnis (momentan gerüstet/leer)
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
  - LibreOffice (`soffice` oder `libreoffice` im `PATH`)
  - `PyMuPDF` (`fitz`)
- Optionale Hilfseinrichtung:
  - Conda (für `scripts/setup_conda_env.sh`)

### Optionale erweiterte Pipelines

Mehrere Skripte unter `scripts/` nutzen externe Tools/Dienste (z. B. `codex` CLI und GRS AI APIs). Diese sind optional und nicht erforderlich, um `aigi2vector.py` auszuführen.

## 🛠️ Installation

### Schnellstart (bestehender Standardablauf)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Optionale Conda-Einrichtung für PPTX-Werkzeuge

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Verwendung

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI-Optionen

| Option | Standardwert | Beschreibung |
|---|---|---|
| `--mode edges|binary` | `edges` | Vektorisierungsmodus |
| `--canny LOW HIGH` | `100 200` | Niedrige/hohe Schwellwerte für den `edges`-Modus |
| `--threshold N` | `128` | Binärer Schwellwert im `binary`-Modus |
| `--invert` | aus | Schwarz/Weiß vor der Konturenfindung invertieren |
| `--blur K` | `3` | Kernelgröße für Gaußsches Weichzeichnen (ungerade Ganzzahl) |
| `--epsilon E` | `1.5` | Kurvenvereinfachung; höher = weniger Punkte |

### Funktionsweise der Modi

- Der `edges`-Modus führt Canny-Kantenerkennung aus und verfolgt externe Konturen.
- Der `binary`-Modus berechnet einen Schwellwert auf Graustufenbildern und verfolgt externe Konturen der resultierenden Maske.

## 🔧 Visueller Workflow

```text
Eingabebild/PPTX-Folien-Assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (optional)
   |
   v
Raster-Triangulierung + Konturenvereinfachung
   |
   v
SVG-Ausgabe
```

## ⚙️ Konfiguration

### Abstimmung der wichtigsten CLI-Parameter

- `--canny LOW HIGH`:
  - Niedrigere Werte erfassen mehr Details/Rauschen.
  - Höhere Werte liefern sauberere, aber potenziell spärlichere Konturen.
- `--threshold` (`binary`-Modus):
  - Niedrige Werte behalten mehr helle Regionen als Vordergrund.
  - Hohe Werte behalten überwiegend dunkle/hohen Kontrast Regionen.
- `--blur`:
  - Wird intern automatisch auf eine positive ungerade Kerngröße normalisiert.
  - Größere Werte glätten Rauschen vor der Konturenfindung.
- `--epsilon`:
  - Größere Werte vereinfachen Pfade stärker (weniger Punkte).
  - Kleinere Werte erhalten mehr Formen-Details.

### Umgebungsvariablen (erweiterte Skripte)

- `GRSAI` wird von GRS-AI-Extraktionsskripten benötigt (z. B. `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Annahme-Hinweis: Erweiterte Skripte sind umfeldspezifisch und im aktuellen README nur teilweise dokumentiert; die folgenden Befehle bilden das repositoriespezifische Verhalten korrekt ab, ohne Portabilität auf allen Systemen zu garantieren.

## 🧪 Beispiele

### Raster zu SVG

Kanten (gut für Strichzeichnungen):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binärformen (gut für Logos / Flat-Art):

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

Füge `--dedupe` hinzu, um doppelte Bilder über Folien hinweg zu überspringen. Mit `--png` werden Dateien als `p{slide}image{index}.png` gespeichert.

### Folien als Bilder rendern

Um jede Folie als `page1.png`, `page2.png`, ... zu rendern, musst du LibreOffice (`soffice`) installiert haben:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Oder nutze den Python-Renderer (verwendet ebenfalls LibreOffice, anschließend werden PDF-Seiten in PNG konvertiert):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optionale erweiterte Workflows (Skripte)

Diese Skripte sind im Repo enthalten und können für größere Zerlege-/Rekonstruktions-Pipelines verwendet werden:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Wichtig: Einige dieser Skripte enthalten derzeit maschinen- und pfadspezifische absolute Pfade sowie externe Service-Abhängigkeiten; passe sie vor dem produktiven Einsatz an.

## 🧰 Entwicklungsnotizen

- Die Hauptimplementierung ist eine einzelne Python-CLI: [`aigi2vector.py`](aigi2vector.py)
- Behalte Funktions- und Variablennamen in `snake_case`, Konstanten in `UPPER_SNAKE_CASE`
- Bevorzuge kleine, testbare Funktionen statt monolithischer Blöcke
- Es gibt aktuell keine formelle Test-Suite
- `AIGI/` ist von Git ignoriert und für lokale Assets gedacht

## 🛟 Fehlerbehebung

- `FileNotFoundError` für Eingabebild/PPTX:
  - Prüfe, ob der Eingabepfad korrekt und lesbar ist.
- `Could not read image`:
  - Prüfe, ob das Dateiformat von OpenCV unterstützt wird und die Datei nicht beschädigt ist.
- Leere oder schlechte SVG-Ausgabe:
  - Probiere `--mode binary` mit angepasstem `--threshold`.
  - Passe die `--canny`-Schwellen im `edges`-Modus an.
  - Reduziere `--epsilon`, um mehr Konturpunkte zu erhalten.
  - Starte mit einem Bild mit höherem Kontrast.
- `LibreOffice (soffice) not found in PATH`:
  - Installiere LibreOffice und stelle sicher, dass `soffice` oder `libreoffice` in deiner Shell auffindbar ist.
- Fehlende Python-Pakete in Skript-Flows:
  - Installiere die benötigten Abhängigkeiten für den jeweiligen Skriptpfad (`python-pptx`, `Pillow`, `PyMuPDF` usw.).
- GRS-AI-Skripte schlagen mit Authentifizierungsfehlern fehl:
  - Exportiere deinen Schlüssel, zum Beispiel: `export GRSAI=...`.

## 🗺️ Roadmap

Mögliche nächste Verbesserungen:

- Testfälle unter `tests/` mit deterministischen Beispielbildern hinzufügen
- Einheitliche optionale Abhängigkeitsgruppen für Script-Workflows bereitstellen
- Portabilität von erweiterten Shell-Pipelines verbessern (harte absolute Pfade entfernen)
- Referenz-Eingabe-/Ausgabe-Beispiele unter versionierten Musterdateien ergänzen
- `i18n/` mit gepflegten README-Übersetzungen füllen

## 🤝 Mitwirken

Beiträge sind willkommen.

Empfohlener Ablauf:

1. Fork oder Branch vom aktuellen Mainline erstellen.
2. Änderungen fokussiert halten und kurze, imperative Commit-Messages verwenden.
3. Relevante geänderte Befehle ausführen und die Ausgabe überprüfen.
4. README-Nutzungshinweise bei Verhaltensänderungen aktualisieren.

Wenn du Tests hinzufügst, lege sie unter `tests/` ab und benenne Dateien als `test_*.py`.

## 📝 Hinweise

- Das Ausgabe-SVG verwendet die Pixel-Dimensionen des Eingabebildes. Skaliere bei Bedarf in deinem Vektorgrafik-Editor.
- Für beste Ergebnisse beginne mit einem hochkontrastigen Bild.

## Lizenz

MIT


## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |
