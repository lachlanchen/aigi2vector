[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

حوّل صورًا نقطية مُنشأة بالذكاء الاصطناعي إلى ملفات SVG متجهة نظيفة للرسم.

يوفر هذا المستودع أداة CLI بلغة Python تكتشف الحواف أو الأشكال الثنائية في الصورة وتُخرجها كمسارات SVG. صُمِّمت لكونها مناسبة للتحويل الموجَّه للرسم على آلات الرسم (plotter)، بدل تتبع الصور الفوتورياليستية.

## 🧰 لمحة سريعة (مصفوفة سريعة)

| المجال | الموقع | الغرض |
|---|---|---|
| التحويل الأساسي | [`aigi2vector.py`](aigi2vector.py) | تحويل صور raster أو الصور المستخرجة من PPTX إلى SVG |
| أدوات PPTX الاختيارية | `scripts/` | استخراج وعرض عناصر الشرائح |
| الأتمتة الموسعة | `AutoAppDev/` | حزمة أتمتة خارجية اختيارية |

---

## 📚 جدول المحتويات

- لمحة سريعة (خريطة سريعة)
- نظرة عامة
- المزايا
- بنية المشروع
- المتطلبات المسبقة
- التثبيت
- الاستخدام
- سير العمل المرئي
- الإعداد
- أمثلة
- ملاحظات التطوير
- استكشاف الأخطاء وإصلاحها
- خارطة الطريق
- المساهمة
- الملاحظات
- الدعم
- الترخيص

## 🧭 لمحة سريعة (خريطة سريعة)

| حالة الاستخدام | نقطة الدخول | الناتج |
|---|---|---|
| تحويل صورة واحدة إلى SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| ضبط مستوى التفاصيل | خيارات CLI في قسم [`الاستخدام`](#-الاستخدام) (`--mode`, `--canny`, `--epsilon`، وغيرها) | حدود أنظف أو أكثر كثافة |
| معالجة أصول PPTX | أدوات `scripts/` + بيئة conda اختيارية | صور مستخرجة + PNG للشرائح |

## 🎯 لمحة سريعة

| الطبقة | الوصف | الموقع |
|---|---|---|
| CLI الأساسية | تحويل الصور النقطية إلى مسارات SVG بأمر واحد | [`aigi2vector.py`](aigi2vector.py) |
| أدوات PPTX | استخراج محتوى الشرائح وعرض الصفحات لتسهيل التتبع المتجه | `scripts/` |
| أتمتة اختيارية | تدفقات عمل أكبر تشمل الاستخراج والتركيب المدعوم بالـ AI | `AutoAppDev/`, `scripts/` |

## ✨ نظرة عامة

`aigi2vector` يتضمن:

- واجهة CLI أساسية للتحويل من raster إلى SVG: [`aigi2vector.py`](aigi2vector.py)
- أدوات PPTX اختيارية لاستخراج الصور المضمنة وعرض الشرائح كـ PNG
- سكربتات إضافية ضمن `scripts/` لاستخراج التخطيطات والاقتصاص وسلاسل العمل المدعومة بالـ AI
- فرع فرعي `AutoAppDev/` (أدوات خارجية؛ غير مطلوب لتشغيل CLI الأساسية)

| العنصر | التفاصيل |
|---|---|---|
| الهدف الأساسي | تحويل الصور النقطية إلى إخراج مسارات SVG |
| نمط التشغيل | CLI Python في ملف واحد |
| المتطلبات الأساسية | `opencv-python`، `numpy` |
| سلاسل عمل اختيارية | استخراج/عرض PPTX، وسلاسل سكربتات مساعدة بالـ AI |

## 🚀 المزايا

- تحويل الصور النقطية إلى مسارات SVG عبر وضعين:
  - `edges`: كشف الحواف باستخدام Canny
  - `binary`: استخراج الشكل عبر العتبة الثنائية
- عناصر تحكم في المعالجة المسبقة:
  - Gaussian blur (`--blur`)
  - عكس الألوان اختياريًا (`--invert`)
- تبسيط المسار باستخدام تقريب Douglas-Peucker (`--epsilon`)
- إخراج SVG يحافظ على أبعاد البكسل الأصلية عبر `width` و`height` و`viewBox`
- أدوات PPTX:
  - استخراج الصور المضمنة حسب الشريحة
  - عرض صفحات `page1.png`، `page2.png`، ...

## 🗂️ بنية المشروع

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

## 📦 المتطلبات المسبقة

### CLI الأساسية

- Python 3
- `pip`
- المتطلبات من [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### أدوات PPTX الاختيارية

- لـ `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- لـ `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` أو `libreoffice` في `PATH`)
  - `PyMuPDF` (`fitz`)
- إعداد مساعد اختياري:
  - Conda (لكـ `scripts/setup_conda_env.sh`)

### خطوط أنابيب متقدمة اختيارية

تعتمد عدة سكربتات ضمن `scripts/` على أدوات/خدمات خارجية (مثل CLI الخاص بـ `codex` وواجهات GRS AI). هذه اختيارية وليست مطلوبة لتشغيل `aigi2vector.py`.

## 🛠️ التثبيت

### البدء السريع (المسار القياسي الحالي)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### إعداد Conda اختياري لأدوات PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ الاستخدام

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### خيارات CLI

| الخيار | القيمة الافتراضية | الوصف |
|---|---|---|
| `--mode edges|binary` | `edges` | وضع التحويل المتجهي |
| `--canny LOW HIGH` | `100 200` | عتبات منخفضة/مرتفعة لوضع الحواف |
| `--threshold N` | `128` | عتبة ثنائية تُستخدم في `binary` |
| `--invert` | off | عكس اللون الأسود/الأبيض قبل اكتشاف الحواف |
| `--blur K` | `3` | حجم نواة Gaussian blur (عدد فردي) |
| `--epsilon E` | `1.5` | تبسيط المنحنيات؛ القيمة الأعلى = نقاط أقل |

### طريقة عمل الأوضاع

- `edges` يشغّل كشف الحواف باستخدام Canny ويتبع الحدود الخارجية.
- `binary` يطبّق عتبة على التدرج الرمادي ويتبع الحدود الخارجية لقناع النتيجة.

## 🔧 سير العمل المرئي

```text
Input image/PPTX slide assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (اختياري)
   |
   v
Raster tracing + contour simplification
   |
   v
SVG output
```

## ⚙️ الإعداد

### ضبط معلمات CLI الرئيسية

- `--canny LOW HIGH`:
  - القيم الأقل تلتقط تفاصيل/ضوضاء أكثر.
  - القيم الأعلى تنتج حدودًا أنظف لكنها قد تكون أقل كثافة.
- `--threshold` (الوضع الثنائي):
  - العتبة المنخفضة تحافظ على المزيد من المناطق الفاتحة كـ foreground.
  - العتبة المرتفعة تحافظ غالبًا على المناطق الداكنة عالية التباين.
- `--blur`:
  - تُضبط داخليًا تلقائيًا إلى نواة فردية موجبة.
  - القيم الأكبر تُنعم الضجيج قبل كشف الحدود.
- `--epsilon`:
  - القيم الأعلى تُبسّط المسارات بشكل أكثر (عدد نقاط أقل).
  - القيم الأقل تحافظ على تفاصيل الشكل.

### متغيرات البيئة (سكربتات متقدمة)

- `GRSAI` مطلوب بواسطة سكربتات استخراج GRS AI (مثل `extract_part_grsai.py`، `extract_elements_grsai_pipeline.py`، `extract_elements_from_prompt_json.py`).

ملاحظة افتراضية: سكربتات المتقدمة تعتمد على البيئة الخاصة ونُصّبت جزئيًا في README الأساسي الحالي؛ الأوامر التالية تُحافظ على سلوك المستودع الفعلي دون ضمان قابلية تشغيل موحدة على جميع الأجهزة.

## 🧪 أمثلة

### تحويل raster إلى SVG

الـ edges (مفيد لفنون الخطوط):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

الأشكال الثنائية (مناسبة للشعارات / الرسوم المسطحة):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### استخراج صور PPTX

إذا كنت تحتاج لاستخراج الصور المضمنة من ملف `.pptx` (مثل صورة واحدة أو اثنتين لكل شريحة)، استخدم:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

أضف `--dedupe` لتخطي الصور المكررة عبر الشرائح. أضف `--png` لحفظ الملفات كـ `p{slide}image{index}.png`.

### عرض الشرائح كصور

لعرض كل شريحة إلى `page1.png`، `page2.png`، ... يجب تثبيت LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

أو استخدم مفسّر Python (ويستخدم أيضًا LibreOffice ثم يحوّل صفحات PDF إلى PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### خطوط أنابيب متقدمة اختيارية (سكربتات)

هذه السكربتات موجودة داخل المستودع ويمكن استخدامها في خطوط أنابيب أكبر للتحليل وإعادة البناء:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

مهم: بعض هذه السكربتات ما زالت تحتوي على مسارات مطلقة خاصة بجهاز معيّن واعتماديات خدمات خارجية؛ عدّلها قبل استخدام الإنتاج.

## 🛠️ ملاحظات التطوير

- التنفيذ الأساسي هو CLI Python من ملف واحد: [`aigi2vector.py`](aigi2vector.py)
- احتفظ بأسماء الدوال/المتغيرات بصيغة `snake_case`، والثوابت بصيغة `UPPER_SNAKE_CASE`
- قدّم وظائف صغيرة يمكن اختبارها بدلاً من كتل ضخمة
- لا يوجد في الوقت الحالي إطار اختبارات رسمي
- `AIGI/` متجاهلة في Git ومخصصة للأصول المحلية

## 🛟 استكشاف الأخطاء وإصلاحها

- `FileNotFoundError` للصورة/PPTX المدخلة:
  - تحقق من أن مسار الإدخال صحيح وقابل للقراءة.
- `Could not read image`:
  - تأكد من أن تنسيق الملف مدعوم من OpenCV وغير تالف.
- إخراج SVG فارغ أو منخفض الجودة:
  - جرّب `--mode binary` مع ضبط `--threshold`.
  - اضبط عتبات `--canny` في وضع `edges`.
  - قلّل `--epsilon` للحفاظ على نقاط الشكل.
  - ابدأ بصورة ذات تباين أعلى.
- `LibreOffice (soffice) not found in PATH`:
  - ثبّت LibreOffice وتأكد أن `soffice` أو `libreoffice` موجودان في `PATH`.
- حزم Python مفقودة في مسارات السكربتات:
  - ثبّت المتطلبات اللازمة لمسار السكربت (`python-pptx`، `Pillow`، `PyMuPDF`، وغيرها).
- فشل سكربتات GRS AI بسبب أخطاء المصادقة:
  - صدر المفتاح، مثلًا: `export GRSAI=...`.

## 🗺️ خارطة الطريق

التحسينات المحتملة القادمة:

- إضافة اختبارات آلية تحت `tests/` بصور عينات صغيرة قابلة لإعادة الإنتاج
- نشر مجموعات تبعيات اختيارية موحدة لسير عمل السكربتات
- تحسين قابلية نقل خطوط الأنبوب المتقدمة (إزالة المسارات المطلقة)
- إضافة أمثلة مدخل/مخرج ضمن أصول عينات محدثة
- إكمال `i18n/` بقراءات README مترجمة ومُدارة

## 🤝 المساهمة

المساهمات مرحبة.

الخطوات المقترحة:

1. اعمل fork أو أنشئ فرعًا من الخط الرئيسي الحالي.
2. اجعل التغييرات مركّزة واستخدم رسائل commit قصيرة ومفروضة.
3. شغّل الأوامر ذات الصلة بالمسار الذي عدّلته وتأكد من المخرجات.
4. حدّث ملاحظات الاستخدام في README عند تغيّر السلوك.

إذا أضفت اختبارات، ضعها تحت `tests/` وسمِّ الملفات `test_*.py`.

## 📝 ملاحظات

- SVG الناتج يستخدم أبعاد البكسل للإدخال. اضبط المقياس في محرر المتجهات إذا لزم الأمر.
- لأفضل النتائج، ابدأ بصورة ذات تباين عالٍ.

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
