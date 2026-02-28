[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Chuyển ảnh raster do AI sinh ra thành các SVG vector sạch để vẽ plot.

Repo này cung cấp một CLI Python phát hiện cạnh hoặc hình dạng nhị phân trong ảnh và xuất chúng dưới dạng đường dẫn SVG. Công cụ được thiết kế cho việc vector hóa phong cách nghệ thuật, thân thiện với máy vẽ đồ họa (plotter), thay vì truy vết ảnh chân thực.

## 🎯 Tóm tắt nhanh

| Lớp | Mô tả | Vị trí |
|---|---|---|
| Core CLI | Chuyển ảnh raster thành đường dẫn SVG từ một lệnh duy nhất | [`aigi2vector.py`](aigi2vector.py) |
| Công cụ PPTX | Trích xuất nội dung slide và render trang cho quy trình vector hóa tiếp theo | `scripts/` |
| Tự động hóa tùy chọn | Pipeline hỗ trợ AI, trích xuất và ghép nối quy mô lớn | `AutoAppDev/`, `scripts/` |

## ✨ Tổng quan

`aigi2vector` gồm:

- Core CLI raster-to-SVG: [`aigi2vector.py`](aigi2vector.py)
- Công cụ PPTX tùy chọn để trích xuất ảnh nhúng và render slide sang PNG
- Script workflow bổ sung trong `scripts/` cho trích xuất bố cục, cắt ảnh và các pipeline có trợ giúp AI
- Submodule `AutoAppDev/` (công cụ bên ngoài; không bắt buộc cho CLI chính)

| Mục | Chi tiết |
|---|---|
| Mục tiêu chính | Chuyển ảnh raster thành dữ liệu SVG dạng đường dẫn |
| Chế độ chính | CLI Python một file |
| Phụ thuộc cốt lõi | `opencv-python`, `numpy` |
| Workflow tùy chọn | Trích xuất/render PPTX, pipeline script có trợ giúp AI |

## 🚀 Tính năng

- Chuyển ảnh raster thành đường dẫn SVG theo hai chế độ:
  - `edges`: phát hiện cạnh dựa trên Canny
  - `binary`: trích xuất hình dạng bằng ngưỡng nhị phân
- Điều khiển tiền xử lý:
  - Gaussian blur (`--blur`)
  - Đảo ảnh tùy chọn (`--invert`)
- Đơn giản hóa đường dẫn theo xấp xỉ Douglas-Peucker (`--epsilon`)
- SVG đầu ra giữ nguyên kích thước pixel đầu vào thông qua `width`, `height` và `viewBox`
- Tiện ích ảnh PPTX:
  - Trích xuất ảnh nhúng theo từng slide
  - Render các trang slide thành `page1.png`, `page2.png`, ...

## 🗂️ Cấu trúc dự án

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (tùy chọn cho CLI cốt lõi)
├── i18n/                            # Thư mục bản dịch (hiện là scaffold/empty)
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

## 📦 Điều kiện tiên quyết

### CLI cốt lõi

- Python 3
- `pip`
- Các phụ thuộc từ [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Công cụ PPTX tùy chọn

- Với `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Với `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` hoặc `libreoffice` trong `PATH`)
  - `PyMuPDF` (`fitz`)
- Thiết lập hỗ trợ tùy chọn:
  - Conda (cho `scripts/setup_conda_env.sh`)

### Pipeline nâng cao tùy chọn

Một số script trong `scripts/` phụ thuộc vào công cụ/dịch vụ bên ngoài (ví dụ CLI `codex` và GRS AI API). Chúng không bắt buộc để chạy `aigi2vector.py`.

## 🛠️ Cài đặt

### Bắt đầu nhanh (luồng cơ bản hiện hành)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Thiết lập Conda tùy chọn cho tiện ích PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Cách sử dụng

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Tùy chọn CLI

| Option | Mặc định | Mô tả |
|---|---|---|
| `--mode edges|binary` | `edges` | Chế độ vector hóa |
| `--canny LOW HIGH` | `100 200` | Ngưỡng thấp/cao cho chế độ edges |
| `--threshold N` | `128` | Ngưỡng nhị phân dùng trong chế độ `binary` |
| `--invert` | off | Đảo màu đen/trắng trước khi phát hiện contour |
| `--blur K` | `3` | Kích thước kernel Gaussian blur (số lẻ) |
| `--epsilon E` | `1.5` | Đơn giản hóa đường cong; giá trị cao hơn = ít điểm hơn |

### Chế độ hoạt động

- `edges` dùng phát hiện cạnh Canny và theo dõi contour bên ngoài.
- `binary` ngưỡng hóa ảnh xám rồi theo dõi contour ngoài của mask kết quả.

## ⚙️ Cấu hình

### Tinh chỉnh tham số CLI chính

- `--canny LOW HIGH`:
  - Giá trị thấp giữ nhiều chi tiết / nhiễu hơn.
  - Giá trị cao cho ra contour sạch hơn nhưng có thể thưa hơn.
- `--threshold` (binary mode):
  - Ngưỡng thấp giữ nhiều vùng sáng làm foreground hơn.
  - Ngưỡng cao giữ chủ yếu vùng tối và tương phản cao.
- `--blur`:
  - Tự động chuẩn hóa thành kernel dương và lẻ.
  - Giá trị lớn làm mượt nhiễu trước khi phát hiện contour.
- `--epsilon`:
  - Giá trị lớn đơn giản hóa đường dẫn mạnh hơn (ít điểm hơn).
  - Giá trị nhỏ giữ chi tiết hình dạng tốt hơn.

### Biến môi trường (script nâng cao)

- `GRSAI` cần cho các script trích xuất GRS AI (ví dụ `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Lưu ý giả định: các script nâng cao phụ thuộc môi trường riêng và một phần chưa được tài liệu hóa đầy đủ trong README gốc hiện tại; lệnh dưới đây giữ đúng hành vi theo repository nhưng không đảm bảo tính tương thích trên mọi máy.

## 🧪 Ví dụ

### Raster -> SVG

Edges (tốt cho line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes (tốt cho logo / flat art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Trích xuất ảnh từ PPTX

Nếu bạn cần trích xuất ảnh nhúng từ file `.pptx` (ví dụ một hoặc hai ảnh mỗi slide), hãy dùng:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Thêm `--dedupe` để bỏ qua ảnh trùng lặp giữa các slide. Thêm `--png` để lưu file là `p{slide}image{index}.png`.

### Render slides thành ảnh

Để render mỗi slide thành `page1.png`, `page2.png`, ... bạn cần cài LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Hoặc dùng Python renderer (cũng dùng LibreOffice, sau đó chuyển PDF pages sang PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Workflow nâng cao tùy chọn (scripts)

Các script sau có trong repo và có thể dùng cho pipeline phân rã/tái tạo quy mô lớn:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Quan trọng: một số script hiện có đường dẫn tuyệt đối phụ thuộc máy và phụ thuộc dịch vụ ngoài; hãy chỉnh lại trước khi đưa vào sản xuất.

## 🧰 Ghi chú phát triển

- Triển khai chính là một CLI Python duy nhất: [`aigi2vector.py`](aigi2vector.py)
- Giữ tên hàm/biến theo `snake_case`, hằng số theo `UPPER_SNAKE_CASE`
- Ưu tiên hàm nhỏ, dễ kiểm thử thay vì khối mã lớn
- Hiện chưa có bộ test chính thức
- `AIGI/` bị bỏ qua bởi git và dành cho tài sản cục bộ

## 🛟 Xử lý sự cố

- `FileNotFoundError` với ảnh/PPTX đầu vào:
  - Kiểm tra xem đường dẫn đầu vào có đúng và có quyền đọc.
- `Could not read image`:
  - Xác nhận định dạng tệp được OpenCV hỗ trợ và tệp không bị hỏng.
- SVG đầu ra rỗng hoặc kém chất lượng:
  - Thử `--mode binary` với `--threshold` đã tinh chỉnh.
  - Điều chỉnh ngưỡng `--canny` trong chế độ `edges`.
  - Giảm `--epsilon` để giữ nhiều điểm contour hơn.
  - Bắt đầu từ ảnh nguồn có độ tương phản cao hơn.
- `LibreOffice (soffice) not found in PATH`:
  - Cài LibreOffice và đảm bảo `soffice` hoặc `libreoffice` có trong shell của bạn.
- Thiếu gói Python cho các luồng script:
  - Cài các phụ thuộc cần thiết cho script đó (`python-pptx`, `Pillow`, `PyMuPDF`, v.v.).
- Script GRS AI lỗi xác thực:
  - Xuất khóa của bạn, ví dụ: `export GRSAI=...`.

## 🗺️ Lộ trình

Các cải tiến dự kiến:

- Thêm test tự động trong `tests/` với ảnh mẫu xác định
- Phát hành nhóm phụ thuộc tùy chọn thống nhất cho workflow script
- Cải thiện khả năng di động của các pipeline shell nâng cao (loại bỏ đường dẫn tuyệt đối hardcode)
- Thêm ví dụ input/output tham chiếu dưới dạng tài nguyên mẫu có phiên bản
- Bổ sung các bản README dịch đã được duy trì trong `i18n/`

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |
