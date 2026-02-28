[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Chuyển ảnh raster do AI tạo thành các SVG vector gọn, sạch, phù hợp cho máy vẽ.

Kho này cung cấp một CLI Python có thể phát hiện biên hoặc hình nhị phân trong ảnh và ghi chúng thành các đường dẫn SVG. Công cụ được thiết kế cho vector hóa kiểu cách, thân thiện với plotter, thay vì truy vết ảnh chân thực.

## ✨ Tổng quan

`aigi2vector` bao gồm:

- CLI raster-to-SVG cốt lõi: [`aigi2vector.py`](aigi2vector.py)
- Các tiện ích PPTX tùy chọn để trích xuất ảnh nhúng và render slide sang PNG
- Các script workflow bổ sung trong `scripts/` cho trích xuất bố cục, crop, và pipeline có hỗ trợ AI
- Submodule `AutoAppDev/` (công cụ bên ngoài; không bắt buộc cho CLI chính)

| Mục | Chi tiết |
|---|---|
| Mục đích cốt lõi | Chuyển ảnh raster thành SVG dạng path |
| Chế độ chính | CLI Python một file |
| Phụ thuộc cốt lõi | `opencv-python`, `numpy` |
| Workflow tùy chọn | Trích xuất/render PPTX, pipeline script có hỗ trợ AI |

## 🚀 Tính năng

- Chuyển ảnh raster thành SVG path với hai chế độ:
  - `edges`: phát hiện biên dựa trên Canny
  - `binary`: trích xuất hình bằng ngưỡng nhị phân
- Điều khiển tiền xử lý:
  - Gaussian blur (`--blur`)
  - Đảo màu tùy chọn (`--invert`)
- Đơn giản hóa path bằng xấp xỉ Douglas-Peucker (`--epsilon`)
- SVG đầu ra giữ nguyên kích thước pixel đầu vào qua `width`, `height`, và `viewBox`
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
├── i18n/                            # Thư mục bản dịch (hiện là scaffold/rỗng)
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
- Các phụ thuộc trong [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Tiện ích PPTX tùy chọn

- Cho `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Cho `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` hoặc `libreoffice` trong `PATH`)
  - `PyMuPDF` (`fitz`)
- Thiết lập trợ giúp tùy chọn:
  - Conda (cho `scripts/setup_conda_env.sh`)

### Pipeline nâng cao tùy chọn

Một số script trong `scripts/` phụ thuộc vào công cụ/dịch vụ bên ngoài (ví dụ CLI `codex` và API GRS AI). Đây là phần tùy chọn và không cần thiết để chạy `aigi2vector.py`.

## 🛠️ Cài đặt

### Khởi động nhanh (luồng chuẩn hiện tại)

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

## ▶️ Cách dùng

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Tùy chọn CLI

| Option | Default | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | Chế độ vector hóa |
| `--canny LOW HIGH` | `100 200` | Ngưỡng thấp/cao cho chế độ edges |
| `--threshold N` | `128` | Ngưỡng nhị phân dùng trong chế độ `binary` |
| `--invert` | off | Đảo đen/trắng trước khi phát hiện contour |
| `--blur K` | `3` | Kích thước kernel Gaussian blur (số lẻ) |
| `--epsilon E` | `1.5` | Đơn giản hóa đường cong; cao hơn = ít điểm hơn |

### Cách các chế độ hoạt động

- Chế độ `edges` chạy phát hiện biên Canny và truy vết contour ngoài.
- Chế độ `binary` nhị phân hóa ảnh xám theo ngưỡng rồi truy vết contour ngoài của mask thu được.

## ⚙️ Cấu hình

### Tinh chỉnh tham số CLI chính

- `--canny LOW HIGH`:
  - Giá trị thấp hơn sẽ giữ nhiều chi tiết/nhiễu hơn.
  - Giá trị cao hơn cho contour sạch hơn nhưng có thể thưa hơn.
- `--threshold` (chế độ binary):
  - Ngưỡng thấp giữ nhiều vùng sáng làm foreground hơn.
  - Ngưỡng cao chủ yếu giữ vùng tối/tương phản mạnh.
- `--blur`:
  - Nội bộ tự chuẩn hóa thành kernel lẻ dương.
  - Giá trị lớn hơn làm mượt nhiễu trước khi tìm contour.
- `--epsilon`:
  - Giá trị lớn đơn giản hóa path mạnh hơn (ít điểm hơn).
  - Giá trị nhỏ giữ lại nhiều chi tiết hình dạng hơn.

### Biến môi trường (script nâng cao)

- `GRSAI` bắt buộc cho các script trích xuất GRS AI (ví dụ `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Ghi chú giả định: các script nâng cao phụ thuộc môi trường và hiện vẫn chưa được tài liệu hóa đầy đủ trong baseline README; các lệnh bên dưới giữ hành vi đúng với repository nhưng không đảm bảo tính di động trên mọi máy.

## 🧪 Ví dụ

### Raster sang SVG

Edges (phù hợp cho line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes (phù hợp cho logo / flat art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### Trích xuất ảnh từ PPTX

Nếu bạn cần trích xuất ảnh nhúng từ `.pptx` (ví dụ mỗi slide có một hoặc hai ảnh), dùng:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Thêm `--dedupe` để bỏ qua ảnh trùng giữa các slide. Thêm `--png` để lưu file dạng `p{slide}image{index}.png`.

### Render slide thành ảnh

Để render từng slide thành `page1.png`, `page2.png`, ... bạn cần cài LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Hoặc dùng bản render Python (cũng dùng LibreOffice, sau đó chuyển trang PDF sang PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Workflow nâng cao tùy chọn (scripts)

Các script sau có sẵn trong repo và có thể dùng cho pipeline phân rã/tái dựng quy mô lớn:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Quan trọng: một số script hiện chứa đường dẫn tuyệt đối phụ thuộc máy và phụ thuộc dịch vụ bên ngoài; hãy chỉnh lại trước khi dùng production.

## 🧰 Ghi chú phát triển

- Triển khai chính là CLI Python một file: [`aigi2vector.py`](aigi2vector.py)
- Dùng `snake_case` cho tên hàm/biến, `UPPER_SNAKE_CASE` cho hằng số
- Ưu tiên hàm nhỏ, dễ kiểm thử thay vì khối mã lớn
- Hiện chưa có bộ test chính thức
- `AIGI/` bị git bỏ qua và dành cho tài nguyên cục bộ

## 🛟 Khắc phục sự cố

- `FileNotFoundError` cho ảnh/PPTX đầu vào:
  - Kiểm tra đường dẫn đầu vào chính xác và có quyền đọc.
- `Could not read image`:
  - Xác nhận định dạng file được OpenCV hỗ trợ và file không bị hỏng.
- SVG đầu ra rỗng hoặc chất lượng kém:
  - Thử `--mode binary` và tinh chỉnh `--threshold`.
  - Điều chỉnh ngưỡng `--canny` trong chế độ `edges`.
  - Giảm `--epsilon` để giữ nhiều điểm contour hơn.
  - Bắt đầu với ảnh nguồn có tương phản cao hơn.
- `LibreOffice (soffice) not found in PATH`:
  - Cài LibreOffice và đảm bảo `soffice` hoặc `libreoffice` có thể được tìm thấy trong shell.
- Thiếu gói Python cho các luồng script:
  - Cài các phụ thuộc cần thiết cho script tương ứng (`python-pptx`, `Pillow`, `PyMuPDF`, v.v.).
- Script GRS AI lỗi xác thực:
  - Export key của bạn, ví dụ: `export GRSAI=...`.

## 🗺️ Lộ trình

Các cải tiến tiềm năng tiếp theo:

- Thêm test tự động trong `tests/` với ảnh mẫu xác định (deterministic)
- Phát hành các nhóm phụ thuộc tùy chọn thống nhất cho các workflow script
- Cải thiện tính di động của pipeline shell nâng cao (loại bỏ đường dẫn tuyệt đối hardcode)
- Thêm ví dụ input/output tham chiếu trong bộ tài nguyên mẫu có version
- Bổ sung các bản README dịch được duy trì trong `i18n/`

## 🤝 Đóng góp

Hoan nghênh đóng góp.

Quy trình gợi ý:

1. Fork hoặc tạo branch từ mainline hiện tại.
2. Giữ thay đổi tập trung và dùng commit message ngắn, dạng mệnh lệnh.
3. Chạy các lệnh liên quan mà bạn đã chỉnh (CLI/script path) và xác minh đầu ra.
4. Cập nhật ghi chú cách dùng trong README khi hành vi thay đổi.

Nếu bạn thêm test, đặt dưới `tests/` và đặt tên file `test_*.py`.

## 📝 Ghi chú

- SVG đầu ra dùng kích thước pixel của ảnh đầu vào. Hãy scale trong trình chỉnh sửa vector nếu cần.
- Để có kết quả tốt nhất, hãy bắt đầu với ảnh có độ tương phản cao.

## License

MIT
