[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Преобразование растровых изображений, сгенерированных ИИ, в чистые векторные SVG для плоттера.

Этот репозиторий предоставляет Python CLI, который находит границы или бинарные формы на изображении и записывает их как SVG-пути. Проект ориентирован на стилизованную, удобную для плоттера векторизацию, а не на фотореалистичную трассировку.

## ✨ Обзор

`aigi2vector` включает:

- Основной CLI для преобразования растра в SVG: [`aigi2vector.py`](../aigi2vector.py)
- Дополнительные PPTX-утилиты для извлечения встроенных изображений и рендера слайдов в PNG
- Дополнительные workflow-скрипты в `scripts/` для извлечения макета, кадрирования и AI-assisted пайплайнов
- Подмодуль `AutoAppDev/` (внешний инструмент; не требуется для основного CLI)

| Элемент | Детали |
|---|---|
| Основное назначение | Преобразование растровых изображений в SVG-пути |
| Основной режим | Однофайловый Python CLI |
| Базовые зависимости | `opencv-python`, `numpy` |
| Дополнительные workflow | Извлечение/рендер PPTX, AI-assisted скриптовые пайплайны |

## 🚀 Возможности

- Преобразование растровых изображений в SVG-пути в двух режимах:
  - `edges`: обнаружение границ на основе Canny
  - `binary`: извлечение форм по порогу
- Параметры предобработки:
  - Гауссово размытие (`--blur`)
  - Опциональная инверсия (`--invert`)
- Упрощение путей с помощью аппроксимации Дугласа-Пекера (`--epsilon`)
- SVG-вывод с сохранением пиксельных размеров входа через `width`, `height` и `viewBox`
- Утилиты для изображений из PPTX:
  - Извлечение встроенных изображений по слайдам
  - Рендер страниц слайдов в `page1.png`, `page2.png`, ...

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
- Зависимости из [`requirements.txt`](../requirements.txt):
  - `opencv-python`
  - `numpy`

### Дополнительные PPTX-утилиты

- Для `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Для `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` или `libreoffice` в `PATH`)
  - `PyMuPDF` (`fitz`)
- Опциональная вспомогательная настройка:
  - Conda (для `scripts/setup_conda_env.sh`)

### Дополнительные расширенные пайплайны

Несколько скриптов в `scripts/` зависят от внешних инструментов/сервисов (например, CLI `codex` и API GRS AI). Они опциональны и не нужны для запуска `aigi2vector.py`.

## 🛠️ Установка

### Быстрый старт (текущий канонический сценарий)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Опциональная настройка Conda для PPTX-утилит

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Использование

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Параметры CLI

| Option | Default | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | Vectorization mode |
| `--canny LOW HIGH` | `100 200` | Low/high thresholds for edges mode |
| `--threshold N` | `128` | Binary threshold used in `binary` mode |
| `--invert` | off | Invert black/white before contour detection |
| `--blur K` | `3` | Gaussian blur kernel size (odd integer) |
| `--epsilon E` | `1.5` | Curve simplification; higher = fewer points |

### Как работают режимы

- Режим `edges` запускает обнаружение границ Canny и трассирует внешние контуры.
- Режим `binary` применяет порог к пикселям в оттенках серого и трассирует внешние контуры полученной маски.

## ⚙️ Конфигурация

### Тонкая настройка параметров основного CLI

- `--canny LOW HIGH`:
  - Более низкие значения захватывают больше деталей/шума.
  - Более высокие значения дают более чистые, но потенциально более редкие контуры.
- `--threshold` (режим binary):
  - Более низкий порог сохраняет больше светлых областей как передний план.
  - Более высокий порог сохраняет в основном тёмные/высококонтрастные области.
- `--blur`:
  - Внутри автоматически нормализуется к положительному нечётному ядру.
  - Большие значения сглаживают шум перед поиском контуров.
- `--epsilon`:
  - Большие значения агрессивнее упрощают пути (меньше точек).
  - Малые значения лучше сохраняют детали формы.

### Переменные окружения (расширенные скрипты)

- `GRSAI` обязателен для скриптов извлечения GRS AI (например, `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Примечание о допущении: расширенные скрипты зависят от окружения и частично не документированы в текущей базовой версии README; команды ниже сохраняют поведение, соответствующее репозиторию, но не гарантируют переносимость на всех машинах.

## 🧪 Примеры

### Растр в SVG

Edges (подходит для line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Бинарные формы (подходит для логотипов / flat art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Извлечение изображений из PPTX

Если нужно извлечь встроенные изображения из `.pptx` (например, одно-два изображения на слайд), используйте:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Добавьте `--dedupe`, чтобы пропускать дублирующиеся изображения между слайдами. Добавьте `--png`, чтобы сохранять файлы как `p{slide}image{index}.png`.

### Рендер слайдов в изображения

Чтобы рендерить каждый слайд в `page1.png`, `page2.png`, ... требуется установленный LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Или используйте Python-рендерер (он также использует LibreOffice, затем конвертирует страницы PDF в PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Опциональные расширенные workflow (скрипты)

Эти скрипты есть в репозитории и могут использоваться для более крупных пайплайнов декомпозиции/реконструкции:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Важно: некоторые из этих скриптов сейчас содержат абсолютные пути, специфичные для конкретной машины, и внешние зависимости от сервисов; адаптируйте их перед использованием в production.

## 🧰 Заметки по разработке

- Основная реализация - однофайловый Python CLI: [`aigi2vector.py`](../aigi2vector.py)
- Используйте `snake_case` для функций/переменных, `UPPER_SNAKE_CASE` для констант
- Предпочитайте небольшие, тестируемые функции вместо монолитных блоков
- Формального набора тестов сейчас нет
- `AIGI/` игнорируется git и предназначена для локальных ассетов

## 🛟 Устранение неполадок

- `FileNotFoundError` для входного изображения/PPTX:
  - Проверьте, что путь к входному файлу корректен и доступен для чтения.
- `Could not read image`:
  - Убедитесь, что формат поддерживается OpenCV и файл не повреждён.
- Пустой или некачественный SVG-вывод:
  - Попробуйте `--mode binary` с подобранным `--threshold`.
  - Подстройте пороги `--canny` в режиме `edges`.
  - Уменьшите `--epsilon`, чтобы сохранить больше точек контура.
  - Начинайте с изображения с более высоким контрастом.
- `LibreOffice (soffice) not found in PATH`:
  - Установите LibreOffice и убедитесь, что `soffice` или `libreoffice` доступен в вашей оболочке.
- Отсутствуют Python-пакеты для скриптовых сценариев:
  - Установите необходимые зависимости для соответствующего сценария (`python-pptx`, `Pillow`, `PyMuPDF` и т.д.).
- Скрипты GRS AI завершаются ошибками аутентификации:
  - Экспортируйте ключ, например: `export GRSAI=...`.

## 🗺️ Дорожная карта

Потенциальные следующие улучшения:

- Добавить автоматические тесты в `tests/` с детерминированными примерами изображений
- Опубликовать единые группы опциональных зависимостей для скриптовых workflow
- Улучшить переносимость расширенных shell-пайплайнов (убрать жёстко заданные абсолютные пути)
- Добавить эталонные примеры ввода/вывода в версионируемые sample-ассеты
- Заполнить `i18n/` поддерживаемыми переводами README

## 🤝 Вклад

Вклад приветствуется.

Рекомендуемый процесс:

1. Форкните репозиторий или создайте ветку от текущей основной линии.
2. Делайте изменения точечно и используйте короткие commit message в повелительном наклонении.
3. Запустите релевантные команды, которые вы изменили (CLI/скриптовый путь), и проверьте результат.
4. Обновляйте примечания по использованию в README, если поведение изменилось.

Если вы добавляете тесты, размещайте их в `tests/` и называйте файлы `test_*.py`.

## 📝 Примечания

- Выходной SVG использует пиксельные размеры входного изображения. При необходимости масштабируйте в векторном редакторе.
- Для наилучшего результата используйте изображение с высоким контрастом.

## License

MIT
