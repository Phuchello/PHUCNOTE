# Copyright (c) 2026 PhucNote Authors. All rights reserved.
# Use of this source code is governed by an AGPL-3.0 license that can be
# found in the LICENSE file.

import os
from PIL import Image, ImageDraw, ImageFont

def build_contact_sheet():
    input_dir = r"artifacts\concept-a-document-lab"
    output_path = os.path.join(input_dir, "DOCUMENT_LAB_CONTACT_SHEET.png")

    items = [
        ("concept_a_library_mixed.png", "01. Thư viện học thuật mở rộng (Hỗn hợp Sổ tay + PDF + Slide + Bản quét)"),
        ("concept_a_pdf_reader_landscape.png", "02. Trình đọc PDF A4 — Chế độ Ngang (Oxford Navy + Giấy Ngà Atelier)"),
        ("concept_a_pdf_reader_portrait.png", "03. Trình đọc PDF A4 — Chế độ Dọc (Vừa vặn màn hình Tablet, không tràn viền)"),
        ("concept_a_pdf_annotated.png", "04. Chú thích PDF (Bút mực đỏ, dạ quang vàng, khoanh vùng công thức Dijkstra)"),
        ("concept_a_pdf_thumbnails.png", "05. Ngăn kéo xem trước trang (Thumbnail Drawer điều hướng trang nhanh)"),
        ("concept_a_slide_landscape.png", "06. Trình đọc Slide 16:9 — Chế độ Ngang (Chuẩn tỷ lệ bài giảng, không méo A4)"),
        ("concept_a_slide_portrait.png", "07. Trình đọc Slide 16:9 — Chế độ Dọc (Letterbox chuẩn, thanh công cụ gọn)"),
        ("concept_a_slide_annotated.png", "08. Chú thích Slide (Dạ quang cyan, đóng khung kiến trúc mạng & ghi chú)"),
        ("concept_a_split_slide_study.png", "09. Không gian học đôi: Slide 16:9 (Trái) + Sổ tay viết tay PhucNote (Phải)"),
        ("concept_a_split_pdf_study.png", "10. Không gian học đôi: PDF A4 (Trái) + Sổ tay viết tay PhucNote (Phải)"),
        ("concept_a_doc_reader_dark.png", "11. Trình đọc tài liệu Dark-Theme (Đêm học thuật, nền đá phiến sâu & nhũ vàng)"),
        ("concept_a_compact_narrow.png", "12. Khung nhìn hẹp Tablet Compact (Giao diện đáp ứng, phím tắt thu gọn an toàn)"),
    ]

    # Grid: 4 columns x 3 rows
    cols = 4
    rows = 3
    card_w = 640
    card_h = 440
    pad_x = 24
    pad_y = 24
    header_h = 130
    footer_h = 60

    canvas_w = pad_x + cols * (card_w + pad_x)
    canvas_h = header_h + rows * (card_h + pad_y) + footer_h

    # Atelier palette
    bg_color = (15, 23, 42)          # Deep Oxford Navy #0F172A
    card_bg = (24, 33, 47)           # Slate Navy #18212F
    gold_accent = (212, 175, 55)     # #D4AF37
    gold_soft = (253, 230, 138)      # #FDE68A
    text_white = (248, 250, 252)
    text_muted = (148, 163, 184)
    border_card = (51, 65, 85)

    sheet = Image.new("RGBA", (canvas_w, canvas_h), bg_color)
    draw = ImageDraw.Draw(sheet)

    # Load system font
    try:
        font_title = ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", 34)
        font_sub = ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf", 18)
        font_card = ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", 15)
        font_footer = ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf", 14)
    except Exception:
        font_title = ImageFont.load_default()
        font_sub = font_title
        font_card = font_title
        font_footer = font_title

    # Header decorative border
    draw.rectangle([pad_x, pad_x, canvas_w - pad_x, header_h - 15], outline=gold_accent, width=2)
    draw.text((pad_x + 20, pad_x + 15), "PHUCNOTE — CONCEPT A: DOCUMENT EXPERIENCE LAB", fill=gold_soft, font=font_title)
    draw.text(
        (pad_x + 20, pad_x + 60),
        "Atelier Academic Document Reader, 16:9 Slide Workspace & Split Study Annotations (12 Verified Screen States)",
        fill=text_white,
        font=font_sub
    )

    badge_rect = [canvas_w - pad_x - 220, pad_x + 20, canvas_w - pad_x - 20, pad_x + 65]
    draw.rectangle(badge_rect, fill=(30, 58, 138), outline=gold_accent, width=1)
    draw.text((badge_rect[0] + 16, badge_rect[1] + 12), "ACADEMIC ATELIER V2", fill=gold_soft, font=font_card)

    for idx, (filename, label) in enumerate(items):
        r = idx // cols
        c = idx % cols

        x0 = pad_x + c * (card_w + pad_x)
        y0 = header_h + r * (card_h + pad_y)
        x1 = x0 + card_w
        y1 = y0 + card_h

        # Card container
        draw.rectangle([x0, y0, x1, y1], fill=card_bg, outline=border_card, width=1)

        # Label banner at top of card
        draw.rectangle([x0, y0, x1, y0 + 36], fill=(30, 41, 59))
        draw.line([x0, y0 + 36, x1, y0 + 36], fill=gold_accent, width=1)
        draw.text((x0 + 12, y0 + 10), label, fill=gold_soft, font=font_card)

        # Image thumbnail
        img_path = os.path.join(input_dir, filename)
        if os.path.exists(img_path):
            img = Image.open(img_path)
            max_thumb_w = card_w - 20
            max_thumb_h = card_h - 52

            # Maintain aspect ratio
            img_ratio = img.width / img.height
            box_ratio = max_thumb_w / max_thumb_h

            if img_ratio > box_ratio:
                tw = max_thumb_w
                th = int(tw / img_ratio)
            else:
                th = max_thumb_h
                tw = int(th * img_ratio)

            img_thumb = img.resize((tw, th), Image.Resampling.LANCZOS)
            tx = x0 + (card_w - tw) // 2
            ty = y0 + 44 + (max_thumb_h - th) // 2

            sheet.paste(img_thumb, (tx, ty))
            draw.rectangle([tx, ty, tx + tw, ty + th], outline=(71, 85, 105), width=1)

    # Footer
    footer_text = "Tất cả 12 ảnh chụp màn hình được render trực tiếp từ Android tablet emulator (2560x1600) • Giao diện Concept A tiếng Việt chuẩn học thuật."
    draw.text((pad_x, canvas_h - 40), footer_text, fill=text_muted, font=font_footer)

    sheet.save(output_path, "PNG", optimize=True)
    print(f"Generated {output_path} ({os.path.getsize(output_path)} bytes)")

if __name__ == "__main__":
    build_contact_sheet()
