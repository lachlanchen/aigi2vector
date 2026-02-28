[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Преобразуйте изображения, сгенерированные ИИ, в аккуратные векторные SVG для плоттера.

Этот репозиторий предоставляет Python CLI, который обнаруживает края или бинарные формы на изображении и записывает их в виде SVG-путей. Он ориентирован на стилизованную векторизацию, удобную для плоттера, а не на фотореалистичную трассировку.

## 🎯 В одном взгляде

| Уровень | Описание | Место |
|---|---|---|
| Core CLI | Преобразование растровых изображений в SVG-пути одной командой | [`aigi2vector.py`](aigi2vector.py) |
| PPTX-утилиты | Извлечение содержимого слайдов и рендер страниц для последующей векторизации | `scripts/` |
| Дополнительная автоматизация | Расширенные AI-ориентированные пайплайны извлечения, сборки и обработки | `AutoAppDev/`, `scripts/` |

## ✨ Обзор

`aigi2vector` включает в себя:

- Основной CLI для преобразования растра в SVG: [`aigi2vector.py`](aigi2vector.py)
- Дополнительные PPTX-утилиты для извлечения встроенных изображений и рендеринга слайдов в PNG
- Дополнительные скрипты в `scripts/` для извлечения макета, кадрирования и AI-ориентированных пайплайнов
- Подмодуль `AutoAppDev/` (внешний инструмент, не требуется для работы основного CLI)

| Пункт | Детали |
|---|---|
| Основная цель | Преобразование растровых изображений в вывод SVG-путей |
| Основной режим | Однофайловый Python CLI |
| Ключевые зависимости | `opencv-python`, `numpy` |
| Дополнительные рабочие процессы | Извлечение/rendering PPTX, AI-ориентированные скриптовые пайплайны |

## 🚀 Возможности

- Преобразование растровых изображений в SVG-пути в двух режимах:
  - `edges`: обнаружение краев на основе Canny
  - `binary`: извлечение форм пороговой обработкой
- Параметры предварительной обработки:
  - Гауссово размытие (`--blur`)
  - Опциональная инверсия (`--invert`)
- Упрощение путей с помощью аппроксимации Дугласа-Пекера (`--epsilon`)
- Вывод SVG, сохраняющий размеры исходного изображения через `width`, `height` и `viewBox`
- PPTX-утилиты для работы с изображениями:
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

## 📦 Предварительные требования

### Core CLI

- Python 3
- `pip`
- Зависимости из [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Дополнительные PPTX-утилиты

- Для `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Для `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` или `libreoffice` в `PATH`)
  - `PyMuPDF` (`fitz`)
- Дополнительная настройка среды:
  - Conda (для `scripts/setup_conda_env.sh`)

### Дополнительные продвинутые пайплайны

Несколько скриптов в `scripts/` зависят от внешних инструментов/сервисов (например, `codex` CLI и API GRS AI). Они опциональны и не требуются для запуска `aigi2vector.py`.

## 🛠️ Установка

### Quick Start (основной рабочий процесс)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Опциональная установка Conda для PPTX-утилит

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Использование

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Параметры CLI

| Опция | По умолчанию | Описание |
|---|---|---|
| `--mode edges|binary` | `edges` | Режим векторизации |
| `--canny LOW HIGH` | `100 200` | Нижние/верхние пороги для режима edges |
| `--threshold N` | `128` | Порог бинаризации, используемый в режиме `binary` |
| `--invert` | off | Инвертировать черное/белое перед поиском контуров |
| `--blur K` | `3` | Размер ядра Гауссова размытия (нечётное число) |
| `--epsilon E` | `1.5` | Упрощение кривых; большее значение = меньше точек |

### Как работают режимы

- Режим `edges` выполняет обнаружение краев Canny и трассирует внешние контуры.
- Режим `binary` выполняет пороговую обработку градаций серого и трассирует внешние контуры полученной маски.

## ⚙️ Конфигурация

### Подбор параметров основного CLI

- `--canny LOW HIGH`:
  - Меньшие значения захватывают больше деталей и шума.
  - Большие значения дают более чистые, но потенциально более редкие контуры.
- `--threshold` (режим binary):
  - Меньший порог оставляет больше светлых областей как foreground.
  - Больший порог оставляет в основном тёмные/контрастные области.
- `--blur`:
  - Автоматически нормализуется во внутренней логике в положительное нечётное ядро.
  - Более высокие значения сглаживают шум перед поиском контуров.
- `--epsilon`:
  - Большие значения агрессивнее упрощают пути (меньше точек).
  - Меньшие значения лучше сохраняют детализацию формы.

### Переменные окружения (расширенные скрипты)

- `GRSAI` требуется для скриптов извлечения GRS AI (например, `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Примечание: расширенные скрипты зависят от окружения и частично не полностью документированы в текущей версии README; приведённые ниже команды отражают поведение репозитория, но не гарантируют переносимость между всеми машинами.

## 🧪 Примеры

### Растр в SVG

Edges (подходит для линейной графики):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Бинарные формы (подходит для логотипов и плоской графики):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Извлечение изображений из PPTX

Если нужно извлечь встроенные изображения из `.pptx` (например, одно или два изображения на слайд), используйте:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Добавьте `--dedupe`, чтобы пропускать повторяющиеся изображения между слайдами. Добавьте `--png`, чтобы сохранять файлы как `p{slide}image{index}.png`.

### Рендер слайдов в изображения

Чтобы отрендерить каждый слайд в `page1.png`, `page2.png`, ... установите LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Или используйте Python-рендерер (также использует LibreOffice, затем конвертирует страницы PDF в PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Дополнительные продвинутые workflows (скрипты)

Эти скрипты есть в репозитории и могут использоваться для более крупных пайплайнов декомпозиции/сборки:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Важно: часть этих скриптов пока содержит машинно-зависимые абсолютные пути и внешние сервисные зависимости; адаптируйте их перед использованием в продакшене.

## 🧰 Заметки по разработке

- Основная реализация — однофайловый Python CLI: [`aigi2vector.py`](aigi2vector.py)
- Используйте `snake_case` для имён функций/переменных и `UPPER_SNAKE_CASE` для констант
- Предпочитайте небольшие, тестируемые функции вместо монолитных блоков
- На данный момент формальная тестовая система отсутствует
- `AIGI/` игнорируется git и предназначена для локальных ассетов

## 🛟 Устранение неполадок

- `FileNotFoundError` для входного изображения/PPTX:
  - Проверьте, что путь входного файла указан корректно и файл доступен для чтения.
- `Could not read image`:
  - Убедитесь, что формат поддерживается OpenCV и файл не повреждён.
- Пустой или плохой SVG:
  - Попробуйте `--mode binary` с настроенным `--threshold`.
  - Подстройте пороги `--canny` в режиме `edges`.
  - Уменьшите `--epsilon`, чтобы сохранить больше точек контура.
  - Начинайте с более контрастного исходного изображения.
- `LibreOffice (soffice) not found in PATH`:
  - Установите LibreOffice и убедитесь, что `soffice` или `libreoffice` доступны из вашей оболочки.
- Отсутствуют Python-пакеты для скриптовых цепочек:
  - Установите нужные зависимости для используемого скриптового маршрута (`python-pptx`, `Pillow`, `PyMuPDF` и т.д.).
- Скрипты GRS AI завершаются с ошибками авторизации:
  - Передайте ключ, например: `export GRSAI=...`.

## 🗺️ Roadmap

Возможные следующие улучшения:

- Добавить автоматические тесты в `tests/` с детерминированными тестовыми изображениями
- Опубликовать единые наборы необязательных зависимостей для скриптовых пайплайнов
- Улучшить переносимость расширенных shell-пайплайнов (убрать жёстко заданные абсолютные пути)
- Добавить эталонные примеры входных/выходных данных под версионируемые assets
- Заполнить `i18n/` поддерживаемыми вариантами README

## 🤝 Contributing

Вклад приветствуется.

Рекомендуемый процесс:

1. Сделайте fork или создайте ветку от текущей основной ветки.
2. Держите изменения целенаправленными и используйте короткие императивные сообщения коммитов.
3. Запускайте соответствующие команды для изменённых путей CLI/скриптов и проверяйте результат.
4. Обновляйте разделы README по использованию при изменении поведения.

Если вы добавляете тесты, размещайте их в `tests/` и называйте файлы `test_*.py`.

## 📝 Заметки

- Выходной SVG сохраняет размеры входного изображения в пикселях. При необходимости масштабируйте его в редакторе векторов.
- Для наилучшего качества начинайте с изображений с высоким контрастом.

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
