[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

AI 생성 래스터 이미지를 깔끔한 벡터 플롯 SVG로 변환합니다.

이 저장소는 이미지의 윤곽선이나 이진 형태를 감지해 SVG 경로로 쓰는 파이썬 CLI를 제공합니다. 사진 그대로의 사실적 추적이 아니라, 스타일화되고 플로터에 적합한 벡터화에 초점을 맞췄습니다.

## 🎯 한눈에 보기

| 구성요소 | 설명 | 위치 |
|---|---|---|
| 핵심 CLI | 한 번의 명령으로 래스터 이미지를 SVG 경로로 변환 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX 헬퍼 | 슬라이드 내용을 추출하고 하위 벡터화 단계용 렌더링 수행 | `scripts/` |
| 선택적 자동화 | 대규모 AI 기반 추출/구성 워크플로우 | `AutoAppDev/`, `scripts/` |

## ✨ 개요

`aigi2vector`는 다음을 포함합니다:

- 핵심 래스터→SVG CLI: [`aigi2vector.py`](aigi2vector.py)
- PPTX 내부 이미지 추출과 슬라이드 PNG 렌더링을 위한 선택적 보조 스크립트
- 레이아웃 추출, 크롭, AI 보조 파이프라인용 추가 스크립트: `scripts/`
- `AutoAppDev/` 하위 모듈 (외부 도구; 핵심 CLI 실행에는 필요하지 않음)

| 항목 | 세부사항 |
|---|---|
| 핵심 목적 | 래스터 이미지를 SVG 경로 출력으로 변환 |
| 주요 실행 방식 | 단일 파일 파이썬 CLI |
| 핵심 의존성 | `opencv-python`, `numpy` |
| 선택적 워크플로우 | PPTX 추출/렌더링, AI 기반 스크립트 파이프라인 |

## 🚀 기능

- 두 가지 모드로 래스터 이미지를 SVG 경로로 변환합니다.
  - `edges`: Canny 기반 에지(윤곽) 검출
  - `binary`: 임계값 기반 형태 추출
- 전처리 제어:
  - 가우시안 블러 (`--blur`)
  - 선택적 반전 (`--invert`)
- Douglas-Peucker 근사로 경로 단순화 (`--epsilon`)
- `width`, `height`, `viewBox`를 사용해 입력 픽셀 크기를 유지하는 SVG 출력
- PPTX 이미지 유틸리티:
  - 슬라이드별 임베디드 이미지 추출
  - 각 슬라이드를 `page1.png`, `page2.png` 등으로 렌더링

## 🗂️ 프로젝트 구조

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git 하위 모듈(핵심 CLI의 경우 선택적)
├── i18n/                            # 번역 디렉터리(현재 스켈레톤/비어 있음)
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

## 📦 사전 요구사항

### 핵심 CLI

- Python 3
- `pip`
- [`requirements.txt`](requirements.txt)의 종속성:
  - `opencv-python`
  - `numpy`

### 선택적 PPTX 보조 도구

- `scripts/extract_pptx_images.py`에 대해:
  - `python-pptx`
  - `Pillow`
- `scripts/render_pptx_slides.py`에 대해:
  - LibreOffice (`soffice` 또는 `libreoffice`가 `PATH`에 등록)
  - `PyMuPDF` (`fitz`)
- 선택적 보조 도구 설정:
  - Conda (`scripts/setup_conda_env.sh`용)

### 선택적 고급 파이프라인

`scripts/` 하위의 여러 스크립트는 외부 도구/서비스(예: `codex` CLI와 GRS AI API)에 의존할 수 있습니다. 이는 선택 기능이며 `aigi2vector.py` 실행에 필수는 아닙니다.

## 🛠️ 설치

### 빠른 시작(공식 기본 흐름)

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
| `--invert` | off | 윤곽선 감지 전에 검정/흰색 반전 |
| `--blur K` | `3` | 가우시안 블러 커널 크기(홀수 정수) |
| `--epsilon E` | `1.5` | 곡선 단순화; 값이 클수록 점 수가 감소 |

### 모드 동작 방식

- `edges` 모드는 Canny 에지 검출을 수행하고 외곽 윤곽선을 추적합니다.
- `binary` 모드는 그레이스케일 임계값을 적용한 뒤 생성된 마스크의 외곽 윤곽선을 추적합니다.

## ⚙️ 구성

### 주요 CLI 파라미터 조정

- `--canny LOW HIGH`:
  - 값이 작을수록 더 많은 디테일/노이즈를 포착합니다.
  - 값이 클수록 더 깔끔하지만 윤곽이 덜 밀집될 수 있습니다.
- `--threshold` (`binary` 모드):
  - 낮은 값은 더 많은 밝은 영역을 전경으로 유지합니다.
  - 높은 값은 주로 어두운/고대비 영역만 유지합니다.
- `--blur`:
  - 내부에서 양수인 홀수 커널로 자동 정규화됩니다.
  - 더 큰 값은 윤곽선 추출 전 노이즈를 더 부드럽게 합니다.
- `--epsilon`:
  - 값이 클수록 경로를 더 공격적으로 단순화합니다(점 수 감소).
  - 값이 작을수록 형태 디테일을 더 보존합니다.

### 환경 변수(고급 스크립트)

- `GRSAI`는 GRS AI 추출 스크립트(예: `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`)에서 필요합니다.

가정 참고: 고급 스크립트는 환경에 따라 의존성이 다르며 현재 README 기준에서만 일부 문서화되어 있습니다. 아래 명령은 저장소 동작에 맞춘 것이며, 모든 머신에서 동일한 휴대성을 보장하지는 않습니다.

## 🧪 예시

### 래스터 → SVG

Edges 모드(선화에 적합):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary 모드(로고/평면 아트에 적합):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 이미지 추출

`.pptx`에서 임베디드 이미지를 추출해야 하는 경우(슬라이드당 한두 개 이미지 등):

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

`--dedupe`를 추가하면 슬라이드 간 중복 이미지를 건너뜁니다. `--png`를 추가하면 파일을 `p{slide}image{index}.png` 형식으로 저장합니다.

### 슬라이드 렌더링

각 슬라이드를 `page1.png`, `page2.png`로 렌더링하려면 LibreOffice(`soffice`)가 설치되어 있어야 합니다:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

또는 Python 렌더러를 사용할 수 있습니다( LibreOffice 사용 후 PDF 페이지를 PNG로 변환):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 선택적 고급 워크플로우 (스크립트)

이 스크립트는 저장소 내에 존재하며, 더 큰 분해/재구성 파이프라인에 사용할 수 있습니다:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

중요: 일부 스크립트는 현재 머신 전용 절대 경로와 외부 서비스 의존성을 포함하므로, 실제 운영에서는 실행 전 조정이 필요합니다.

## 🛠️ 개발 노트

- 기본 구현은 단일 파이썬 CLI입니다: [`aigi2vector.py`](aigi2vector.py)
- `aigi2vector.py`에서 함수/변수는 `snake_case`, 상수는 `UPPER_SNAKE_CASE` 유지
- 큰 블록보다 작고 테스트 가능한 함수를 선호
- 현재 정식 테스트 스위트는 없음
- `AIGI/`는 git에서 무시되며 로컬 자산용 디렉터리입니다.

## 🛟 문제 해결

- 입력 이미지/PPTX에서 `FileNotFoundError` 발생:
  - 입력 경로가 정확하고 읽기 가능한지 확인하세요.
- `Could not read image`:
  - OpenCV가 지원하는 형식인지, 파일이 손상되지 않았는지 확인하세요.
- SVG 출력이 비어 있거나 품질이 낮은 경우:
  - `edges` 모드에서 `--canny` 임계값을 조정해 보세요.
  - `--epsilon`을 줄여 윤곽점 보존을 늘려 보세요.
  - 대비가 높은 소스 이미지로 시작하세요.
- `LibreOffice (soffice) not found in PATH`:
  - LibreOffice를 설치하고 쉘에서 `soffice` 또는 `libreoffice`를 찾을 수 있게 PATH를 설정하세요.
- 스크립트 흐름에서 Python 패키지 누락:
  - 해당 스크립트 경로에 필요한 의존성(`python-pptx`, `Pillow`, `PyMuPDF` 등)을 설치하세요.
- GRS AI 스크립트 인증 실패:
  - 키를 내보내세요. 예: `export GRSAI=...`.

## 🗺️ 로드맵

다음 개선을 고려할 수 있습니다:

- `tests/` 아래 결정론적 샘플 이미지로 자동화 테스트 추가
- 스크립트 워크플로우용 통합된 선택적 의존성 그룹 제공
- 고급 셸 파이프라인의 이식성 개선(하드코딩 절대 경로 제거)
- 버전 관리된 샘플 자산 아래 입력/출력 예시 추가
- 유지보수되는 번역본으로 `i18n/` 채우기

## 🤝 기여

기여를 환영합니다.

권장 절차:

1. 현재 메인라인에서 fork 또는 브랜치 생성
2. 변경 범위를 좁게 유지하고 짧고 명령형 커밋 메시지를 사용
3. 변경한 CLI/스크립트 경로를 실행하고 결과를 검증
4. 동작 변경 시 README 사용법을 업데이트

테스트를 추가한다면 `tests/`에 `test_*.py` 형식으로 배치하세요.

## 📝 참고 사항

- 출력 SVG는 입력 픽셀 크기를 유지합니다. 필요하면 벡터 편집기에서 스케일하세요.
- 최상의 결과를 위해서는 대비가 높은 이미지에서 시작하세요.

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
