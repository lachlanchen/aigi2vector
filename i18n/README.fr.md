[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Convertit des images raster générées par l'IA en SVG vectoriels propres pour le traçage.

Ce dépôt fournit une CLI Python qui détecte les bords ou les formes binaires dans une image, puis les écrit sous forme de chemins SVG. Il est conçu pour une vectorisation orientée traceur, stylisée, plutôt que pour un traçage photo-réaliste.

## 🧰 At a Glance (Quick Matrix)

| Domaine | Emplacement | Objectif |
|---|---|---|
| Conversion principale | [`aigi2vector.py`](aigi2vector.py) | Convertir les images raster/PPTX en SVG |
| Utilitaires PPTX optionnels | `scripts/` | Extraire et rendre les ressources de diapositives |
| Automatisation étendue | `AutoAppDev/` | Pile d'automatisation externe optionnelle |

---

## 📚 Table of Contents

- [At a Glance](#-at-a-glance-quick-map)
- [Overview](#-overview)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Visual Workflow](#-visual-workflow)
- [Configuration](#-configuration)
- [Examples](#-examples)
- [Development Notes](#-development-notes)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [Notes](#-notes)
- [Support](#️-support)
- [License](#license)

## 🧭 At a Glance (Quick Map)

| Cas d'usage | Point d'entrée | Sortie |
|---|---|---|
| Convertir une image en SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| Ajuster le niveau de détail | Options CLI dans [`Usage`](#-usage) (`--mode`, `--canny`, `--epsilon`, etc.) | Contours plus propres ou plus denses |
| Traiter des ressources PPTX | `scripts/` et environnement Conda facultatif | Images extraites + PNG de diapositives rendues |

## 🎯 At a Glance

| Couche | Description | Emplacement |
|---|---|---|
| CLI principale | Convertir des images raster en chemins SVG en une commande | [`aigi2vector.py`](aigi2vector.py) |
| Outils PPTX | Extraire le contenu des diapositives et rendre les pages pour la vectorisation ultérieure | `scripts/` |
| Automatisation optionnelle | Workflows plus larges assistés par IA pour extraction et composition | `AutoAppDev/`, `scripts/` |

## ✨ Overview

`aigi2vector` inclut :

- Une CLI core raster-vers-SVG : [`aigi2vector.py`](aigi2vector.py)
- Des utilitaires PPTX optionnels pour extraire les images intégrées et rendre les diapositives en PNG
- Des scripts de workflow supplémentaires dans `scripts/` pour l'extraction de mise en page, le recadrage et les pipelines assistés par IA
- Un sous-module `AutoAppDev/` (outillage externe ; non requis pour la CLI principale)

| Élément | Détails |
|---|---|
| Objectif principal | Convertir des images raster en chemins SVG |
| Mode principal | CLI Python monofichier |
| Dépendances principales | `opencv-python`, `numpy` |
| Workflows optionnels | Extraction/rendu PPTX, pipelines de scripts assistés par IA |

## 🚀 Features

- Convertir des images raster en chemins SVG via deux modes :
  - `edges` : détection de contours basée sur Canny
  - `binary` : extraction de formes par seuillage
- Contrôles de prétraitement :
  - Flou gaussien (`--blur`)
  - Inversion optionnelle (`--invert`)
- Simplification des chemins via l'approximation de Douglas-Peucker (`--epsilon`)
- Sortie SVG préservant les dimensions en pixels d'entrée via `width`, `height` et `viewBox`
- Utilitaires PPTX :
  - Extraire les images intégrées par diapositive
  - Rendre les pages en `page1.png`, `page2.png`, ...

## 🗂️ Project Structure

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (optionnel pour la CLI principale)
├── i18n/                            # Répertoire de traduction (actuellement scaffold/empty)
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

## 📦 Prerequisites

### Core CLI

- Python 3
- `pip`
- Dépendances depuis [`requirements.txt`](requirements.txt) :
  - `opencv-python`
  - `numpy`

### Outils PPTX optionnels

- Pour `scripts/extract_pptx_images.py` :
  - `python-pptx`
  - `Pillow`
- Pour `scripts/render_pptx_slides.py` :
  - LibreOffice (`soffice` ou `libreoffice` dans le `PATH`)
  - `PyMuPDF` (`fitz`)
- Configuration helper optionnelle :
  - Conda (pour `scripts/setup_conda_env.sh`)

### Pipelines avancés optionnels

Plusieurs scripts dans `scripts/` reposent sur des outils/services externes (par exemple le CLI `codex` et les API GRS AI). Ils sont optionnels et ne sont pas requis pour exécuter `aigi2vector.py`.

## 🛠️ Installation

### Démarrage rapide (flux canonique existant)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Configuration Conda optionnelle pour les utilitaires PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Usage

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI Options

| Option | Défaut | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | Mode de vectorisation |
| `--canny LOW HIGH` | `100 200` | Seuils bas/haut pour le mode edges |
| `--threshold N` | `128` | Seuil binaire utilisé en mode `binary` |
| `--invert` | off | Inverser noir/blanc avant détection des contours |
| `--blur K` | `3` | Taille du noyau de flou gaussien (entier impair) |
| `--epsilon E` | `1.5` | Simplification de courbe ; plus élevé = moins de points |

### Fonctionnement des modes

- Le mode `edges` exécute la détection de bords Canny et trace les contours externes.
- Le mode `binary` applique un seuillage en niveaux de gris et trace les contours externes du masque résultant.

## 🔧 Visual Workflow

```text
Input image/PPTX slide assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (optionnel)
   |
   v
Raster tracing + contour simplification
   |
   v
SVG output
```

## ⚙️ Configuration

### Réglage des paramètres principaux de la CLI

- `--canny LOW HIGH` :
  - Des valeurs plus faibles capturent plus de détails/bruit.
  - Des valeurs plus élevées produisent des contours plus nets mais parfois plus clairsemés.
- `--threshold` (mode binaire) :
  - Un seuil plus bas conserve davantage de zones claires en premier plan.
  - Un seuil plus haut conserve surtout les zones sombres/à fort contraste.
- `--blur` :
  - Normalisé automatiquement en noyau impair positif en interne.
  - Des valeurs plus importantes lissent le bruit avant la détection de contours.
- `--epsilon` :
  - Des valeurs plus élevées simplifient plus agressivement les chemins (moins de points).
  - Des valeurs plus faibles préservent plus de détails de forme.

### Variables d'environnement (scripts avancés)

- `GRSAI` est requis par les scripts d'extraction GRS AI (par exemple `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Remarque : les scripts avancés sont spécifiques à un environnement et partiellement non documentés dans la base actuelle du README ; les commandes ci-dessous gardent le comportement fidèle au dépôt sans garantir la portabilité sur toutes les machines.

## 🧪 Examples

### Raster to SVG

Bords (idéal pour l'art de ligne) :

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Shapes binaires (idéal pour les logos / illustrations plates) :

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX image extraction

Si vous devez extraire des images intégrées d'un `.pptx` (par ex. une ou deux images par diapositive), utilisez :

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Ajoutez `--dedupe` pour ignorer les doublons d'images entre diapositives. Ajoutez `--png` pour enregistrer les fichiers sous la forme `p{slide}image{index}.png`.

### Rendre les diapositives en images

Pour rendre chaque diapositive en `page1.png`, `page2.png`, ... vous devez avoir LibreOffice (`soffice`) installé :

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Ou utilisez le moteur Python (qui utilise aussi LibreOffice, puis convertit les pages PDF en PNG) :

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Workflows avancés optionnels (scripts)

Ces scripts sont présents dans le dépôt et peuvent alimenter des pipelines plus vastes de découpage/recomposition :

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Important : certains de ces scripts contiennent encore des chemins absolus dépendants d'une machine et des dépendances à des services externes ; adaptez-les avant usage en production.

## 🧰 Development Notes

- L'implémentation principale est une CLI Python monofichier : [`aigi2vector.py`](aigi2vector.py)
- Conserver les noms de fonctions/variables en `snake_case` et les constantes en `UPPER_SNAKE_CASE`
- Privilégier des fonctions petites et testables plutôt que des blocs monolithiques
- Aucune suite de tests formelle n'est actuellement disponible
- `AIGI/` est ignoré par git et sert aux ressources locales

## 🛟 Troubleshooting

- `FileNotFoundError` pour une image/PPTX d'entrée :
  - Vérifiez que le chemin d'entrée est correct et lisible.
- `Could not read image` :
  - Vérifiez que le format de fichier est supporté par OpenCV et n'est pas corrompu.
- Sortie SVG vide ou de mauvaise qualité :
  - Essayez `--mode binary` avec `--threshold` ajusté.
  - Ajustez les seuils `--canny` en mode `edges`.
  - Réduisez `--epsilon` pour conserver davantage de points de contour.
  - Utilisez une image source plus contrastée.
- `LibreOffice (soffice) not found in PATH` :
  - Installez LibreOffice et vérifiez que `soffice` ou `libreoffice` est accessible dans votre shell.
- Packages Python manquants pour les flux de scripts :
  - Installez les dépendances nécessaires pour le flux utilisé (`python-pptx`, `Pillow`, `PyMuPDF`, etc.).
- Les scripts GRS AI échouent avec des erreurs d'authentification :
  - Exportez votre clé, par exemple : `export GRSAI=...`.

## 🗺️ Roadmap

Améliorations potentielles prévues :

- Ajouter des tests automatisés sous `tests/` avec des images d'échantillon déterministes
- Publier des jeux de dépendances optionnelles unifiés pour les workflows de scripts
- Améliorer la portabilité des pipelines shell avancés (suppression de chemins absolus codés en dur)
- Ajouter des exemples d'entrée/sortie de référence avec ressources versionnées
- Remplir `i18n/` avec des traductions de README maintenues

## 🤝 Contributing

Les contributions sont bienvenues.

Processus proposé :

1. Forker ou créer une branche depuis la branche principale actuelle.
2. Garder les changements ciblés et utiliser des messages de commit courts et impératifs.
3. Exécuter les commandes pertinentes qui ont changé (CLI/chemins de scripts) et vérifier la sortie.
4. Mettre à jour les notes d'utilisation dans le README lorsque le comportement change.

Si vous ajoutez des tests, placez-les sous `tests/` et nommez les fichiers `test_*.py`.

## 📝 Notes

- Le SVG de sortie utilise les dimensions en pixels de l'entrée. Ajustez l'échelle dans votre éditeur vectoriel si nécessaire.
- Pour de meilleurs résultats, commencez par une image à fort contraste.

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
