[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lazyingchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Konvertiere KI-generierte Rasterbilder in saubere Vektor-SVGs.

Dieses Repository stellt eine Python-CLI bereit, die Kanten oder Binärformen in einem Bild erkennt und als SVG-Pfade schreibt. Es ist auf stilisierte, plotterfreundliche Vektorisierung ausgelegt statt auf fotorealistischem Tracing.

## 🎯 Kurzüberblick

| Ebene | Beschreibung | Ort |
|---|---|---|
| Kern-CLI | Rasterbilder mit einem einzelnen Befehl in SVG-Pfade umwandeln | [`aigi2vector.py`](aigi2vector.py) |
| PPTX-Hilfswerkzeuge | Folieninhalte extrahieren und Seiten für eine nachgelagerte Vektorisierung rendern | `scripts/` |
| Optionale Automatisierung | Größere KI-gestützte Extraktions- und Kompositions-Workflows | `AutoAppDev/`, `scripts/` |

## ✨ Überblick

`aigi2vector` enthält:

- Einen zentralen Raster-zu-SVG-CLI: [`aigi2vector.py`](aigi2vector.py)
- Optionale PPTX-Hilfswerkzeuge zum Extrahieren eingebetteter Bilder und Rendern von Folien zu PNG
- Zusätzliche Workflow-Skripte unter `scripts/` für Layout-Extraktion, Zuschneiden und KI-gestützte Pipelines
- Das Untermodul `AutoAppDev/` (externes Tooling; nicht erforderlich für die Haupt-CLI)

| Punkt | Details |
|---|---|
| Kernzweck | Rasterbilder in SVG-Pfade umwandeln |
| Primärer Modus | Einzelne Python-CLI-Datei |
| Kernabhängigkeiten | `opencv-python`, `numpy` |
| Optionale Workflows | PPTX-Extraktion/-Rendern, KI-gestützte Script-Pipelines |

## 🚀 Funktionen

- Konvertiere Rasterbilder in SVG-Pfade mit zwei Modi:
  - `edges`: Kanten­erkennung auf Basis von Canny
  - `binary`: Formextraktion über Schwellwertsetzung
- Optionen für die Vorverarbeitung:
  - Gaußscher Weichzeichner (`--blur`)
  - Optionale Invertierung (`--invert`)
- Pfadvereinfachung mit Douglas-Peucker-Näherung (`--epsilon`)
- SVG-Ausgabe, die die Eingangspixelgröße über `width`, `height` und `viewBox` beibehält
- PPTX-Bildwerkzeuge:
  - Eingebettete Bilder nach Folien extrahieren
  - Seiten als `page1.png`, `page2.png`, ... rendern

## 🗂️ Projektstruktur

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git-Untermodul (optional für die Kern-CLI)
├── i18n/                            # Übersetzungsordner (derzeit Gerüst/leer)
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

### Optionale PPTX-Hilfswerkzeuge

- Für `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Für `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` oder `libreoffice` im `PATH`)
  - `PyMuPDF` (`fitz`)
- Optionale Hilfs-Setups:
  - Conda (für `scripts/setup_conda_env.sh`)

### Optionale fortgeschrittene Pipelines

Mehrere Skripte unter `scripts/` nutzen externe Tools/Services (zum Beispiel die `codex`-CLI und GRS-AI-APIs). Diese sind optional und nicht nötig, um `aigi2vector.py` auszuführen.

## 🛠️ Installation

### Schneller Start (bestehender kanonischer Ablauf)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Optionale Conda-Einrichtung für PPTX-Hilfswerkzeuge

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Verwendung

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI-Optionen

| Option | Standard | Beschreibung |
|---|---|---|
| `--mode edges|binary` | `edges` | Vektorisierungsmodus |
| `--canny LOW HIGH` | `100 200` | Untere/obere Schwellen für den Edges-Modus |
| `--threshold N` | `128` | Binärer Schwellwert im `binary`-Modus |
| `--invert` | aus | Schwarz/Weiß vor Konturenerkennung invertieren |
| `--blur K` | `3` | Kernelgröße für Gaußschen Weichzeichner (ungerade Ganzzahl) |
| `--epsilon E` | `1.5` | Kurvenvereinfachung; höher = weniger Punkte |

### So funktionieren die Modi

- Im Modus `edges` wird eine Canny-Kantenerkennung ausgeführt und externe Konturen verfolgt.
- Im Modus `binary` werden Graustufenwerte geschwelligt und externe Konturen der resultierenden Maske verfolgt.

## ⚙️ Konfiguration

### Haupt-CLI-Parametereinstellungen

- `--canny LOW HIGH`:
  - Niedrigere Werte erfassen mehr Details/Rauschen.
  - Höhere Werte erzeugen sauberere, aber ggf. spärlichere Konturen.
- `--threshold` (Binary-Modus):
  - Niedrigere Schwelle behält mehr helle Bereiche als Vordergrund.
  - Höhere Schwelle behält vor allem dunkle/high-contrast-Bereiche.
- `--blur`:
  - Wird intern automatisch auf eine positive ungerade Kernelgröße normalisiert.
  - Größere Werte glätten Rauschen vor der Konturenerkennung.
- `--epsilon`:
  - Größere Werte vereinfachen Pfade aggressiver (weniger Punkte).
  - Kleinere Werte erhalten Formdetails.

### Umgebungsvariablen (erweiterte Skripte)

- `GRSAI` wird von GRS-AI-Extraktionsskripten benötigt (z. B. `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Hinweis zur Annahme: Diese fortgeschrittenen Skripte sind umgebungsspezifisch und derzeit teilweise nicht vollständig dokumentiert in der aktuellen README; die untenstehenden Kommandos halten sich am Verhalten des Repositories, ohne plattformübergreifende Portabilität auf jedem Rechner zu garantieren.

## 🧪 Beispiele

### Raster zu SVG

Kanten (gut für Line Art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binärformen (gut für Logos / flache Grafik):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX-Bildextraktion

Wenn du eingebettete Bilder aus einer `.pptx` extrahieren musst (z. B. ein oder zwei Bilder pro Folie), nutze:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /pfad/zu/datei.pptx /pfad/zu/ausgabe_ordner
```

Nutze `--dedupe`, um doppelte Bilder über Folien hinweg zu überspringen. Nutze `--png`, um Dateien als `p{slide}image{index}.png` zu speichern.

### Folien als Bilder rendern

Um jede Folie als `page1.png`, `page2.png`, ... zu rendern, installiere LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /pfad/zu/datei.pptx /pfad/zu/ausgabe_ordner
```

Oder nutze den Python-Renderer (verwendet ebenfalls LibreOffice und konvertiert PDF-Seiten anschließend in PNG):

```bash
python scripts/render_pptx_slides.py /pfad/zu/datei.pptx /pfad/zu/ausgabe_ordner --dpi 200
```

### Optionale fortgeschrittene Workflows (Skripte)

Diese Skripte sind im Repo enthalten und können für größere Zerlegungs-/Rekonstruktions-Pipelines verwendet werden:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Wichtig: Einige dieser Skripte enthalten aktuell fest verdrahtete, maschinenspezifische absolute Pfade und Abhängigkeiten von externen Diensten; passe sie vor Produktionseinsatz an.

## 🛠️ Entwicklungshinweise

- Die Hauptimplementierung ist eine CLI in einer einzigen Python-Datei: [`aigi2vector.py`](aigi2vector.py)
- Halte Funktions-/Variablennamen in `snake_case` und Konstanten in `UPPER_SNAKE_CASE`
- Bevorzuge kleine, testbare Funktionen gegenüber monolithischen Blöcken
- Es existiert aktuell keine formale Testsuite
- `AIGI/` wird von Git ignoriert und ist für lokale Assets vorgesehen

## 🛟 Fehlerbehebung

- `FileNotFoundError` für Eingabebild/PPTX:
  - Prüfe, ob der Eingabepfad korrekt und lesbar ist.
- `Could not read image`:
  - Bestätige, dass das Bildformat von OpenCV unterstützt wird und die Datei nicht beschädigt ist.
- Leere oder schlechte SVG-Ausgabe:
  - Probiere `--mode binary` mit angepasstem `--threshold`.
  - Passe die `--canny`-Schwellen im `edges`-Modus an.
  - Verringere `--epsilon`, um mehr Konturpunkte zu erhalten.
  - Beginne mit einem kontrastreicheren Quellbild.
- `LibreOffice (soffice) not found in PATH`:
  - Installiere LibreOffice und stelle sicher, dass `soffice` oder `libreoffice` in deiner Shell auffindbar ist.
- Fehlende Python-Pakete für Skriptabläufe:
  - Installiere die erforderlichen Abhängigkeiten für den jeweiligen Skript-Pfad (`python-pptx`, `Pillow`, `PyMuPDF` usw.).
- GRS-AI-Skripte schlagen bei Authentifizierung fehl:
  - Exportiere deinen Schlüssel, zum Beispiel: `export GRSAI=...`.

## 🗺️ Roadmap

Mögliche nächste Verbesserungen:

- Automatisierte Tests unter `tests/` mit deterministischen Beispieldateien hinzufügen
- Einheitliche optionale Abhängigkeitsgruppen für Skript-Workflows veröffentlichen
- Portabilität fortgeschrittener Shell-Pipelines verbessern (hardcodierte absolute Pfade entfernen)
- Referenz-Ein-/Ausgabe-Beispiele unter versionierten Beispieldateien ergänzen
- `i18n/` mit gepflegten übersetzten README-Varianten füllen

## 🤝 Mitwirken

Beiträge sind willkommen.

Empfohlener Ablauf:

1. Forke oder erstelle einen Branch vom aktuellen Mainline.
2. Halte Änderungen fokussiert und verwende kurze, imperative Commit-Nachrichten.
3. Führe die geänderten CLI-/Skriptpfade mit den relevanten Kommandos aus und prüfe die Ausgabe.
4. Aktualisiere die README-Nutzungshinweise bei Verhaltensänderungen.

Wenn du Tests ergänzt, lege sie unter `tests/` an und benenne Dateien `test_*.py`.

## 📝 Hinweise

- Die Ausgabe-SVG nutzt die Pixelabmessungen des Eingabebildes. Skaliere bei Bedarf in deinem Vektoreditor.
- Für beste Ergebnisse beginne mit einem hochkontrastigen Bild.

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
