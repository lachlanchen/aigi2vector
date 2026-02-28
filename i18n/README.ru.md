[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Преобразуйте AI-генерированные растровые изображения в аккуратные SVG для векторной графики.

Этот репозиторий предоставляет CLI на Python, который находит края или бинарные формы на изображении и записывает их в виде SVG-путей. Он предназначен для стилизованной, удобной для плоттера векторизации, а не для фотореалистичной трассировки.

## 🧰 Краткая сводка (Quick Matrix)

| Раздел | Расположение | Назначение |
|---|---|---|
| Основное преобразование | [`aigi2vector.py`](aigi2vector.py) | Конвертировать растровые и извлечённые из PPTX изображения в SVG |
| Необязательные помощники PPTX | `scripts/` | Извлечение и рендеринг активов слайдов |
| Расширенная автоматизация | `AutoAppDev/` | Необязательный внешний стек автоматизации |

---

## 📚 Содержание

- [Краткая сводка](#-краткая-сводка-quick-matrix)
- [Обзор](#-обзор)
- [Возможности](#-возможности)
- [Структура проекта](#-структура-проекта)
- [Требования](#-требования)
- [Установка](#-установка)
- [Использование](#-использование)
- [Визуальный конвейер](#-визуальный-конвейер)
- [Настройки](#-настройки)
- [Примеры](#-примеры)
- [Заметки по разработке](#-заметки-по-разработке)
- [Устранение неполадок](#-устранение-неполадок)
- [Дорожная карта](#-дорожная-карта)
- [Вклад](#-вклад)
- [Заметки](#-заметки)
- [Support](#️-support)
- [Лицензия](#license)

## 🧭 Краткий взгляд (быстрая карта)

| Сценарий использования | Точка входа | Результат |
|---|---|---|
| Конвертировать одно изображение в SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| Настроить уровень детализации | Параметры CLI в разделе [Использование](#-использование) (`--mode`, `--canny`, `--epsilon` и др.) | Более чистые или более плотные контуры |
| Обработать активы PPTX | Помощники `scripts/` + необязательная среда conda | Извлечённые изображения + PNG слайдов |

## 🎯 Кратко

| Уровень | Описание | Расположение |
|---|---|---|
| Основной CLI | Конвертировать растровые изображения в SVG-пути одной командой | [`aigi2vector.py`](aigi2vector.py) |
| Утилиты PPTX | Извлекать содержимое слайдов и рендерить страницы для последующей векторизации | `scripts/` |
| Необязательная автоматизация | Расширенные AI-потоки для извлечения и сборки | `AutoAppDev/`, `scripts/` |

## ✨ Обзор

`aigi2vector` включает:

- Основной CLI raster-to-SVG: [`aigi2vector.py`](aigi2vector.py)
- Необязательные помощники PPTX для извлечения встроенных изображений и рендеринга слайдов в PNG
- Дополнительные скрипты в `scripts/` для извлечения разметки, обрезки и AI-ассистированных пайплайнов
- Подмодуль `AutoAppDev/` (внешний инструмент; не обязателен для основного CLI)

| Пункт | Детали |
|---|---|
| Основная цель | Конвертировать растровые изображения в SVG-пути |
| Основной режим | Однофайловый CLI на Python |
| Ключевые зависимости | `opencv-python`, `numpy` |
| Дополнительные потоки | Извлечение/рендеринг PPTX, AI-ассистируемые скриптовые пайплайны |

## 🚀 Возможности

- Конвертация растровых изображений в SVG-пути в двух режимах:
  - `edges`: детектирование краёв на основе Canny
  - `binary`: выделение фигур через пороговую обработку
- Элементы предварительной обработки:
  - Гауссово размытие (`--blur`)
  - Необязательная инверсия (`--invert`)
- Упрощение путей методом Дугласа-Пекера (`--epsilon`)
- Вывод SVG сохраняет размеры исходного изображения через `width`, `height` и `viewBox`
- Утилиты для PPTX:
  - Извлечение встроенных изображений по слайду
  - Рендер страниц в `page1.png`, `page2.png`, ...

## 🗂️ Структура проекта

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

## 📦 Требования

### Основной CLI

- Python 3
- `pip`
- Зависимости из [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Необязательные помощники PPTX

- Для `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Для `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` или `libreoffice` в `PATH`)
  - `PyMuPDF` (`fitz`)
- Необязательная подготовка окружения:
  - Conda (для `scripts/setup_conda_env.sh`)

### Необязательные расширенные пайплайны

Несколько скриптов в `scripts/` зависят от внешних инструментов/сервисов (например, CLI `codex` и API GRS AI). Они не обязательны и не требуются для запуска `aigi2vector.py`.

## 🛠️ Установка

### Быстрый старт (базовый рабочий сценарий)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Необязательная настройка Conda для утилит PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Использование

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Параметры CLI

| Параметр | Значение по умолчанию | Описание |
|---|---|---|
| `--mode edges|binary` | `edges` | Режим векторизации |
| `--canny LOW HIGH` | `100 200` | Нижний/верхний пороги для режима `edges` |
| `--threshold N` | `128` | Порог бинаризации для режима `binary` |
| `--invert` | off | Инвертировать чёрный/белый перед поиском контуров |
| `--blur K` | `3` | Размер ядра Гаусса (нечётное целое) |
| `--epsilon E` | `1.5` | Упрощение кривых; выше значение = меньше точек |

### Как работают режимы

- Режим `edges` выполняет детектирование Canny и трассирует внешние контуры.
- Режим `binary` применяет порог к оттенкам серого и трассирует внешние контуры полученной маски.

## 🔧 Визуальный конвейер

```text
Input image/PPTX slide assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (optional)
   |
   v
Raster tracing + contour simplification
   |
   v
SVG output
```

## ⚙️ Настройки

### Подбор основных параметров CLI

- `--canny LOW HIGH`:
  - Низкие значения захватывают больше деталей/шума.
  - Высокие значения дают более чистые, но потенциально более разреженные контуры.
- `--threshold` (режим `binary`):
  - Ниже порога оставляет больше светлых областей как объект.
  - Выше порога оставляет в основном тёмные, контрастные области.
- `--blur`:
  - Внутренне нормализуется в положительное нечётное ядро.
  - Большие значения сглаживают шум перед детектированием контуров.
- `--epsilon`:
  - Больше значение упрощает пути агрессивнее (меньше точек).
  - Меньше значение лучше сохраняет детали формы.

### Переменные окружения (расширенные скрипты)

- `GRSAI` требуется скриптам извлечения GRS AI (например, `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Примечание: расширенные скрипты зависят от окружения и частично не задокументированы в текущем README; команды ниже отражают фактическое поведение репозитория и не гарантируют переносимость между машинами.

## 🧪 Примеры

### Растр → SVG

Контуры (подходит для линейной графики):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Бинарные формы (подходит для логотипов / плоского графического контента):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Извлечение изображений из PPTX

Если нужно извлечь встроенные изображения из `.pptx` (например, одно-или два изображения на слайд), используйте:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Добавьте `--dedupe`, чтобы пропускать дублирующиеся изображения между слайдами. Добавьте `--png`, чтобы сохранять файлы как `p{slide}image{index}.png`.

### Рендер слайдов в изображения

Чтобы отрендерить каждый слайд в `page1.png`, `page2.png`, ... установите LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Или используйте Python-рендер (он тоже использует LibreOffice, затем конвертирует страницы PDF в PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Необязательные расширенные рабочие процессы (скрипты)

Эти скрипты есть в репозитории и могут использоваться для более крупных пайплайнов декомпозиции/воссоздания:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Важно: некоторые из этих скриптов всё ещё содержат абсолютные пути под конкретные машины и зависимости внешних сервисов; адаптируйте их перед production-использованием.

## 🧰 Заметки по разработке

- Основная реализация — однофайловый CLI на Python: [`aigi2vector.py`](aigi2vector.py)
- Используйте `snake_case` для имён функций и переменных, `UPPER_SNAKE_CASE` для констант
- Предпочитайте небольшие тестируемые функции вместо монолитов
- Формальной системы тестирования сейчас нет
- `AIGI/` игнорируется Git и предназначена для локальных ассетов

## 🛟 Устранение неполадок

- `FileNotFoundError` для входного изображения/PPTX:
  - Проверьте, что путь корректен и файл доступен для чтения.
- `Could not read image`:
  - Убедитесь, что формат поддерживается OpenCV и файл не повреждён.
- Пустой или плохой SVG-результат:
  - Попробуйте `--mode binary` с подстроенным `--threshold`.
  - Подберите пороги `--canny` в режиме `edges`.
  - Уменьшите `--epsilon`, чтобы сохранить больше точек контура.
  - Начните с изображения с более высоким контрастом.
- `LibreOffice (soffice) not found in PATH`:
  - Установите LibreOffice и убедитесь, что `soffice` или `libreoffice` доступны в PATH.
- Отсутствуют Python-пакеты для сценариев скриптов:
  - Установите зависимости для конкретного пути скрипта (`python-pptx`, `Pillow`, `PyMuPDF` и т. д.).
- Сценарии GRS AI падают с ошибкой авторизации:
  - Экспортируйте ключ, например: `export GRSAI=...`.

## 🗺️ Дорожная карта

Возможные улучшения:

- Добавить автоматизированные тесты в `tests/` с детерминированными примерами изображений
- Ввести единые группы опциональных зависимостей для скриптовых пайплайнов
- Повысить переносимость расширенных shell-процессов (убрать жёстко заданные абсолютные пути)
- Добавить эталонные входные/выходные изображения в версионируемых примерах
- Заполнить `i18n/` поддерживаемыми переводами README

## 🤝 Вклад

Вклады приветствуются.

Рекомендуемый процесс:

1. Сделайте fork или ветку из текущей основной ветки.
2. Держите изменения сфокусированными и используйте короткие императивные коммиты.
3. Запускайте релевантные команды, которые меняли (CLI/скрипты), и проверяйте вывод.
4. Обновляйте раздел Usage в README при изменении поведения.

Если добавляете тесты, размещайте их в `tests/` и именуйте файлы как `test_*.py`.

## 📝 Заметки

- Выходной SVG сохраняет размеры пикселей входного изображения. При необходимости масштабируйте в редакторе векторной графики.
- Для лучших результатов начните с изображения с высоким контрастом.

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
