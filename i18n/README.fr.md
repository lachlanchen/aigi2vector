[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Convertissez des images raster générées par IA en fichiers SVG vectoriels propres pour impression/dessin.

Ce dépôt fournit une CLI Python qui détecte les contours ou les formes binaires d'une image et les écrit en chemins SVG. Il est conçu pour une vectorisation de type stylisé, adaptée aux traceurs, plutôt qu'un tracing photoréaliste.

## 🎯 En bref

| Couche | Description | Emplacement |
|---|---|---|
| CLI principale | Convertit les images raster en chemins SVG en une seule commande | [`aigi2vector.py`](aigi2vector.py) |
| Outils PPTX | Extrait le contenu des diapositives et rend les pages pour une vectorisation en aval | `scripts/` |
| Automatisation optionnelle | Flux plus larges assistés par IA pour extraction et composition | `AutoAppDev/`, `scripts/` |

## ✨ Aperçu

`aigi2vector` comprend :

- Une CLI principale de raster vers SVG : [`aigi2vector.py`](aigi2vector.py)
- Des utilitaires PPTX optionnels pour extraire les images intégrées et rendre des diapositives en PNG
- Des scripts de workflow additionnels sous `scripts/` pour l'extraction de mise en page, le recadrage et des pipelines assistés par IA
- Un sous-module `AutoAppDev/` (outillage externe ; non requis pour la CLI principale)

| Élément | Détails |
|---|---|
| Objectif principal | Convertir des images raster en sortie de chemins SVG |
| Mode principal | CLI Python en fichier unique |
| Dépendances principales | `opencv-python`, `numpy` |
| Workflows optionnels | Extraction/rendu PPTX, pipelines de scripts assistés par IA |

## 🚀 Fonctionnalités

- Convertir des images raster en chemins SVG via deux modes :
  - `edges` : détection de contours basée sur Canny
  - `binary` : extraction de formes via seuillage
- Contrôles de prétraitement :
  - Flou gaussien (`--blur`)
  - Inversion optionnelle (`--invert`)
- Simplification de polylignes avec l'approximation de Douglas-Peucker (`--epsilon`)
- Sortie SVG qui préserve les dimensions en pixels d'entrée via `width`, `height` et `viewBox`
- Utilitaires d'images PPTX :
  - Extraire les images intégrées par diapositive
  - Rendre les pages des diapositives en `page1.png`, `page2.png`, ...

## 🗂️ Structure du projet

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Sous-module Git (facultatif pour la CLI principale)
├── i18n/                            # Répertoire de traduction (actuellement en préambule/ vide)
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
- Dépendances depuis [`requirements.txt`](requirements.txt) :
  - `opencv-python`
  - `numpy`

### Utilitaires PPTX optionnels

- Pour `scripts/extract_pptx_images.py` :
  - `python-pptx`
  - `Pillow`
- Pour `scripts/render_pptx_slides.py` :
  - LibreOffice (`soffice` ou `libreoffice` dans le `PATH`)
  - `PyMuPDF` (`fitz`)
- Configuration d'aide optionnelle :
  - Conda (pour `scripts/setup_conda_env.sh`)

### Pipelines avancés optionnels

Plusieurs scripts dans `scripts/` dépendent d'outils/services externes (par exemple le CLI `codex` et les API GRS AI). Ils sont optionnels et ne sont pas requis pour exécuter `aigi2vector.py`.

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
| `--invert` | off | Inverser noir/blanc avant la détection de contours |
| `--blur K` | `3` | Taille du noyau de flou gaussien (entier impair) |
| `--epsilon E` | `1.5` | Simplification des courbes ; plus haut = moins de points |

### Fonctionnement des modes

- Le mode `edges` exécute la détection de contours Canny et trace les contours externes.
- Le mode `binary` applique un seuillage de niveaux de gris et trace les contours externes du masque obtenu.

## ⚙️ Configuration

### Ajustement des paramètres principaux de la CLI

- `--canny LOW HIGH` :
  - Des valeurs plus faibles capturent plus de détails/bruit.
  - Des valeurs plus élevées donnent des contours plus propres mais potentiellement plus clairsemés.
- `--threshold` (mode binary) :
  - Un seuil bas conserve plus de zones claires en premier plan.
  - Un seuil élevé conserve surtout les zones sombres/à fort contraste.
- `--blur` :
  - Normalisé automatiquement en interne vers un noyau impair positif.
  - Des valeurs plus grandes atténuent le bruit avant la détection de contours.
- `--epsilon` :
  - Des valeurs plus élevées simplifient davantage les chemins (moins de points).
  - Des valeurs plus faibles conservent plus de détails de forme.

### Variables d'environnement (scripts avancés)

- `GRSAI` est requis par les scripts d'extraction GRS AI (par exemple `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Note d'hypothèse : les scripts avancés sont dépendants de l'environnement et partiellement non documentés dans l'état actuel du README ; les commandes ci-dessous conservent le comportement exact du dépôt sans garantir la portabilité sur toutes les machines.

## 🧪 Exemples

### Raster vers SVG

Contours (idéal pour l'art vectoriel de lignes) :

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Formes binaires (idéal pour logos / illustrations plates) :

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Extraction d'images PPTX

Si vous devez extraire des images intégrées depuis un `.pptx` (par exemple une ou deux images par diapositive), utilisez :

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Ajoutez `--dedupe` pour ignorer les images dupliquées entre diapositives. Ajoutez `--png` pour enregistrer les fichiers sous le format `p{slide}image{index}.png`.

### Rendre des diapositives en images

Pour rendre chaque diapositive en `page1.png`, `page2.png`, ... vous devez avoir LibreOffice (`soffice`) installé :

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Ou utilisez le moteur Python (qui utilise aussi LibreOffice, puis convertit les pages PDF en PNG) :

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

Important : certains de ces scripts contiennent actuellement des chemins absolus spécifiques à une machine et des dépendances vers des services externes ; adaptez-les avant une utilisation en production.

## 🧰 Notes de développement

- L'implémentation principale est une CLI Python en un seul fichier : [`aigi2vector.py`](aigi2vector.py)
- Conservez des noms de fonctions/variables en `snake_case`, des constantes en `UPPER_SNAKE_CASE`
- Préférez de petites fonctions testables à des blocs monolithiques
- Aucun cadre de tests formels n'est présent actuellement
- `AIGI/` est ignoré par git et destiné aux assets locaux

## 🧭 Dépannage

- `FileNotFoundError` pour l'image/PPTX d'entrée :
  - Vérifiez que le chemin d'entrée est correct et lisible.
- `Could not read image` :
  - Confirmez que le format de fichier est pris en charge par OpenCV et non corrompu.
- Sortie SVG vide ou de mauvaise qualité :
  - Essayez `--mode binary` avec un `--threshold` ajusté.
  - Ajustez les seuils `--canny` en mode `edges`.
  - Réduisez `--epsilon` pour conserver plus de points de contour.
  - Commencez avec une source à contraste plus élevé.
- `LibreOffice (soffice) not found in PATH` :
  - Installez LibreOffice et assurez-vous que `soffice` ou `libreoffice` est détectable dans votre shell.
- Paquets Python manquants pour les flux de scripts :
  - Installez les dépendances requises pour ce flux de script (`python-pptx`, `Pillow`, `PyMuPDF`, etc.).
- Les scripts GRS AI échouent avec des erreurs d'authentification :
  - Exportez votre clé, par exemple : `export GRSAI=...`.

## 🗺️ Feuille de route

Améliorations possibles :

- Ajouter des tests automatisés dans `tests/` avec des images d'exemple déterministes
- Publier des groupes de dépendances optionnels unifiés pour les workflows de scripts
- Améliorer la portabilité des pipelines shell avancés (retirer les chemins absolus codés en dur)
- Ajouter des exemples d'entrée/sortie de référence sous des assets d'exemple versionnés
- Remplir le répertoire `i18n/` avec des README traduits et maintenus

## 🤝 Contribuer

Les contributions sont les bienvenues.

Processus suggéré :

1. Forker ou créer une branche depuis la branche principale actuelle.
2. Garder les changements ciblés et utiliser des messages de commit courts et à l'infinitif.
3. Exécuter les commandes concernées que vous avez modifiées (chemins CLI/script) et vérifier la sortie.
4. Mettre à jour les notes d'utilisation du README quand le comportement change.

Si vous ajoutez des tests, placez-les dans `tests/` et nommez-les `test_*.py`.

## 📝 Remarques

- La sortie SVG conserve les dimensions en pixels de l'entrée. Mettez à l'échelle dans votre éditeur vectoriel si nécessaire.
- Pour de meilleurs résultats, commencez avec une image à contraste élevé.

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## Licence

MIT
