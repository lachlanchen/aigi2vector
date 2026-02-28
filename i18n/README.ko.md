[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

AI가 생성한 래스터 이미지를 깔끔한 벡터 경로 SVG로 변환합니다.

이 리포지토리는 이미지에서 에지 또는 이진 형태를 감지해 SVG 경로로 저장하는 Python CLI를 제공합니다. 사실적인 트레이싱보다는 스타일화된, 플로터 친화적인 벡터화에 초점을 맞췄습니다.

## ✨ 개요

`aigi2vector`에는 다음이 포함됩니다.

- 코어 래스터→SVG CLI: [`aigi2vector.py`](aigi2vector.py)
- 임베디드 이미지 추출 및 슬라이드를 PNG로 렌더링하는 선택형 PPTX 보조 도구
- 레이아웃 추출, 크롭, AI 보조 파이프라인을 위한 `scripts/` 내 추가 워크플로 스크립트
- `AutoAppDev/` 서브모듈(외부 도구, 메인 CLI 실행에는 불필요)

| 항목 | 세부 정보 |
|---|---|
| 핵심 목적 | 래스터 이미지를 SVG 경로 출력으로 변환 |
| 기본 실행 형태 | 단일 파일 Python CLI |
| 핵심 의존성 | `opencv-python`, `numpy` |
| 선택형 워크플로 | PPTX 추출/렌더링, AI 보조 스크립트 파이프라인 |

## 🚀 기능

- 두 가지 모드로 래스터 이미지를 SVG 경로로 변환:
  - `edges`: Canny 기반 에지 검출
  - `binary`: 임계값 기반 형태 추출
- 전처리 제어:
  - 가우시안 블러(`--blur`)
  - 선택적 반전(`--invert`)
- Douglas-Peucker 근사를 이용한 경로 단순화(`--epsilon`)
- `width`, `height`, `viewBox`를 통해 입력 픽셀 크기를 유지하는 SVG 출력
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

### 코어 CLI

- Python 3
- `pip`
- [`requirements.txt`](requirements.txt)의 의존성:
  - `opencv-python`
  - `numpy`

### 선택형 PPTX 보조 도구

- `scripts/extract_pptx_images.py` 사용 시:
  - `python-pptx`
  - `Pillow`
- `scripts/render_pptx_slides.py` 사용 시:
  - LibreOffice(`PATH`에 `soffice` 또는 `libreoffice`)
  - `PyMuPDF`(`fitz`)
- 선택형 보조 설정:
  - Conda(`scripts/setup_conda_env.sh`용)

### 선택형 고급 파이프라인

`scripts/` 아래 여러 스크립트는 외부 도구/서비스(예: `codex` CLI, GRS AI API)에 의존합니다. 이는 선택 사항이며 `aigi2vector.py` 실행에는 필요하지 않습니다.

## 🛠️ 설치

### 빠른 시작(기존 정식 흐름)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX 유틸리티용 선택형 Conda 설정

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
| `--canny LOW HIGH` | `100 200` | edges 모드의 low/high 임계값 |
| `--threshold N` | `128` | `binary` 모드에서 사용하는 이진 임계값 |
| `--invert` | off | 윤곽선 검출 전 흑백 반전 |
| `--blur K` | `3` | 가우시안 블러 커널 크기(홀수 정수) |
| `--epsilon E` | `1.5` | 곡선 단순화; 값이 클수록 포인트가 줄어듦 |

### 모드 동작 방식

- `edges` 모드는 Canny 에지 검출을 수행하고 외곽 윤곽선을 추적합니다.
- `binary` 모드는 그레이스케일 픽셀에 임계값을 적용한 뒤 결과 마스크의 외곽 윤곽선을 추적합니다.

## ⚙️ 설정

### 메인 CLI 파라미터 튜닝

- `--canny LOW HIGH`:
  - 낮은 값은 더 많은 디테일/노이즈를 포착합니다.
  - 높은 값은 더 깨끗하지만 더 성긴 윤곽선을 만들 수 있습니다.
- `--threshold`(`binary` 모드):
  - 낮은 임계값은 밝은 영역을 전경으로 더 많이 유지합니다.
  - 높은 임계값은 주로 어두운/고대비 영역만 유지합니다.
- `--blur`:
  - 내부적으로 양의 홀수 커널로 자동 정규화됩니다.
  - 값이 클수록 윤곽선 검출 전에 노이즈를 더 부드럽게 만듭니다.
- `--epsilon`:
  - 값이 클수록 경로를 더 공격적으로 단순화합니다(포인트 감소).
  - 값이 작을수록 형태 디테일을 더 잘 유지합니다.

### 환경 변수(고급 스크립트)

- `GRSAI`는 GRS AI 추출 스크립트(예: `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`)에서 필요합니다.

가정 참고: 고급 스크립트는 환경 의존적이며 현재 README 기준으로 일부 문서화가 부족합니다. 아래 명령은 리포지토리 기준 동작은 유지하지만 모든 머신에서의 이식성을 보장하지는 않습니다.

## 🧪 예시

### 래스터를 SVG로 변환

Edges(선화에 적합):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes(로고/플랫 아트에 적합):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 이미지 추출

`.pptx`에서 임베디드 이미지를 추출해야 한다면(예: 슬라이드당 1~2개 이미지), 다음을 사용하세요.

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

슬라이드 간 중복 이미지를 건너뛰려면 `--dedupe`를 추가하세요. 파일을 `p{slide}image{index}.png` 형식으로 저장하려면 `--png`를 추가하세요.

### 슬라이드를 이미지로 렌더링

각 슬라이드를 `page1.png`, `page2.png`, ...로 렌더링하려면 LibreOffice(`soffice`)가 설치되어 있어야 합니다.

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

또는 Python 렌더러를 사용할 수 있습니다(LibreOffice를 사용한 뒤 PDF 페이지를 PNG로 변환).

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 선택형 고급 워크플로(스크립트)

다음 스크립트는 리포지토리에 포함되어 있으며 더 큰 분해/재구성 파이프라인에서 사용할 수 있습니다.

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

중요: 이 스크립트들 중 일부는 현재 머신별 절대 경로와 외부 서비스 의존성을 포함합니다. 운영 환경에서 사용하기 전에 반드시 조정하세요.

## 🧰 개발 노트

- 주요 구현은 단일 파일 Python CLI입니다: [`aigi2vector.py`](aigi2vector.py)
- 함수/변수 이름은 `snake_case`, 상수는 `UPPER_SNAKE_CASE`를 유지하세요.
- 큰 블록보다 작고 테스트 가능한 함수를 선호하세요.
- 현재 정식 테스트 스위트는 없습니다.
- `AIGI/`는 git에서 무시되며 로컬 에셋 저장용입니다.

## 🛟 문제 해결

- 입력 이미지/PPTX에서 `FileNotFoundError`가 발생하는 경우:
  - 입력 경로가 올바르고 읽기 가능한지 확인하세요.
- `Could not read image`가 발생하는 경우:
  - 파일 형식이 OpenCV에서 지원되는지, 파일이 손상되지 않았는지 확인하세요.
- SVG 출력이 비어 있거나 품질이 낮은 경우:
  - `--mode binary`로 바꾸고 `--threshold`를 조정해 보세요.
  - `edges` 모드에서 `--canny` 임계값을 조정하세요.
  - 더 많은 윤곽점 보존을 위해 `--epsilon` 값을 낮추세요.
  - 대비가 높은 원본 이미지를 사용해 보세요.
- `LibreOffice (soffice) not found in PATH`:
  - LibreOffice를 설치하고 `soffice` 또는 `libreoffice`가 셸에서 검색되는지 확인하세요.
- 스크립트 흐름에 필요한 Python 패키지가 없는 경우:
  - 해당 스크립트 경로에 필요한 의존성(`python-pptx`, `Pillow`, `PyMuPDF` 등)을 설치하세요.
- GRS AI 스크립트가 인증 오류로 실패하는 경우:
  - 예: `export GRSAI=...` 형태로 키를 내보내세요.

## 🗺️ 로드맵

잠재적인 다음 개선 사항:

- `tests/` 아래에 결정론적 샘플 이미지를 사용하는 자동 테스트 추가
- 스크립트 워크플로를 위한 통합 선택형 의존성 그룹 배포
- 고급 셸 파이프라인의 이식성 개선(하드코딩된 절대 경로 제거)
- 버전 관리되는 샘플 에셋 아래에 참조 입력/출력 예시 추가
- 유지보수되는 다국어 README 변형으로 `i18n/` 채우기

## 🤝 기여

기여를 환영합니다.

권장 절차:

1. 현재 메인라인에서 포크하거나 브랜치를 생성합니다.
2. 변경은 한 가지 논리 단위로 집중하고, 짧은 명령형 커밋 메시지를 사용합니다.
3. 변경한 관련 명령(CLI/스크립트 경로)을 실행해 출력 결과를 검증합니다.
4. 동작이 바뀌면 README 사용법 노트를 업데이트합니다.

테스트를 추가하는 경우 `tests/` 아래에 두고 파일 이름은 `test_*.py`로 지정하세요.

## 📝 참고

- 출력 SVG는 입력 픽셀 크기를 사용합니다. 필요하면 벡터 편집기에서 스케일을 조정하세요.
- 최상의 결과를 위해 대비가 높은 이미지를 사용하세요.

## License

MIT
