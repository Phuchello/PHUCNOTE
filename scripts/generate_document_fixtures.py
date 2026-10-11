import os
import io
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import fitz  # PyMuPDF
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

OUTPUT_DIR = os.path.abspath(r"fixtures\document_lab")
RENDERS_DIR = os.path.join(OUTPUT_DIR, "renders")

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(RENDERS_DIR, exist_ok=True)

FONT_REG = "C:/Windows/Fonts/arial.ttf"
FONT_BOLD = "C:/Windows/Fonts/arialbd.ttf"
FONT_MONO = "C:/Windows/Fonts/consola.ttf"

def setup_page_fonts(page):
    page.insert_font(fontname="Arial", fontfile=FONT_REG)
    page.insert_font(fontname="ArialBold", fontfile=FONT_BOLD)
    page.insert_font(fontname="Consolas", fontfile=FONT_MONO)

# -------------------------------------------------------------------------
# 1. GENERATE 4-PAGE A4 LECTURE PDF (Toán Rời Rạc & Lý Thuyết Đồ Thị)
# -------------------------------------------------------------------------
def generate_a4_lecture_pdf():
    pdf_path = os.path.join(OUTPUT_DIR, "lecture_notes_discrete_math.pdf")
    doc = fitz.open()
    
    # A4 Dimensions: 595.3 x 841.9 points
    w, h = 595.3, 841.9
    
    # --- PAGE 1: Lý Thuyết Đồ Thị & Bậc Đỉnh ---
    p1 = doc.new_page(width=w, height=h)
    setup_page_fonts(p1)
    
    # Header rule & university title
    p1.draw_rect(fitz.Rect(50, 45, 545, 46), color=(0.1, 0.15, 0.25), fill=(0.1, 0.15, 0.25))
    p1.insert_text(fitz.Point(50, 40), "ĐẠI HỌC BÁCH KHOA — KHOA KHOA HỌC MÁY TÍNH", fontsize=8, fontname="ArialBold", color=(0.3, 0.35, 0.45))
    p1.insert_text(fitz.Point(440, 40), "HỌC KỲ I · 2026–2027", fontsize=8, fontname="ArialBold", color=(0.3, 0.35, 0.45))
    
    # Title & Metadata
    p1.insert_text(fitz.Point(50, 75), "BÀI GIẢNG 08: LÝ THUYẾT ĐỒ THỊ & THUẬT TOÁN ĐƯỜNG ĐI", fontsize=15, fontname="ArialBold", color=(0.1, 0.15, 0.25))
    p1.insert_text(fitz.Point(50, 92), "Môn học: Toán Rời Rạc (CO2003) | Giảng viên: TS. Nguyễn Văn Phúc | Tài liệu lưu hành nội bộ", fontsize=8.5, fontname="Arial", color=(0.4, 0.45, 0.5))
    
    # Abstract Box
    p1.draw_rect(fitz.Rect(50, 105, 545, 150), color=(0.85, 0.88, 0.92), fill=(0.95, 0.96, 0.98))
    p1.draw_rect(fitz.Rect(50, 105, 54, 150), color=(0.1, 0.3, 0.6), fill=(0.1, 0.3, 0.6))
    p1.insert_text(fitz.Point(62, 120), "Tóm tắt bài học:", fontsize=9.5, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    p1.insert_textbox(fitz.Rect(62, 124, 535, 148), 
        "Bài giảng cung cấp nền tảng toán học về đồ thị hữu hạn G = (V, E), các định lý cơ bản về bậc của đỉnh, "
        "bổ đề bắt tay (Handshaking Lemma), phương pháp biểu diễn ma trận kề và danh sách kề, cùng với thuật toán tìm kiếm đường đi ngắn nhất.",
        fontsize=8.5, fontname="Arial", color=(0.2, 0.25, 0.3))

    # Section 1
    p1.insert_text(fitz.Point(50, 175), "1. ĐỊNH NGHĨA VÀ BẬC CỦA ĐỈNH TRONG ĐỒ THỊ VÔ HƯỚNG", fontsize=11, fontname="ArialBold", color=(0.1, 0.2, 0.35))
    p1.insert_textbox(fitz.Rect(50, 182, 545, 235),
        "Một đồ thị vô hướng G được xác định bởi cặp tập hợp G = (V, E), trong đó V là tập các đỉnh (vertices) khác rỗng "
        "và E là tập các cạnh (edges) nối các cặp đỉnh. Bậc của đỉnh v trong G, ký hiệu deg(v), là số cạnh liên thuộc với v, "
        "với quy ước khuyên (loop) đóng góp 2 vào bậc của đỉnh.",
        fontsize=9, fontname="Arial", color=(0.15, 0.15, 0.15))
    
    # Theorem 1 Box
    p1.draw_rect(fitz.Rect(50, 240, 545, 305), color=(0.8, 0.7, 0.4), fill=(0.99, 0.98, 0.94))
    p1.insert_text(fitz.Point(60, 256), "Định lý 1.1 (Bổ đề bắt tay — Handshaking Lemma):", fontsize=9.5, fontname="ArialBold", color=(0.6, 0.35, 0.0))
    p1.insert_text(fitz.Point(60, 274), "Cho đồ thị vô hướng G = (V, E) có |V| đỉnh và |E| cạnh. Khi đó:", fontsize=9, fontname="Arial", color=(0.2, 0.2, 0.2))
    p1.insert_text(fitz.Point(210, 292), "∑ deg(v) = 2 · |E|   (v ∈ V)", fontsize=11, fontname="ArialBold", color=(0.1, 0.2, 0.5))

    # Corollary
    p1.insert_textbox(fitz.Rect(50, 315, 545, 350),
        "Hệ quả 1.1: Trong mọi đồ thị vô hướng, số lượng đỉnh có bậc lẻ luôn là một số chẵn. "
        "Chứng minh: Gọi V_chẵn và V_lẻ lần lượt là tập đỉnh bậc chẵn và bậc lẻ. Tổng bậc của toàn bộ đỉnh bằng 2|E| (số chẵn), "
        "mà tổng bậc các đỉnh thuộc V_chẵn là chẵn, do đó tổng bậc các đỉnh thuộc V_lẻ phải là một số chẵn, suy ra |V_lẻ| là số chẵn.",
        fontsize=8.5, fontname="Arial", color=(0.2, 0.2, 0.2))

    # Graph diagram (drawing vector nodes and edges)
    p1.insert_text(fitz.Point(50, 370), "Minh họa 1.1: Đồ thị mẫu G1 với 5 đỉnh và 6 cạnh", fontsize=9.5, fontname="ArialBold", color=(0.2, 0.25, 0.35))
    nodes = [(120, 440, "v1"), (220, 400, "v2"), (320, 440, "v3"), (270, 510, "v4"), (170, 510, "v5")]
    edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0), (1, 3)]
    for e1, e2 in edges:
        p1.draw_line(fitz.Point(nodes[e1][0], nodes[e1][1]), fitz.Point(nodes[e2][0], nodes[e2][1]), color=(0.2, 0.4, 0.7), width=1.5)
    for x, y, name in nodes:
        p1.draw_circle(fitz.Point(x, y), 14, color=(0.1, 0.25, 0.5), fill=(0.95, 0.97, 1.0), width=1.5)
        p1.insert_text(fitz.Point(x - 6, y + 4), name, fontsize=9, fontname="ArialBold", color=(0.1, 0.2, 0.4))
        
    # Table of degrees
    p1.insert_text(fitz.Point(375, 400), "Bảng bậc của các đỉnh:", fontsize=8.5, fontname="ArialBold", color=(0.2, 0.2, 0.3))
    table_x, table_y = 375, 410
    rows = [
        ["v1", "{v2, v5}", "2"],
        ["v2", "{v1, v3, v4}", "3"],
        ["v3", "{v2, v4}", "2"],
        ["v4", "{v2, v3, v5}", "3"],
        ["v5", "{v1, v4}", "2"],
    ]
    p1.draw_rect(fitz.Rect(table_x, table_y, table_x + 160, table_y + 115), color=(0.7, 0.75, 0.8), fill=(1, 1, 1))
    p1.draw_rect(fitz.Rect(table_x, table_y, table_x + 160, table_y + 20), color=(0.7, 0.75, 0.8), fill=(0.9, 0.93, 0.97))
    p1.insert_text(fitz.Point(table_x + 8, table_y + 14), "Đỉnh", fontsize=8, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    p1.insert_text(fitz.Point(table_x + 45, table_y + 14), "Đỉnh kề", fontsize=8, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    p1.insert_text(fitz.Point(table_x + 115, table_y + 14), "deg(v)", fontsize=8, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    for idx, r in enumerate(rows):
        ry = table_y + 20 + idx * 19
        p1.draw_line(fitz.Point(table_x, ry), fitz.Point(table_x + 160, ry), color=(0.85, 0.88, 0.9))
        p1.insert_text(fitz.Point(table_x + 12, ry + 13), r[0], fontsize=8, fontname="Arial", color=(0.1, 0.1, 0.1))
        p1.insert_text(fitz.Point(table_x + 45, ry + 13), r[1], fontsize=8, fontname="Arial", color=(0.1, 0.1, 0.1))
        p1.insert_text(fitz.Point(table_x + 128, ry + 13), r[2], fontsize=8, fontname="ArialBold", color=(0.1, 0.3, 0.7))
    p1.insert_text(fitz.Point(table_x + 8, table_y + 130), "Tổng bậc: ∑ deg(v) = 12 = 2 · 6 (Thỏa Định lý 1.1)", fontsize=7.5, fontname="ArialBold", color=(0.1, 0.5, 0.2))

    # Dense bottom text
    p1.insert_textbox(fitz.Rect(50, 560, 545, 680),
        "1.2. Biểu diễn đồ thị trên máy tính:\n"
        "Có hai cấu trúc dữ liệu chính được sử dụng phổ biến:\n"
        "a) Ma trận kề A = [a_ij] kích thước n × n, trong đó a_ij = 1 nếu (v_i, v_j) ∈ E và a_ij = 0 nếu ngược lại. "
        "Ma trận kề đồ thị vô hướng luôn là ma trận đối xứng (A = A^T). Ưu điểm: kiểm tra liên thuộc O(1), "
        "nhược điểm: tốn bộ nhớ O(n^2), không hiệu quả cho đồ thị thưa (sparse graph).\n"
        "b) Danh sách kề (Adjacency List): mỗi đỉnh v duy trì một danh sách các đỉnh kề với nó. "
        "Bộ nhớ yêu cầu là O(|V| + |E|), duyệt đỉnh kề tối ưu O(deg(v)).",
        fontsize=8.5, fontname="Arial", color=(0.15, 0.15, 0.15))
        
    p1.insert_text(fitz.Point(50, 800), "Trang 1 / 4 — Giáo trình Toán Rời Rạc (CO2003)", fontsize=8, fontname="Arial", color=(0.5, 0.5, 0.5))

    # --- PAGE 2: Thuật Toán Dijkstra ---
    p2 = doc.new_page(width=w, height=h)
    setup_page_fonts(p2)
    p2.draw_rect(fitz.Rect(50, 45, 545, 46), color=(0.1, 0.15, 0.25), fill=(0.1, 0.15, 0.25))
    p2.insert_text(fitz.Point(50, 40), "ĐẠI HỌC BÁCH KHOA — KHOA KHOA HỌC MÁY TÍNH", fontsize=8, fontname="ArialBold", color=(0.3, 0.35, 0.45))
    p2.insert_text(fitz.Point(50, 75), "2. THUẬT TOÁN TÌM ĐƯỜNG ĐI NGẮN NHẤT — DIJKSTRA", fontsize=13, fontname="ArialBold", color=(0.1, 0.15, 0.25))
    
    p2.insert_textbox(fitz.Rect(50, 85, 545, 140),
        "Thuật toán Dijkstra (Edsger W. Dijkstra, 1959) giải quyết bài toán tìm đường đi ngắn nhất từ một đỉnh nguồn s "
        "đến tất cả các đỉnh còn lại trong đồ thị có trọng số không âm w(u, v) ≥ 0. "
        "Thuật toán duy trì ước lượng khoảng cách d[v] từ s tới v và tập S các đỉnh đã xác định được khoảng cách tối ưu.",
        fontsize=8.5, fontname="Arial", color=(0.15, 0.15, 0.15))

    # Pseudocode box
    p2.draw_rect(fitz.Rect(50, 145, 545, 340), color=(0.2, 0.25, 0.35), fill=(0.97, 0.98, 0.99))
    p2.insert_text(fitz.Point(60, 162), "Mã giả thuật toán Dijkstra (Sử dụng hàng đợi ưu tiên Min-Priority Queue):", fontsize=9, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    code_lines = [
        "function Dijkstra(G = (V, E, w), s):",
        "    for each vertex v in V:",
        "        d[v] = ∞;  parent[v] = null",
        "    d[s] = 0",
        "    Q = PriorityQueue()  // Khởi tạo hàng đợi nhị phân min-heap",
        "    Q.insert(s, 0)",
        "    while not Q.isEmpty():",
        "        u = Q.extractMin()  // Đỉnh có d[u] nhỏ nhất chưa thăm",
        "        for each neighbor v of u with weight w(u, v):",
        "            if d[u] + w(u, v) < d[v]:  // Bước nới lỏng (Relaxation)",
        "                d[v] = d[u] + w(u, v)",
        "                parent[v] = u",
        "                Q.decreaseKey(v, d[v])",
        "    return d, parent",
    ]
    for idx, line in enumerate(code_lines):
        p2.insert_text(fitz.Point(65, 180 + idx * 11.5), line, fontsize=8, fontname="Consolas", color=(0.05, 0.15, 0.3))

    # Complexity table
    p2.insert_text(fitz.Point(50, 360), "Bảng phân tích độ phức tạp thời gian theo cấu trúc dữ liệu:", fontsize=9.5, fontname="ArialBold", color=(0.1, 0.2, 0.35))
    p2.draw_rect(fitz.Rect(50, 370, 545, 475), color=(0.7, 0.75, 0.8), fill=(1, 1, 1))
    p2.draw_rect(fitz.Rect(50, 370, 545, 392), color=(0.7, 0.75, 0.8), fill=(0.9, 0.93, 0.97))
    headers = [("Cấu trúc hàng đợi Q", 55), ("Tìm min (Extract-Min)", 210), ("Nới lỏng (Decrease-Key)", 340), ("Tổng thời gian T(V, E)", 445)]
    for h_text, hx in headers:
        p2.insert_text(fitz.Point(hx, 385), h_text, fontsize=8, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    comp_rows = [
        ("Mảng tuần tự (Array)", "O(V)", "O(1)", "O(V² + E) = O(V²)"),
        ("Nhị phân (Binary Heap)", "O(log V)", "O(log V)", "O((V + E) log V)"),
        ("Heap d-phân (d-ary Heap)", "O(d log_d V)", "O(log_d V)", "O((d V + E) log_d V)"),
        ("Fibonacci Heap", "O(log V) amortized", "O(1) amortized", "O(E + V log V)  [Tối ưu lý thuyết]"),
    ]
    for idx, cr in enumerate(comp_rows):
        ry = 392 + idx * 20.5
        p2.draw_line(fitz.Point(50, ry), fitz.Point(545, ry), color=(0.85, 0.88, 0.9))
        p2.insert_text(fitz.Point(55, ry + 14), cr[0], fontsize=8, fontname="Arial", color=(0.1, 0.1, 0.1))
        p2.insert_text(fitz.Point(210, ry + 14), cr[1], fontsize=8, fontname="Consolas", color=(0.2, 0.2, 0.2))
        p2.insert_text(fitz.Point(340, ry + 14), cr[2], fontsize=8, fontname="Consolas", color=(0.2, 0.2, 0.2))
        p2.insert_text(fitz.Point(445, ry + 14), cr[3], fontsize=8, fontname="ArialBold", color=(0.1, 0.35, 0.7))

    # Notes on negative weights
    p2.insert_textbox(fitz.Rect(50, 490, 545, 600),
        "Cảnh báo quan trọng về trọng số âm:\n"
        "Thuật toán Dijkstra KHÔNG hoạt động chính xác khi đồ thị tồn tại cạnh có trọng số âm (w(u, v) < 0). "
        "Nguyên nhân: nguyên lý tham lam (Greedy Choice Property) giả định rằng khi một đỉnh u được lấy ra khỏi Q "
        "với khoảng cách d[u] nhỏ nhất, không thể có đường đi nào khác qua các đỉnh chưa thăm có thể làm giảm d[u]. "
        "Giả định này sai lầm nếu có trọng số âm. Để giải bài toán với trọng số âm và phát hiện chu trình âm, "
        "bắt buộc phải sử dụng thuật toán Bellman-Ford với độ phức tạp O(V · E).",
        fontsize=8.5, fontname="Arial", color=(0.2, 0.15, 0.15))

    p2.insert_text(fitz.Point(50, 800), "Trang 2 / 4 — Giáo trình Toán Rời Rạc (CO2003)", fontsize=8, fontname="Arial", color=(0.5, 0.5, 0.5))

    # --- PAGE 3: Cây Khung Nhỏ Nhất (MST) ---
    p3 = doc.new_page(width=w, height=h)
    setup_page_fonts(p3)
    p3.draw_rect(fitz.Rect(50, 45, 545, 46), color=(0.1, 0.15, 0.25), fill=(0.1, 0.15, 0.25))
    p3.insert_text(fitz.Point(50, 40), "ĐẠI HỌC BÁCH KHOA — KHOA KHOA HỌC MÁY TÍNH", fontsize=8, fontname="ArialBold", color=(0.3, 0.35, 0.45))
    p3.insert_text(fitz.Point(50, 75), "3. CÂY KHUNG NHỎ NHẤT (MINIMUM SPANNING TREE - MST)", fontsize=13, fontname="ArialBold", color=(0.1, 0.15, 0.25))
    
    p3.insert_textbox(fitz.Rect(50, 85, 545, 140),
        "Cho đồ thị vô hướng liên thông có trọng số G = (V, E, w). Một cây khung T = (V, E_T) là một đồ thị con liên thông "
        "không có chu trình chứa tất cả các đỉnh của G (|E_T| = |V| - 1). Cây khung nhỏ nhất (MST) là cây khung có tổng trọng số "
        "w(T) = ∑_{e ∈ E_T} w(e) đạt giá trị nhỏ nhất.",
        fontsize=8.5, fontname="Arial", color=(0.15, 0.15, 0.15))

    # Diagram of Weighted Graph & MST
    p3.insert_text(fitz.Point(50, 150), "Sơ đồ mạng tô-pô có trọng số & Cây khung tối ưu:", fontsize=9.5, fontname="ArialBold", color=(0.1, 0.2, 0.35))
    mst_nodes = [(100, 220, "A"), (200, 170, "B"), (300, 200, "C"), (400, 170, "D"), (200, 270, "E"), (320, 280, "F")]
    all_edges = [
        (0, 1, 4, True), (0, 4, 2, True), (1, 2, 5, False), (1, 4, 1, True), 
        (2, 3, 3, True), (2, 5, 6, False), (3, 5, 2, True), (4, 5, 8, False)
    ]
    for n1, n2, weight, is_mst in all_edges:
        color = (0.0, 0.5, 0.8) if is_mst else (0.75, 0.8, 0.85)
        lwidth = 2.5 if is_mst else 1.0
        p3.draw_line(fitz.Point(mst_nodes[n1][0], mst_nodes[n1][1]), fitz.Point(mst_nodes[n2][0], mst_nodes[n2][1]), color=color, width=lwidth)
        mx = (mst_nodes[n1][0] + mst_nodes[n2][0]) / 2 + 3
        my = (mst_nodes[n1][1] + mst_nodes[n2][1]) / 2 - 3
        p3.insert_text(fitz.Point(mx, my), str(weight), fontsize=8.5, fontname="ArialBold", color=(0.8, 0.2, 0.1) if is_mst else (0.5, 0.5, 0.5))
        
    for x, y, name in mst_nodes:
        p3.draw_circle(fitz.Point(x, y), 13, color=(0.1, 0.2, 0.4), fill=(0.96, 0.98, 1.0), width=1.5)
        p3.insert_text(fitz.Point(x - 4, y + 4), name, fontsize=8.5, fontname="ArialBold", color=(0.1, 0.2, 0.4))
        
    p3.insert_text(fitz.Point(100, 315), "Chú thích: Các cạnh đậm màu xanh dương thuộc về cây khung nhỏ nhất T (Tổng trọng số: w(T) = 2 + 1 + 4 + 3 + 2 = 12)", fontsize=8, fontname="ArialBold", color=(0.0, 0.4, 0.7))

    # Kruskal Algorithm Table Step Trace
    p3.insert_text(fitz.Point(50, 345), "Bảng diễn tiến từng bước theo thuật toán Kruskal (Sắp xếp cạnh tăng dần):", fontsize=9, fontname="ArialBold", color=(0.1, 0.2, 0.35))
    p3.draw_rect(fitz.Rect(50, 355, 545, 500), color=(0.7, 0.75, 0.8), fill=(1, 1, 1))
    p3.draw_rect(fitz.Rect(50, 355, 545, 375), color=(0.7, 0.75, 0.8), fill=(0.9, 0.93, 0.97))
    headers_k = [("Bước", 55), ("Cạnh (u, v)", 95), ("Trọng số w", 170), ("Kiểm tra tạo chu trình (Disjoint-Set)", 250), ("Quyết định", 455)]
    for ht, hx in headers_k:
        p3.insert_text(fitz.Point(hx, 369), ht, fontsize=8, fontname="ArialBold", color=(0.1, 0.2, 0.4))
    k_steps = [
        ("1", "(B, E)", "1", "Find(B) ≠ Find(E) -> Hợp nhất {B, E}", "CHẤP NHẬN"),
        ("2", "(A, E)", "2", "Find(A) ≠ Find(E) -> Hợp nhất {A, B, E}", "CHẤP NHẬN"),
        ("3", "(D, F)", "2", "Find(D) ≠ Find(F) -> Hợp nhất {D, F}", "CHẤP NHẬN"),
        ("4", "(C, D)", "3", "Find(C) ≠ Find(D) -> Hợp nhất {C, D, F}", "CHẤP NHẬN"),
        ("5", "(A, B)", "4", "Find(A) = Find(B) = tập {A, B, E} -> Tạo chu trình A-B-E", "LOẠI BỎ"),
        ("6", "(B, C)", "5", "Find(B) ≠ Find(C) -> Hợp nhất 2 thành phần liên thông", "CHẤP NHẬN (Đủ 5 cạnh)"),
    ]
    for idx, ks in enumerate(k_steps):
        ry = 375 + idx * 20.5
        p3.draw_line(fitz.Point(50, ry), fitz.Point(545, ry), color=(0.85, 0.88, 0.9))
        p3.insert_text(fitz.Point(60, ry + 14), ks[0], fontsize=8, fontname="Arial", color=(0.1, 0.1, 0.1))
        p3.insert_text(fitz.Point(100, ry + 14), ks[1], fontsize=8, fontname="ArialBold", color=(0.1, 0.2, 0.3))
        p3.insert_text(fitz.Point(180, ry + 14), ks[2], fontsize=8, fontname="Consolas", color=(0.2, 0.2, 0.2))
        p3.insert_text(fitz.Point(250, ry + 14), ks[3], fontsize=8, fontname="Arial", color=(0.2, 0.2, 0.2))
        res_color = (0.1, 0.5, 0.2) if "CHẤP NHẬN" in ks[4] else (0.8, 0.2, 0.1)
        p3.insert_text(fitz.Point(455, ry + 14), ks[4], fontsize=8, fontname="ArialBold", color=res_color)

    p3.insert_text(fitz.Point(50, 800), "Trang 3 / 4 — Giáo trình Toán Rời Rạc (CO2003)", fontsize=8, fontname="Arial", color=(0.5, 0.5, 0.5))

    # --- PAGE 4: Ứng Dụng Trong Mạng Máy Tính & Bài Tập ---
    p4 = doc.new_page(width=w, height=h)
    setup_page_fonts(p4)
    p4.draw_rect(fitz.Rect(50, 45, 545, 46), color=(0.1, 0.15, 0.25), fill=(0.1, 0.15, 0.25))
    p4.insert_text(fitz.Point(50, 40), "ĐẠI HỌC BÁCH KHOA — KHOA KHOA HỌC MÁY TÍNH", fontsize=8, fontname="ArialBold", color=(0.3, 0.35, 0.45))
    p4.insert_text(fitz.Point(50, 75), "4. ỨNG DỤNG THỰC TIỄN & BÀI TẬP TỰ LUYỆN", fontsize=13, fontname="ArialBold", color=(0.1, 0.15, 0.25))
    
    p4.insert_textbox(fitz.Rect(50, 90, 545, 230),
        "4.1. Định tuyến gói tin trong mạng Internet (OSPF & IS-IS):\n"
        "Giao thức Open Shortest Path First (OSPF) là một giao thức định tuyến trạng thái liên kết (Link-State Routing Protocol) "
        "được triển khai rộng rãi trong các hệ thống mạng doanh nghiệp và ISP. Mỗi router trong vùng OSPF xây dựng "
        "một cơ sở dữ liệu trạng thái liên kết (LSDB) đồng nhất, mô tả toàn bộ tô-pô mạng dưới dạng một đồ thị có trọng số. "
        "Mỗi router sau đó độc lập thực thi thuật toán Dijkstra để tính toán cây đường đi ngắn nhất (Shortest Path Tree) "
        "từ chính nó tới tất cả các mạng con đích, từ đó nạp bảng chuyển tiếp gói tin (FIB).\n\n"
        "4.2. Giao thức chống bão broadcast (Spanning Tree Protocol - STP / RSTP):\n"
        "Trong mạng cục bộ Ethernet (Layer 2), việc tạo vòng lặp dự phòng cáp dẫn đến thảm họa broadcast storm và MAC flapping. "
        "STP (IEEE 802.1D) và RSTP (IEEE 802.1w) sử dụng biến thể phân tán của thuật toán tìm cây khung để tự động "
        "khóa các cổng dự phòng, đảm bảo mạng chỉ có một topo hình cây logic duy nhất tại mọi thời điểm.",
        fontsize=8.5, fontname="Arial", color=(0.15, 0.15, 0.15))

    # Exercises Box
    p4.draw_rect(fitz.Rect(50, 240, 545, 470), color=(0.7, 0.75, 0.8), fill=(0.98, 0.99, 1.0))
    p4.insert_text(fitz.Point(62, 258), "BÀI TẬP VỀ NHÀ (Nộp trước 23:59 Chủ Nhật tuần thứ 8):", fontsize=9.5, fontname="ArialBold", color=(0.1, 0.25, 0.5))
    exercises = [
        "Bài 1 (2.0 điểm): Chứng minh rằng trong đồ thị vô hướng liên thông G = (V, E) có trọng số các cạnh đôi một khác nhau, cây khung nhỏ nhất (MST) là duy nhất.",
        "Bài 2 (3.0 điểm): Cho đồ thị có hướng G có n đỉnh. Thiết kế thuật toán kiểm tra sự tồn tại của chu trình có trọng số trung bình nhỏ nhất với độ phức tạp O(n · m).",
        "Bài 3 (2.5 điểm): Giả sử chi phí của mỗi liên kết mạng biến thiên theo hàm thời gian c(e, t) = α_e + β_e · t với t ≥ 0. "
        "Nếu khởi hành từ s tại thời điểm t = 0, hãy chứng minh điều kiện cần và đủ để thuật toán Dijkstra mở rộng vẫn đảm bảo tính tối ưu toàn cục.",
        "Bài 4 (2.5 điểm): Cài đặt cấu trúc dữ liệu Disjoint-Set với tối ưu nén đường đi (Path Compression) và hợp nhất theo hạng (Union by Rank) bằng Python hoặc C++, đo đếm số phép toán thực tế.",
    ]
    for idx, ex in enumerate(exercises):
        p4.insert_textbox(fitz.Rect(62, 270 + idx * 48, 535, 315 + idx * 48), ex, fontsize=8.2, fontname="Arial", color=(0.15, 0.15, 0.2))

    p4.insert_text(fitz.Point(50, 800), "Trang 4 / 4 — Giáo trình Toán Rời Rạc (CO2003)", fontsize=8, fontname="Arial", color=(0.5, 0.5, 0.5))

    doc.save(pdf_path)
    doc.close()
    print(f"Generated {pdf_path}")

# -------------------------------------------------------------------------
# 2. GENERATE 6-SLIDE 16:9 PPTX (Kiến Trúc Mạng & An Toàn Thông Tin)
# -------------------------------------------------------------------------
def generate_16_9_pptx():
    pptx_path = os.path.join(OUTPUT_DIR, "lecture_slides_network_security.pptx")
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    
    blank_layout = prs.slide_layouts[6]
    c_oxford = RGBColor(26, 37, 54)
    c_gold = RGBColor(217, 119, 6)
    c_cream = RGBColor(251, 249, 245)
    c_slate = RGBColor(100, 116, 139)
    c_blue = RGBColor(37, 99, 235)
    c_white = RGBColor(255, 255, 255)
    c_card_bg = RGBColor(241, 245, 249)

    slides_content = [
        {
            "num": 1,
            "title": "BÀI GIẢNG CHUYÊN ĐỀ: KIẾN TRÚC MẠNG & AN TOÀN THÔNG TIN",
            "subtitle": "Phân Tích Giao Thức Mạng, Mã Hóa Đầu Cuối & Tô-pô Doanh Nghiệp\nKhoa Công Nghệ Thông Tin — ĐHQG-HCM · 2026",
            "type": "title"
        },
        {
            "num": 2,
            "title": "MÔ HÌNH PHÂN LỚP OSI & BỘ GIAO THỨC TCP/IP HIỆN ĐẠI",
            "subtitle": "So sánh kiến trúc 7 tầng lý thuyết và 4 tầng thực thi trên Internet",
            "type": "table_osi"
        },
        {
            "num": 3,
            "title": "SƠ ĐỒ TÔ-PÔ MẠNG TRUNG TÂM DỮ LIỆU & BẢO VỆ ĐA TẦNG (DMZ)",
            "subtitle": "Kiến trúc Defense-in-Depth với tường lửa kép và phân vùng mạng logic",
            "type": "diagram_topology"
        },
        {
            "num": 4,
            "title": "NGUYÊN LÝ MÃ HÓA BẤT ĐỐI XỨNG: RSA & ĐƯỜNG CONG ELIPTIC (ECC)",
            "subtitle": "Cơ sở toán học của thuật toán trao đổi khóa và chữ ký điện tử",
            "type": "math_crypto"
        },
        {
            "num": 5,
            "title": "LẬP TRÌNH SOCKET BẢO MẬT VỚI TLS 1.3 TRONG PYTHON",
            "subtitle": "Triển khai kết nối Client-Server mã hóa toàn phần sử dụng thư viện ssl",
            "type": "code_python"
        },
        {
            "num": 6,
            "title": "ĐÁNH GIÁ HIỆU NĂNG GIAO THỨC & ĐỘ TRỄ KẾT NỐI (BENCHMARK)",
            "subtitle": "Phân tích RTT handshake giữa TCP, TLS 1.2, TLS 1.3 và QUIC (HTTP/3)",
            "type": "benchmark"
        }
    ]

    for item in slides_content:
        slide = prs.slides.add_slide(blank_layout)
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = c_cream
        bg.line.color.rgb = c_cream

        hb = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(1.2))
        hb.fill.solid()
        hb.fill.fore_color.rgb = c_oxford
        hb.line.color.rgb = c_oxford

        tf = hb.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = item["title"]
        p.font.size = Pt(22)
        p.font.bold = True
        p.font.color.rgb = c_white
        
        p2 = tf.add_paragraph()
        p2.text = item["subtitle"]
        p2.font.size = Pt(11)
        p2.font.color.rgb = c_gold

        fb = slide.shapes.add_textbox(Inches(0.8), Inches(6.9), Inches(11.733), Inches(0.5))
        fp = fb.text_frame.paragraphs[0]
        fp.text = f"PHUCNOTE ACADEMIC ATELIER · KHÓA HỌC AN TOÀN MẠNG 2026 · SLIDE {item['num']}/6"
        fp.font.size = Pt(9)
        fp.font.color.rgb = c_slate

        stype = item["type"]
        if stype == "title":
            box = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(2), Inches(2.2), Inches(9.333), Inches(3.8))
            box.fill.solid()
            box.fill.fore_color.rgb = c_white
            box.line.color.rgb = c_gold
            btf = box.text_frame
            btf.word_wrap = True
            bp1 = btf.paragraphs[0]
            bp1.text = "Mục Tiêu Học Phần & Chuẩn Đầu Ra:"
            bp1.font.bold = True
            bp1.font.size = Pt(16)
            bp1.font.color.rgb = c_oxford
            bullet_points = [
                "1. Nắm vững mô hình tham chiếu OSI 7 tầng và sự tiến hóa của giao thức TCP/IP.",
                "2. Thiết kế topo mạng an toàn phân tách DMZ, Internal LAN và Core Services.",
                "3. Làm chủ lý thuyết mật mã học bất đối xứng: Hàm một chiều RSA và nhóm đường cong Elliptic.",
                "4. Lập trình ứng dụng phân tán với kết nối TLS 1.3 và tối ưu handshake 0-RTT của giao thức QUIC."
            ]
            for bp in bullet_points:
                bpp = btf.add_paragraph()
                bpp.text = bp
                bpp.font.size = Pt(13)
                bpp.font.color.rgb = RGBColor(50, 50, 50)
                
        elif stype == "table_osi":
            table_shape = slide.shapes.add_table(5, 4, Inches(1.0), Inches(1.8), Inches(11.333), Inches(4.5))
            table = table_shape.table
            headers = ["Tầng OSI", "Tầng TCP/IP", "Giao thức tiêu biểu", "Đơn vị dữ liệu (PDU) & Chức năng"]
            for col_idx, htext in enumerate(headers):
                cell = table.cell(0, col_idx)
                cell.text = htext
                cell.fill.solid()
                cell.fill.fore_color.rgb = c_oxford
                for tp in cell.text_frame.paragraphs:
                    tp.font.size = Pt(12)
                    tp.font.bold = True
                    tp.font.color.rgb = c_white
            osi_data = [
                ["7-Application, 6, 5", "Application Layer", "HTTP/3, DNS, SSH, TLS 1.3", "Data / Message — Giao diện ứng dụng người dùng"],
                ["4-Transport", "Transport Layer", "TCP (Reliable), UDP (Fast), QUIC", "Segment / Datagram — Điều khiển luồng, cổng port"],
                ["3-Network", "Internet Layer", "IPv4, IPv6, ICMP, BGP, OSPF", "Packet — Định tuyến gói tin xuyên mạng toàn cầu"],
                ["2-Data Link, 1-Phys", "Network Access", "Ethernet 802.3, Wi-Fi 802.11ax, Fiber", "Frame / Bits — Truyền dẫn vật lý giữa hai node kề"]
            ]
            for r_idx, rdata in enumerate(osi_data):
                for c_idx, val in enumerate(rdata):
                    cell = table.cell(r_idx + 1, c_idx)
                    cell.text = val
                    cell.fill.solid()
                    cell.fill.fore_color.rgb = c_white if r_idx % 2 == 0 else c_card_bg
                    for tp in cell.text_frame.paragraphs:
                        tp.font.size = Pt(11)
                        tp.font.color.rgb = RGBColor(30, 30, 30)

        elif stype == "diagram_topology":
            nodes_def = [
                ("INTERNET / NGOÀI", Inches(1.2), Inches(2.2), Inches(2.2), Inches(1.0), c_slate),
                ("FIREWALL BIÊN (PF)", Inches(4.0), Inches(2.2), Inches(2.4), Inches(1.0), c_gold),
                ("DMZ WEB / API CLUSTER", Inches(7.2), Inches(1.8), Inches(2.6), Inches(1.0), c_blue),
                ("FIREWALL NỘI BỘ", Inches(7.2), Inches(3.2), Inches(2.6), Inches(1.0), c_gold),
                ("INTERNAL DB / CORE", Inches(10.3), Inches(3.2), Inches(2.2), Inches(1.0), c_oxford),
            ]
            for label, left, top, width, height, col in nodes_def:
                box = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
                box.fill.solid()
                box.fill.fore_color.rgb = col
                box.line.color.rgb = c_white
                tf = box.text_frame
                tf.word_wrap = True
                p = tf.paragraphs[0]
                p.text = label
                p.alignment = PP_ALIGN.CENTER
                p.font.size = Pt(11)
                p.font.bold = True
                p.font.color.rgb = c_white
                
            info_box = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(1.2), Inches(4.6), Inches(10.933), Inches(1.8))
            info_box.fill.solid()
            info_box.fill.fore_color.rgb = c_white
            info_box.line.color.rgb = c_slate
            itf = info_box.text_frame
            itf.word_wrap = True
            ip = itf.paragraphs[0]
            ip.text = "Quy Tắc Định Tuyến & Cô Lập Vùng Mạng (Zero-Trust Model):"
            ip.font.bold = True
            ip.font.size = Pt(12)
            ip.font.color.rgb = c_oxford
            bullets = [
                "• Vùng DMZ chỉ chấp nhận kết nối HTTPS (TCP 443) từ Internet; tuyệt đối cấm DMZ chủ động kết nối vào Database.",
                "• Firewall nội bộ chỉ cho phép các máy chủ ứng dụng đã xác thực chứng chỉ mTLS truy cập cổng PostgreSQL (TCP 5432).",
                "• Mọi luồng quản trị phải đi qua VPN Gateway có MFA và lưu vết trên hệ thống SIEM tập trung."
            ]
            for b in bullets:
                bp = itf.add_paragraph()
                bp.text = b
                bp.font.size = Pt(10.5)
                bp.font.color.rgb = RGBColor(60, 60, 60)

        elif stype == "math_crypto":
            box_rsa = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.0), Inches(1.8), Inches(5.4), Inches(4.6))
            box_rsa.fill.solid()
            box_rsa.fill.fore_color.rgb = c_white
            box_rsa.line.color.rgb = c_oxford
            rtf = box_rsa.text_frame
            rtf.word_wrap = True
            rp = rtf.paragraphs[0]
            rp.text = "1. Hệ Mật Mã RSA (Rivest–Shamir–Adleman)"
            rp.font.bold = True
            rp.font.size = Pt(13)
            rp.font.color.rgb = c_oxford
            rsa_texts = [
                "• Chọn hai số nguyên tố lớn ngẫu nhiên: p, q",
                "• Tính n = p · q và phi(n) = (p - 1)(q - 1)",
                "• Chọn số mũ công khai e sao cho gcd(e, phi(n)) = 1",
                "• Tính số mũ bí mật d = e^(-1) mod phi(n)",
                "• Khóa công khai: (e, n) | Khóa bí mật: (d, n)",
                "• Mã hóa: c ≡ m^e (mod n)",
                "• Giải mã: m ≡ c^d (mod n)",
                "• Độ phức tạp dựa trên bài toán phân tích thừa số nguyên tố lớn."
            ]
            for rt in rsa_texts:
                p = rtf.add_paragraph()
                p.text = rt
                p.font.size = Pt(10.5)
                p.font.color.rgb = RGBColor(40, 40, 40)

            box_ecc = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.9), Inches(1.8), Inches(5.4), Inches(4.6))
            box_ecc.fill.solid()
            box_ecc.fill.fore_color.rgb = c_white
            box_ecc.line.color.rgb = c_blue
            etf = box_ecc.text_frame
            etf.word_wrap = True
            ep = etf.paragraphs[0]
            ep.text = "2. Đường Cong Elliptic (ECC / ECDSA / Ed25519)"
            ep.font.bold = True
            ep.font.size = Pt(13)
            ep.font.color.rgb = c_blue
            ecc_texts = [
                "• Phương trình Weierstrass: y^2 = x^3 + a·x + b (mod p)",
                "• Phép cộng điểm trên đường cong P + Q = R",
                "• Phép nhân vô hướng: Q = k · P (k là khóa bí mật, Q là khóa công khai)",
                "• Độ an toàn dựa trên bài toán logarit rời rạc ECDLP",
                "• Ưu thế: Khóa ECC 256-bit có độ an toàn tương đương RSA 3072-bit!",
                "• Băng thông nhỏ hơn, tính toán nhanh hơn gấp nhiều lần trên chip di động."
            ]
            for et in ecc_texts:
                p = etf.add_paragraph()
                p.text = et
                p.font.size = Pt(10.5)
                p.font.color.rgb = RGBColor(40, 40, 40)

        elif stype == "code_python":
            code_box = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(1.0), Inches(1.8), Inches(11.333), Inches(4.6))
            code_box.fill.solid()
            code_box.fill.fore_color.rgb = RGBColor(20, 24, 33)
            code_box.line.color.rgb = c_gold
            ctf = code_box.text_frame
            ctf.word_wrap = True
            cp = ctf.paragraphs[0]
            cp.text = "# Python TLS 1.3 Client Script — Handshake & Encrypted Payload"
            cp.font.name = "Courier New"
            cp.font.size = Pt(10.5)
            cp.font.color.rgb = RGBColor(140, 200, 100)
            py_code = [
                "import socket, ssl",
                "",
                "# Khởi tạo TLS Context theo chuẩn bảo mật TLS 1.3 hiện đại",
                "context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)",
                "context.minimum_version = ssl.TLSVersion.TLSv1_3",
                "context.check_hostname = True",
                "",
                "hostname = 'api.phucnote.internal'",
                "with socket.create_connection((hostname, 443), timeout=5.0) as sock:",
                "    with context.wrap_socket(sock, server_hostname=hostname) as tls_sock:",
                "        print(f'[+] Kết nối an toàn thành công! Phiên bản: {tls_sock.version()}')",
                "        print(f'[+] Bộ thuật toán mã hóa (Cipher): {tls_sock.cipher()}')",
                "        request = f'GET /v1/notes HTTP/1.1\\r\\nHost: {hostname}\\r\\nConnection: close\\r\\n\\r\\n'",
                "        tls_sock.sendall(request.encode('utf-8'))",
                "        response = tls_sock.recv(4096)",
                "        print(f'[+] Nhận {len(response)} bytes phản hồi đã giải mã.')"
            ]
            for cl in py_code:
                p = ctf.add_paragraph()
                p.text = cl
                p.font.name = "Courier New"
                p.font.size = Pt(9.5)
                p.font.color.rgb = RGBColor(230, 235, 245)

        elif stype == "benchmark":
            table_shape = slide.shapes.add_table(5, 5, Inches(1.0), Inches(1.8), Inches(11.333), Inches(4.5))
            table = table_shape.table
            headers = ["Giao thức", "Bắt tay kết nối (Handshake)", "Độ trễ RTT", "Mã hóa Payload", "Ưu điểm vượt trội"]
            for col_idx, htext in enumerate(headers):
                cell = table.cell(0, col_idx)
                cell.text = htext
                cell.fill.solid()
                cell.fill.fore_color.rgb = c_oxford
                for tp in cell.text_frame.paragraphs:
                    tp.font.size = Pt(11)
                    tp.font.bold = True
                    tp.font.color.rgb = c_white
            bench_data = [
                ["TCP thuần", "3-way handshake (SYN, SYN-ACK, ACK)", "1.0 RTT", "Không (Plaintext)", "Cổ điển, không an toàn"],
                ["TCP + TLS 1.2", "TCP Handshake (1 RTT) + TLS (2 RTT)", "3.0 RTT", "Có (AES-GCM / CBC)", "Chuẩn cũ, bắt tay chậm"],
                ["TCP + TLS 1.3", "TCP Handshake (1 RTT) + TLS (1 RTT)", "2.0 RTT", "Có (ChaCha20, AES-GCM)", "Bảo mật cao, giảm 1 RTT"],
                ["QUIC (HTTP/3)", "Combined Transport + Crypto qua UDP", "1.0 RTT (0-RTT Resume)", "Bắt buộc 100% mã hóa", "Không bị Head-of-Line blocking!"]
            ]
            for r_idx, rdata in enumerate(bench_data):
                for c_idx, val in enumerate(rdata):
                    cell = table.cell(r_idx + 1, c_idx)
                    cell.text = val
                    cell.fill.solid()
                    cell.fill.fore_color.rgb = c_white if r_idx % 2 == 0 else c_card_bg
                    for tp in cell.text_frame.paragraphs:
                        tp.font.size = Pt(10.5)
                        tp.font.color.rgb = RGBColor(30, 30, 30)

    prs.save(pptx_path)
    print(f"Generated {pptx_path}")

# -------------------------------------------------------------------------
# 3. GENERATE 6-SLIDE 16:9 PDF RENDITION
# -------------------------------------------------------------------------
def generate_slides_pdf_rendition():
    pdf_path = os.path.join(OUTPUT_DIR, "lecture_slides_network_security.pdf")
    doc = fitz.open()
    
    w, h = 960, 540
    
    slides_info = [
        ("BÀI GIẢNG CHUYÊN ĐỀ: KIẾN TRÚC MẠNG & AN TOÀN THÔNG TIN",
         "Phân Tích Giao Thức Mạng, Mã Hóa Đầu Cuối & Tô-pô Doanh Nghiệp\nKhoa Công Nghệ Thông Tin — ĐHQG-HCM · 2026",
         "title"),
        ("MÔ HÌNH PHÂN LỚP OSI & BỘ GIAO THỨC TCP/IP HIỆN ĐẠI",
         "So sánh kiến trúc 7 tầng lý thuyết và 4 tầng thực thi trên Internet",
         "table_osi"),
        ("SƠ ĐỒ TÔ-PÔ MẠNG TRUNG TÂM DỮ LIỆU & BẢO VỆ ĐA TẦNG (DMZ)",
         "Kiến trúc Defense-in-Depth với tường lửa kép và phân vùng mạng logic",
         "topology"),
        ("NGUYÊN LÝ MÃ HÓA BẤT ĐỐI XỨNG: RSA & ĐƯỜNG CONG ELIPTIC (ECC)",
         "Cơ sở toán học của thuật toán trao đổi khóa và chữ ký điện tử",
         "crypto"),
        ("LẬP TRÌNH SOCKET BẢO MẬT VỚI TLS 1.3 TRONG PYTHON",
         "Triển khai kết nối Client-Server mã hóa toàn phần sử dụng thư viện ssl",
         "code"),
        ("ĐÁNH GIÁ HIỆU NĂNG GIAO THỨC & ĐỘ TRỄ KẾT NỐI (BENCHMARK)",
         "Phân tích RTT handshake giữa TCP, TLS 1.2, TLS 1.3 và QUIC (HTTP/3)",
         "bench")
    ]

    for idx, (title, sub, stype) in enumerate(slides_info):
        p = doc.new_page(width=w, height=h)
        setup_page_fonts(p)
        p.draw_rect(fitz.Rect(0, 0, w, h), color=(0.98, 0.97, 0.95), fill=(0.98, 0.97, 0.95))
        p.draw_rect(fitz.Rect(0, 0, w, 75), color=(0.1, 0.15, 0.22), fill=(0.1, 0.15, 0.22))
        p.insert_text(fitz.Point(40, 32), title, fontsize=14, fontname="ArialBold", color=(1, 1, 1))
        p.insert_text(fitz.Point(40, 52), sub.split('\n')[0], fontsize=8.5, fontname="Arial", color=(0.85, 0.6, 0.2))

        p.insert_text(fitz.Point(40, 515), f"PHUCNOTE ACADEMIC ATELIER · KHÓA HỌC AN TOÀN MẠNG 2026 · SLIDE {idx+1}/6", fontsize=7.5, fontname="Arial", color=(0.4, 0.45, 0.5))

        if stype == "title":
            p.draw_rect(fitz.Rect(120, 120, 840, 440), color=(0.85, 0.6, 0.2), fill=(1, 1, 1), width=1.5)
            p.insert_text(fitz.Point(150, 160), "MỤC TIÊU HỌC PHẦN & CHUẨN ĐẦU RA:", fontsize=13, fontname="ArialBold", color=(0.1, 0.15, 0.25))
            bullets = [
                "1. Nắm vững mô hình tham chiếu OSI 7 tầng và sự tiến hóa của giao thức TCP/IP.",
                "2. Thiết kế topo mạng an toàn phân tách DMZ, Internal LAN và Core Services.",
                "3. Làm chủ lý thuyết mật mã học bất đối xứng: Hàm một chiều RSA và nhóm đường cong Elliptic.",
                "4. Lập trình ứng dụng phân tán với kết nối TLS 1.3 và tối ưu handshake 0-RTT của giao thức QUIC."
            ]
            for b_idx, b in enumerate(bullets):
                p.insert_text(fitz.Point(150, 210 + b_idx * 45), b, fontsize=10.5, fontname="Arial", color=(0.2, 0.2, 0.25))

        elif stype == "table_osi":
            p.draw_rect(fitz.Rect(50, 110, 910, 470), color=(0.7, 0.75, 0.8), fill=(1, 1, 1))
            p.draw_rect(fitz.Rect(50, 110, 910, 140), color=(0.1, 0.15, 0.25), fill=(0.1, 0.15, 0.25))
            p.insert_text(fitz.Point(60, 130), "Tầng OSI", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(220, 130), "Tầng TCP/IP", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(380, 130), "Giao thức tiêu biểu", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(580, 130), "Đơn vị dữ liệu (PDU) & Chức năng", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            rows_data = [
                ("7-Application, 6, 5", "Application Layer", "HTTP/3, DNS, SSH, TLS 1.3", "Data / Message — Giao diện ứng dụng người dùng"),
                ("4-Transport", "Transport Layer", "TCP (Reliable), UDP (Fast), QUIC", "Segment / Datagram — Điều khiển luồng, cổng port"),
                ("3-Network", "Internet Layer", "IPv4, IPv6, ICMP, BGP, OSPF", "Packet — Định tuyến gói tin xuyên mạng toàn cầu"),
                ("2-Data Link, 1-Phys", "Network Access", "Ethernet 802.3, Wi-Fi 802.11ax", "Frame / Bits — Truyền dẫn vật lý giữa hai node kề")
            ]
            for r_idx, r in enumerate(rows_data):
                ry = 140 + r_idx * 75
                p.draw_line(fitz.Point(50, ry), fitz.Point(910, ry), color=(0.8, 0.85, 0.9))
                p.insert_text(fitz.Point(60, ry + 42), r[0], fontsize=9, fontname="ArialBold", color=(0.1, 0.2, 0.35))
                p.insert_text(fitz.Point(220, ry + 42), r[1], fontsize=9, fontname="Arial", color=(0.2, 0.2, 0.2))
                p.insert_text(fitz.Point(380, ry + 42), r[2], fontsize=9, fontname="Consolas", color=(0.1, 0.35, 0.7))
                p.insert_text(fitz.Point(580, ry + 42), r[3], fontsize=8.5, fontname="Arial", color=(0.3, 0.3, 0.3))

        elif stype == "topology":
            nodes_diag = [
                ("INTERNET", 80, 190, 120, 60, (0.4, 0.45, 0.5)),
                ("FIREWALL BIÊN", 260, 190, 140, 60, (0.85, 0.55, 0.1)),
                ("DMZ SERVERS", 470, 140, 140, 60, (0.1, 0.4, 0.8)),
                ("INTERNAL FW", 470, 240, 140, 60, (0.85, 0.55, 0.1)),
                ("INTERNAL DB", 680, 240, 140, 60, (0.1, 0.15, 0.25)),
            ]
            p.draw_line(fitz.Point(200, 220), fitz.Point(260, 220), color=(0.3, 0.35, 0.4), width=2)
            p.draw_line(fitz.Point(400, 220), fitz.Point(470, 170), color=(0.3, 0.35, 0.4), width=2)
            p.draw_line(fitz.Point(400, 220), fitz.Point(470, 270), color=(0.3, 0.35, 0.4), width=2)
            p.draw_line(fitz.Point(610, 270), fitz.Point(680, 270), color=(0.3, 0.35, 0.4), width=2)
            for name, x, y, nw, nh, col in nodes_diag:
                p.draw_rect(fitz.Rect(x, y, x + nw, y + nh), color=col, fill=col)
                p.insert_text(fitz.Point(x + 12, y + 36), name, fontsize=9.5, fontname="ArialBold", color=(1, 1, 1))

            p.draw_rect(fitz.Rect(60, 340, 900, 480), color=(0.8, 0.85, 0.9), fill=(1, 1, 1))
            p.insert_text(fitz.Point(80, 370), "Quy Tắc Định Tuyến & Cô Lập Vùng Mạng (Zero-Trust Architecture):", fontsize=10, fontname="ArialBold", color=(0.1, 0.15, 0.25))
            p.insert_text(fitz.Point(80, 400), "• Vùng DMZ chỉ chấp nhận kết nối HTTPS (TCP 443) từ Internet; tuyệt đối cấm DMZ chủ động kết nối vào Database.", fontsize=8.5, fontname="Arial", color=(0.2, 0.2, 0.25))
            p.insert_text(fitz.Point(80, 425), "• Firewall nội bộ chỉ cho phép các máy chủ ứng dụng đã xác thực chứng chỉ mTLS truy cập cổng PostgreSQL.", fontsize=8.5, fontname="Arial", color=(0.2, 0.2, 0.25))
            p.insert_text(fitz.Point(80, 450), "• Mọi luồng quản trị phải đi qua VPN Gateway có MFA và lưu vết trên hệ thống SIEM tập trung.", fontsize=8.5, fontname="Arial", color=(0.2, 0.2, 0.25))

        elif stype == "crypto":
            p.draw_rect(fitz.Rect(50, 110, 460, 480), color=(0.1, 0.15, 0.25), fill=(1, 1, 1), width=1.2)
            p.insert_text(fitz.Point(70, 140), "1. Hệ Mật Mã RSA (Rivest–Shamir–Adleman)", fontsize=11, fontname="ArialBold", color=(0.1, 0.15, 0.25))
            rsa_texts = [
                "• Chọn hai số nguyên tố lớn ngẫu nhiên: p, q",
                "• Tính n = p · q và phi(n) = (p - 1)(q - 1)",
                "• Chọn số mũ công khai e sao cho gcd(e, phi(n)) = 1",
                "• Tính số mũ bí mật d = e^(-1) mod phi(n)",
                "• Khóa công khai: (e, n) | Khóa bí mật: (d, n)",
                "• Mã hóa: c ≡ m^e (mod n)",
                "• Giải mã: m ≡ c^d (mod n)",
                "• Độ an toàn dựa trên độ khó bài toán phân tích thừa số."
            ]
            for ridx, rt in enumerate(rsa_texts):
                p.insert_text(fitz.Point(70, 180 + ridx * 35), rt, fontsize=9, fontname="Arial", color=(0.2, 0.2, 0.2))

            p.draw_rect(fitz.Rect(500, 110, 910, 480), color=(0.1, 0.35, 0.7), fill=(1, 1, 1), width=1.2)
            p.insert_text(fitz.Point(520, 140), "2. Đường Cong Elliptic (ECC / ECDSA / Ed25519)", fontsize=11, fontname="ArialBold", color=(0.1, 0.35, 0.7))
            ecc_texts = [
                "• Phương trình Weierstrass: y² = x³ + a·x + b (mod p)",
                "• Phép cộng điểm trên đường cong P + Q = R",
                "• Phép nhân vô hướng: Q = k · P (k bí mật, Q công khai)",
                "• Độ an toàn dựa trên bài toán logarit rời rạc ECDLP",
                "• Ưu thế: Khóa ECC 256-bit an toàn tương đương RSA 3072-bit!",
                "• Băng thông nhỏ hơn, tính toán nhanh hơn gấp 10 lần trên thiết bị di động."
            ]
            for eidx, et in enumerate(ecc_texts):
                p.insert_text(fitz.Point(520, 180 + eidx * 35), et, fontsize=9, fontname="Arial", color=(0.2, 0.2, 0.2))

        elif stype == "code":
            p.draw_rect(fitz.Rect(50, 105, 910, 480), color=(0.1, 0.15, 0.22), fill=(0.08, 0.1, 0.15))
            p.insert_text(fitz.Point(70, 130), "# Python TLS 1.3 Client Script — Handshake & Encrypted Payload", fontsize=9.5, fontname="Consolas", color=(0.55, 0.8, 0.4))
            py_code = [
                "import socket, ssl",
                "",
                "# Khởi tạo TLS Context theo chuẩn bảo mật TLS 1.3 hiện đại",
                "context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)",
                "context.minimum_version = ssl.TLSVersion.TLSv1_3",
                "context.check_hostname = True",
                "",
                "hostname = 'api.phucnote.internal'",
                "with socket.create_connection((hostname, 443), timeout=5.0) as sock:",
                "    with context.wrap_socket(sock, server_hostname=hostname) as tls_sock:",
                "        print(f'[+] Kết nối an toàn thành công! Phiên bản: {tls_sock.version()}')",
                "        print(f'[+] Bộ thuật toán mã hóa (Cipher): {tls_sock.cipher()}')",
                "        request = f'GET /v1/notes HTTP/1.1\\r\\nHost: {hostname}\\r\\nConnection: close\\r\\n\\r\\n'",
                "        tls_sock.sendall(request.encode('utf-8'))",
                "        response = tls_sock.recv(4096)",
                "        print(f'[+] Nhận {len(response)} bytes phản hồi đã giải mã.')"
            ]
            for cidx, cl in enumerate(py_code):
                p.insert_text(fitz.Point(70, 155 + cidx * 18), cl, fontsize=9, fontname="Consolas", color=(0.9, 0.93, 0.98))

        elif stype == "bench":
            p.draw_rect(fitz.Rect(50, 110, 910, 470), color=(0.7, 0.75, 0.8), fill=(1, 1, 1))
            p.draw_rect(fitz.Rect(50, 110, 910, 140), color=(0.1, 0.15, 0.25), fill=(0.1, 0.15, 0.25))
            p.insert_text(fitz.Point(60, 130), "Giao thức", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(180, 130), "Bắt tay kết nối (Handshake)", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(420, 130), "Độ trễ RTT", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(520, 130), "Mã hóa Payload", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            p.insert_text(fitz.Point(670, 130), "Ưu điểm vượt trội", fontsize=9, fontname="ArialBold", color=(1, 1, 1))
            b_rows = [
                ("TCP thuần", "3-way handshake (SYN, SYN-ACK, ACK)", "1.0 RTT", "Không (Plaintext)", "Cổ điển, không an toàn"),
                ("TCP + TLS 1.2", "TCP Handshake (1 RTT) + TLS (2 RTT)", "3.0 RTT", "Có (AES-GCM)", "Chuẩn cũ, bắt tay chậm"),
                ("TCP + TLS 1.3", "TCP Handshake (1 RTT) + TLS (1 RTT)", "2.0 RTT", "Có (ChaCha20, AES)", "Bảo mật cao, giảm 1 RTT"),
                ("QUIC (HTTP/3)", "Combined Transport + Crypto qua UDP", "1.0 RTT (0-RTT)", "Bắt buộc 100% mã hóa", "Không bị Head-of-Line blocking!")
            ]
            for ridx, br in enumerate(b_rows):
                ry = 140 + ridx * 75
                p.draw_line(fitz.Point(50, ry), fitz.Point(910, ry), color=(0.8, 0.85, 0.9))
                p.insert_text(fitz.Point(60, ry + 42), br[0], fontsize=9, fontname="ArialBold", color=(0.1, 0.2, 0.35))
                p.insert_text(fitz.Point(180, ry + 42), br[1], fontsize=8.5, fontname="Arial", color=(0.2, 0.2, 0.2))
                p.insert_text(fitz.Point(420, ry + 42), br[2], fontsize=9, fontname="ArialBold", color=(0.8, 0.4, 0.0))
                p.insert_text(fitz.Point(520, ry + 42), br[3], fontsize=8.5, fontname="Arial", color=(0.2, 0.2, 0.2))
                p.insert_text(fitz.Point(670, ry + 42), br[4], fontsize=8.5, fontname="Arial", color=(0.0, 0.4, 0.7))

    doc.save(pdf_path)
    doc.close()
    print(f"Generated {pdf_path}")

# -------------------------------------------------------------------------
# 4. GENERATE 1-PAGE SCANNED-STYLE RASTER PDF
# -------------------------------------------------------------------------
def generate_scanned_pdf():
    pdf_path = os.path.join(OUTPUT_DIR, "scanned_historical_notes.pdf")
    
    img_w, img_h = 1200, 1700
    img = Image.new("RGB", (img_w, img_h), (243, 237, 222))
    draw = ImageDraw.Draw(img)
    
    try:
        font_vintage = ImageFont.truetype("C:/Windows/Fonts/cour.ttf", 26)
        font_title = ImageFont.truetype("C:/Windows/Fonts/courbd.ttf", 36)
    except Exception:
        font_vintage = ImageFont.load_default()
        font_title = ImageFont.load_default()

    import random
    random.seed(1984)
    for _ in range(4000):
        nx = random.randint(0, img_w - 1)
        ny = random.randint(0, img_h - 1)
        nval = random.randint(210, 240)
        img.putpixel((nx, ny), (nval, nval - 12, nval - 25))

    draw.rectangle([800, 120, 1120, 240], outline=(180, 50, 40), width=4)
    draw.text((820, 140), "LƯU TRỮ HỌC THUẬT", fill=(180, 50, 40), font=font_vintage)
    draw.text((840, 180), "NGÀY: 15/10/1984", fill=(180, 50, 40), font=font_vintage)

    draw.text((120, 120), "BẢN SAO TÀI LIỆU KHOA HỌC", fill=(40, 35, 30), font=font_title)
    draw.text((120, 180), "TRÍCH ĐOẠN: PHƯƠNG PHÁP TÍNH & GIẢI TÍCH CỔ ĐIỂN", fill=(70, 60, 50), font=font_vintage)
    draw.line([(120, 230), (1080, 230)], fill=(80, 70, 60), width=2)

    body_text = [
        "1. NGUYÊN LÝ CO BANACH TRONG KHÔNG GIAN ĐẦY ĐỦ",
        "Cho (X, d) la khong gian metric day du va T: X -> X la mot anh xa co,",
        "tuc la ton tai hang so k thuoc [0, 1) sao cho:",
        "       d(T(x), T(y)) <= k * d(x, y)  voi moi x, y thuoc X.",
        "Khi do, anh xa T co duy nhat mot diem bat dong x* thuoc X sao cho T(x*) = x*.",
        "",
        "Day lap x_{n+1} = T(x_n) voi x_0 bat ky hoi tu ve x* voi toc do hinh hoc:",
        "       d(x_n, x*) <= (k^n / (1 - k)) * d(x_1, x_0).",
        "",
        "2. UNG DUNG GIAI HE PHUONG TRINH DAI SO TUYEN TINH",
        "Xet he phuong trinh Ax = b. Bien doi ve dang x = Bx + c.",
        "Dieu kien du de phep lap don Jacobi hoi tu la ma tran A co tinh",
        "chat troi duong cheo nghiem ngat (Strictly Diagonally Dominant):",
        "       |a_{ii}| > \\sum_{j != i} |a_{ij}|  voi moi i = 1, 2, ..., n.",
        "",
        "3. GHI CHU CUA VIEN NGHIEP CUU TOAN HOC (1984):",
        "Ket qua tren duoc ap dung truc tiep trong chuong trinh tinh toan",
        "dong luc hoc chat luu tren may tinh the he thu hai EC-1022."
    ]

    y_pos = 280
    for line in body_text:
        draw.text((120, y_pos), line, fill=(50, 45, 40), font=font_vintage)
        y_pos += 45

    draw.text((750, 640), "[Kiem tra lai!", fill=(20, 40, 160), font=font_vintage)
    draw.text((750, 680), " sai so k=0.65]", fill=(20, 40, 160), font=font_vintage)
    draw.line([(120, 560), (450, 560)], fill=(200, 40, 30), width=2)

    img_skew = img.rotate(-0.4, resample=Image.Resampling.BICUBIC, expand=False, fillcolor=(243, 237, 222))
    img_scanned = img_skew.filter(ImageFilter.GaussianBlur(0.6))
    
    img_byte_arr = io.BytesIO()
    img_scanned.save(img_byte_arr, format='JPEG', quality=88)
    img_bytes = img_byte_arr.getvalue()
    
    doc = fitz.open()
    page = doc.new_page(width=595.3, height=841.9)
    page.insert_image(fitz.Rect(0, 0, 595.3, 841.9), stream=img_bytes)
    doc.save(pdf_path)
    doc.close()
    print(f"Generated {pdf_path}")

# -------------------------------------------------------------------------
# 5. RENDER ALL PAGES/SLIDES TO HIGH-RES PNG
# -------------------------------------------------------------------------
def render_all_to_png():
    files = [
        ("lecture_notes_discrete_math.pdf", "a4_lecture_p"),
        ("lecture_slides_network_security.pdf", "slide_16_9_s"),
        ("scanned_historical_notes.pdf", "scanned_doc_p")
    ]
    for filename, prefix in files:
        fpath = os.path.join(OUTPUT_DIR, filename)
        doc = fitz.open(fpath)
        for p_idx in range(len(doc)):
            page = doc[p_idx]
            pix = page.get_pixmap(dpi=180)
            out_img = os.path.join(RENDERS_DIR, f"{prefix}{p_idx + 1}.png")
            pix.save(out_img)
            print(f"Rendered {out_img} ({os.path.getsize(out_img)} bytes)")
        doc.close()

if __name__ == "__main__":
    generate_a4_lecture_pdf()
    generate_16_9_pptx()
    generate_slides_pdf_rendition()
    generate_scanned_pdf()
    render_all_to_png()
    print("ALL FIXTURES GENERATED WITH CLEAN UNICODE FONTS!")
