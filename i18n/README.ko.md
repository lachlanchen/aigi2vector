[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

AI 생성 래스터 이미지를 깨끗한 플롯용 벡터 SVG로 변환합니다.

이 저장소는 이미지의 에지 또는 이진 형태를 감지해 SVG 경로로 저장하는 Python CLI를 제공합니다. 사실적인 추적이 아니라, 스타일화된 플롯 친화형 벡터화에 맞춰 설계되었습니다.

## 🧰 한눈에 보기 (빠른 매트릭스)

| 영역 | 위치 | 목적 |
|---|---|---|
| 핵심 변환 | [`aigi2vector.py`](aigi2vector.py) | 래스터/PPTX 추출 이미지를 SVG로 변환 |
| 선택적 PPTX 도우미 | `scripts/` | 슬라이드 자산 추출 및 렌더링 |
| 확장 자동화 | `AutoAppDev/` | 선택적 외부 자동화 스택 |

---

## 📚 목차

- [한눈에 보기 (빠른 매트릭스)](#-한눈에-보기-빠른-매트릭스)
- [개요](#-개요)
- [기능](#-기능)
- [프로젝트 구조](#-프로젝트-구조)
- [사전 요구 사항](#-사전-요구-사항)
- [설치](#-설치)
- [사용법](#-사용법)
- [시각적 워크플로우](#-시각적-워크플로우)
- [설정](#-설정)
- [예시](#-예시)
- [개발 노트](#-개발-노트)
- [문제 해결](#-문제-해결)
- [로드맵](#-로드맵)
- [기여](#-기여)
- [참고](#-참고)
- [Support](#️-support)
- [License](#license)

## 🧭 한눈에 보기 (빠른 지도)

| 사용 사례 | 진입점 | 출력 |
|---|---|---|
| 한 이미지 를 SVG로 변환 | `python aigi2vector.py input.png output.svg` | `output.svg` |
| 출력 상세 조정 | [`사용법`](#-사용법)의 CLI 플래그 (`--mode`, `--canny`, `--epsilon` 등) | 더 깔끔하거나 더 촘촘한 윤곽 |
| PPTX 자산 처리 | `scripts/` 보조 도구 + 선택적 conda 환경 | 추출 이미지 + 렌더링된 슬라이드 PNG |

## 🎯 한눈에 보기

| 계층 | 설명 | 위치 |
|---|---|---|
| 핵심 CLI | 단일 명령으로 래스터 이미지를 SVG 경로로 변환 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX 보조 도구 | 슬라이드 콘텐츠를 추출하고 하류 벡터화용으로 슬라이드를 렌더링 | `scripts/` |
| 선택적 자동화 | AI 보조 추출, 구성 워크플로우 | `AutoAppDev/`, `scripts/` |

## ✨ 개요

`aigi2vector`에는 다음이 포함됩니다:

- 핵심 래스터-to-SVG CLI: [`aigi2vector.py`](aigi2vector.py)
- 임베디드 이미지 추출 및 슬라이드 PNG 렌더링을 위한 선택적 PPTX 보조 도구
- 레이아웃 추출, 크롭, AI 보조 파이프라인용 추가 워크플로우 스크립트 (`scripts/`)
- `AutoAppDev/` 하위 모듈(외부 도구, 핵심 CLI 실행에는 불필요)

| 항목 | 세부 내용 |
|---|---|
| 핵심 목적 | 래스터 이미지를 SVG 경로로 출력 |
| 주요 방식 | 단일 파일 Python CLI |
| 핵심 의존성 | `opencv-python`, `numpy` |
| 선택적 워크플로우 | PPTX 추출/렌더링, AI 보조 스크립트 파이프라인 |

## 🚀 기능

- 래스터 이미지를 두 가지 모드로 SVG 경로로 변환:
  - `edges`: Canny 기반 에지 검출
  - `binary`: 임계값 기반 형태 추출
- 전처리 제어:
  - 가우시안 블러 (`--blur`)
  - 선택적 반전 (`--invert`)
- Douglas-Peucker 근사(`--epsilon`)를 사용한 경로 단순화
- `width`, `height`, `viewBox`를 통해 입력 픽셀 크기를 보존하는 SVG 출력
- PPTX 이미지 유틸리티:
  - 슬라이드별 임베디드 이미지 추출
  - 슬라이드 페이지를 `page1.png`, `page2.png`, ...로 렌더링

## 🗂️ 프로젝트 구조

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

## 📦 사전 요구 사항

### 핵심 CLI

- Python 3
- `pip`
- [`requirements.txt`](requirements.txt)의 의존성:
  - `opencv-python`
  - `numpy`

### 선택적 PPTX 보조 도구

- `scripts/extract_pptx_images.py`의 경우:
  - `python-pptx`
  - `Pillow`
- `scripts/render_pptx_slides.py`의 경우:
  - LibreOffice (`soffice` 또는 `libreoffice`가 `PATH`에 있어야 함)
  - `PyMuPDF` (`fitz`)
- 선택적 보조 설정:
  - Conda (`scripts/setup_conda_env.sh`)

### 선택적 고급 파이프라인

`scripts/` 아래의 여러 스크립트는 외부 도구/서비스(예: `codex` CLI와 GRS AI API)에 의존할 수 있습니다. 이들은 선택 사항이며 `aigi2vector.py` 실행에 필수는 아닙니다.

## 🛠️ 설치

### 빠른 시작(기본 흐름)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX 유틸리티용 선택적 Conda 설정

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ 사용법

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI 옵션

| 옵션 | 기본값 | 설명 |
|---|---|---|
| `--mode edges|binary` | `edges` | 벡터화 모드 |
| `--canny LOW HIGH` | `100 200` | edges 모드의 저/고 임계값 |
| `--threshold N` | `128` | `binary` 모드에서 사용하는 임계값 |
| `--invert` | off | 윤곽선 탐지 전에 반전 |
| `--blur K` | `3` | 가우시안 블러 커널 크기(홀수 정수) |
| `--epsilon E` | `1.5` | 곡선 단순화; 값이 클수록 포인트 수 감소 |

### 모드 동작 방식

- `edges` 모드는 Canny 에지 검출을 수행하고 외부 윤곽선을 추적합니다.
- `binary` 모드는 그레이스케일 픽셀을 임계값 처리하고 결과 마스크의 외부 윤곽선을 추적합니다.

## 🔧 시각적 워크플로우

```text
입력 이미지/PPTX 슬라이드 자산
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (선택적)
   |
   v
래스터 추적 + 윤곽선 단순화
   |
   v
SVG 출력
```

## ⚙️ 설정

### 주요 CLI 매개변수 튜닝

- `--canny LOW HIGH`:
  - 낮은 값은 더 많은 디테일/노이즈를 포착
  - 높은 값은 더 깔끔하지만 윤곽이 더 희소해질 수 있음
- `--threshold` (`binary` 모드):
  - 낮은 임계값은 더 많은 밝은 영역을 전경으로 유지
  - 높은 임계값은 주로 어두운/고대비 영역만 유지
- `--blur`:
  - 내부적으로 양의 홀수 커널로 자동 정규화됩니다.
  - 더 큰 값은 윤곽선 탐지 전에 노이즈를 부드럽게 만듦
- `--epsilon`:
  - 값이 클수록 경로를 더 공격적으로 단순화(점 수 감소)
  - 값이 작을수록 형태 디테일을 더 잘 보존

### 환경 변수(고급 스크립트)

- `GRSAI`는 GRS AI 추출 스크립트에서 필요합니다(예: `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

가정 노트: 고급 스크립트는 환경 종속적이며 현재 README 기준 설명이 일부만 있습니다. 아래 명령은 저장소 기준 동작을 그대로 반영할 뿐, 모든 환경에서 동작을 보장하지는 않습니다.

## 🧪 사용 예시

### 래스터에서 SVG로

에지 모드(선화에 적합):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

이진 형태(로고/평면 아트에 적합):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 이미지 추출

`.pptx`에서 임베디드 이미지를 추출해야 할 때(예: 슬라이드당 1~2개), 다음을 사용합니다:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

`--dedupe`를 추가하면 슬라이드 간 중복 이미지를 건너뜁니다. `--png`를 추가하면 `p{slide}image{index}.png`로 저장됩니다.

### 슬라이드 렌더링

각 슬라이드를 `page1.png`, `page2.png`, ...로 렌더링하려면 LibreOffice (`soffice`)가 필요합니다:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

또는 Python 렌더러를 사용합니다(LibreOffice 실행 후 PDF 페이지를 PNG로 변환):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 선택적 고급 워크플로우 (scripts)

이 스크립트들은 저장소에 있으며, 더 큰 분해/재구성 파이프라인에 사용 가능합니다:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

중요: 일부 스크립트에는 현재 머신 전용 절대 경로와 외부 서비스 의존성이 포함되어 있습니다. 운영 환경에서 사용하기 전에 조정하세요.

## 🛠️ 개발 노트

- 기본 구현은 단일 파일 Python CLI입니다: [`aigi2vector.py`](aigi2vector.py)
- `aigi2vector.py`에서 함수/변수 이름은 `snake_case`, 상수는 `UPPER_SNAKE_CASE`를 유지하세요.
- 큰 단일 블록보다 작은 테스트 가능한 함수 단위를 선호하세요.
- 현재 정식 테스트 스위트는 없습니다.
- `AIGI/`는 Git에서 무시되는 디렉터리로, 로컬 자산용 폴더입니다.

## 🛟 문제 해결

- 입력 이미지/PPTX에서 `FileNotFoundError`:
  - 입력 경로가 정확하고 읽기 가능한지 확인하세요.
- `Could not read image`:
  - 파일 형식이 OpenCV에서 지원되는지, 파일이 손상되지 않았는지 확인하세요.
- SVG 출력이 비어 있거나 품질이 낮은 경우:
  - `--mode binary`로 전환하고 `--threshold`를 조정해 보세요.
  - `edges` 모드에서 `--canny` 임계값을 조정하세요.
  - 더 많은 윤곽 포인트를 유지하려면 `--epsilon`을 낮추세요.
  - 더 높은 대비의 원본 이미지를 사용하세요.
- `LibreOffice (soffice) not found in PATH`:
  - LibreOffice를 설치하고 `soffice` 또는 `libreoffice`가 셸의 검색 경로에 있는지 확인하세요.
- 스크립트 흐름에서 Python 패키지 누락:
  - 해당 스크립트에 필요한 의존성(`python-pptx`, `Pillow`, `PyMuPDF` 등)을 설치하세요.
- GRS AI 스크립트 인증 오류:
  - 키를 내보냅니다. 예: `export GRSAI=...`.

## 🗺️ 로드맵

향후 개선 가능 항목:

- `tests/`에 결정론적 샘플 이미지 기반 자동 테스트 추가
- 스크립트 워크플로우용 통합 선택적 의존성 그룹 제공
- 고급 셸 파이프라인의 이식성 개선(하드코딩된 절대 경로 제거)
- 버전 관리 샘플 자산으로 참조 입출력 예시 추가
- `i18n/`에 유지되는 번역 README 보강

## 🤝 기여

기여를 환영합니다.

권장 프로세스:

1. 현재 mainline에서 fork 또는 브랜치 생성
2. 변경 범위를 좁고 집중되게 유지하고, 짧은 명령형 커밋 메시지 사용
3. 수정한 CLI/스크립트 경로를 실행해 출력물을 확인
4. 동작이 바뀐 경우 README 사용법을 업데이트

테스트를 추가할 경우 `tests/` 아래에 `test_*.py` 형식으로 배치하세요.

## 📝 참고

- 출력 SVG는 입력 픽셀 크기를 그대로 사용합니다. 필요하면 벡터 편집기에서 크기 조절하세요.
- 최적의 결과를 위해 고대비 이미지로 시작하세요.

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
