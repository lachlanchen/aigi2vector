[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Convertissez des images raster générées par IA en SVG de tracés vectoriels propres.

Ce dépôt fournit une CLI Python qui détecte les contours ou formes binaires dans une image et les écrit sous forme de chemins SVG. Il est conçu pour une vectorisation stylisée, adaptée aux plotters, plutôt qu’au traçage photoréaliste.

## ✨ Vue d’ensemble

`aigi2vector` comprend :

- Une CLI principale de conversion raster vers SVG : [`aigi2vector.py`](aigi2vector.py)
- Des utilitaires PPTX optionnels pour extraire les images intégrées et rendre les diapositives en PNG
- Des scripts de workflow supplémentaires sous `scripts/` pour l’extraction de mise en page, le recadrage et des pipelines assistés par IA
- Un sous-module `AutoAppDev/` (outillage externe, non requis pour la CLI principale)

| Élément | Détails |
|---|---|
| Objectif principal | Convertir des images raster en sortie SVG basée sur des chemins |
| Mode principal | CLI Python en fichier unique |
| Dépendances principales | `opencv-python`, `numpy` |
| Workflows optionnels | Extraction/rendu PPTX, pipelines de scripts assistés par IA |

## 🚀 Fonctionnalités

- Conversion d’images raster en chemins SVG via deux modes :
  - `edges` : détection de contours basée sur Canny
  - `binary` : extraction de formes après seuillage
- Contrôles de prétraitement :
  - Flou gaussien (`--blur`)
  - Inversion optionnelle (`--invert`)
- Simplification des chemins via l’approximation de Douglas-Peucker (`--epsilon`)
- Sortie SVG qui préserve les dimensions en pixels de l’entrée via `width`, `height` et `viewBox`
- Utilitaires d’images PPTX :
  - Extraction des images intégrées par diapositive
  - Rendu des pages de diapositives en `page1.png`, `page2.png`, ...

## 🗂️ Structure du projet

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

## 📦 Prérequis

### CLI principale

- Python 3
- `pip`
- Dépendances de [`requirements.txt`](requirements.txt) :
  - `opencv-python`
  - `numpy`

### Utilitaires PPTX optionnels

- Pour `scripts/extract_pptx_images.py` :
  - `python-pptx`
  - `Pillow`
- Pour `scripts/render_pptx_slides.py` :
  - LibreOffice (`soffice` ou `libreoffice` dans `PATH`)
  - `PyMuPDF` (`fitz`)
- Configuration optionnelle d’assistance :
  - Conda (pour `scripts/setup_conda_env.sh`)

### Pipelines avancés optionnels

Plusieurs scripts sous `scripts/` s’appuient sur des outils/services externes (par exemple la CLI `codex` et les API GRS AI). Ils sont optionnels et non requis pour exécuter `aigi2vector.py`.

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

## ▶️ Utilisation

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Options CLI

| Option | Valeur par défaut | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | Mode de vectorisation |
| `--canny LOW HIGH` | `100 200` | Seuils bas/haut pour le mode edges |
| `--threshold N` | `128` | Seuil binaire utilisé en mode `binary` |
| `--invert` | off | Inverser noir/blanc avant la détection des contours |
| `--blur K` | `3` | Taille du noyau de flou gaussien (entier impair) |
| `--epsilon E` | `1.5` | Simplification de courbe ; plus élevé = moins de points |

### Fonctionnement des modes

- Le mode `edges` exécute une détection de contours Canny et trace les contours externes.
- Le mode `binary` applique un seuillage des pixels en niveaux de gris et trace les contours externes du masque résultant.

## ⚙️ Configuration

### Ajustement des paramètres de la CLI principale

- `--canny LOW HIGH` :
  - Des valeurs plus basses capturent plus de détails/bruit.
  - Des valeurs plus élevées produisent des contours plus propres mais potentiellement plus clairsemés.
- `--threshold` (mode binaire) :
  - Un seuil plus bas conserve davantage de régions claires au premier plan.
  - Un seuil plus élevé conserve principalement les régions sombres/à fort contraste.
- `--blur` :
  - Normalisé automatiquement en noyau impair positif en interne.
  - Des valeurs plus élevées lissent le bruit avant la détection des contours.
- `--epsilon` :
  - Des valeurs plus élevées simplifient les chemins de manière plus agressive (moins de points).
  - Des valeurs plus faibles préservent les détails de forme.

### Variables d’environnement (scripts avancés)

- `GRSAI` est requis par les scripts d’extraction GRS AI (par exemple `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Note d’hypothèse : les scripts avancés sont spécifiques à l’environnement et partiellement non documentés dans la base README actuelle ; les commandes ci-dessous conservent un comportement fidèle au dépôt sans garantir la portabilité sur toutes les machines.

## 🧪 Exemples

### Raster vers SVG

Edges (adapté au line art) :

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Formes binaires (adapté aux logos / aplats) :

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Extraction d’images PPTX

Si vous devez extraire des images intégrées depuis un `.pptx` (par ex., une ou deux images par diapositive), utilisez :

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Ajoutez `--dedupe` pour ignorer les images dupliquées entre diapositives. Ajoutez `--png` pour enregistrer les fichiers en `p{slide}image{index}.png`.

### Rendu des diapositives en images

Pour rendre chaque diapositive en `page1.png`, `page2.png`, ... LibreOffice (`soffice`) doit être installé :

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Ou utilisez le moteur de rendu Python (utilise aussi LibreOffice, puis convertit les pages PDF en PNG) :

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Workflows avancés optionnels (scripts)

Ces scripts existent dans le dépôt et peuvent être utilisés pour des pipelines de décomposition/reconstruction plus larges :

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Important : certains de ces scripts contiennent actuellement des chemins absolus spécifiques à une machine et des dépendances à des services externes ; adaptez-les avant une utilisation en production.

## 🧰 Notes de développement

- L’implémentation principale est une CLI Python en fichier unique : [`aigi2vector.py`](aigi2vector.py)
- Conserver `snake_case` pour les fonctions/variables, `UPPER_SNAKE_CASE` pour les constantes
- Préférer de petites fonctions testables plutôt que des blocs monolithiques
- Aucune suite de tests formelle n’est actuellement présente
- `AIGI/` est ignoré par git et destiné aux ressources locales

## 🛟 Dépannage

- `FileNotFoundError` pour une image/PPTX en entrée :
  - Vérifiez que le chemin d’entrée est correct et lisible.
- `Could not read image` :
  - Confirmez que le format de fichier est pris en charge par OpenCV et non corrompu.
- Sortie SVG vide ou de mauvaise qualité :
  - Essayez `--mode binary` avec un `--threshold` ajusté.
  - Ajustez les seuils `--canny` en mode `edges`.
  - Réduisez `--epsilon` pour conserver davantage de points de contour.
  - Partez d’une image source à contraste plus élevé.
- `LibreOffice (soffice) not found in PATH` :
  - Installez LibreOffice et assurez-vous que `soffice` ou `libreoffice` est détectable dans votre shell.
- Packages Python manquants pour les flux de scripts :
  - Installez les dépendances requises pour ce chemin de script (`python-pptx`, `Pillow`, `PyMuPDF`, etc.).
- Les scripts GRS AI échouent avec des erreurs d’authentification :
  - Exportez votre clé, par exemple : `export GRSAI=...`.

## 🗺️ Feuille de route

Améliorations potentielles à venir :

- Ajouter des tests automatisés sous `tests/` avec des images d’exemple déterministes
- Publier des groupes de dépendances optionnelles unifiés pour les workflows de scripts
- Améliorer la portabilité des pipelines shell avancés (suppression des chemins absolus codés en dur)
- Ajouter des exemples d’entrée/sortie de référence dans des ressources d’exemple versionnées
- Compléter `i18n/` avec des variantes README traduites et maintenues

## 🤝 Contribution

Les contributions sont les bienvenues.

Processus suggéré :

1. Forkez le dépôt ou créez une branche depuis la branche principale actuelle.
2. Gardez les changements ciblés et utilisez des messages de commit courts à l’impératif.
3. Exécutez les commandes pertinentes que vous avez modifiées (chemin CLI/script) et vérifiez la sortie.
4. Mettez à jour les notes d’utilisation du README quand le comportement change.

Si vous ajoutez des tests, placez-les sous `tests/` et nommez les fichiers `test_*.py`.

## 📝 Notes

- Le SVG de sortie utilise les dimensions en pixels de l’entrée. Redimensionnez dans votre éditeur vectoriel si nécessaire.
- Pour de meilleurs résultats, partez d’une image à fort contraste.

## License

MIT
