// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

enum LabDocumentType {
  notebook,
  pdf,
  slides,
  scanned,
}

class LabDocument {
  final String id;
  final String title;
  final LabDocumentType type;
  final int pageCount;
  final String lastModified;
  final String thumbnailAsset;
  final List<String> pageAssets;
  final String sourceFormat;
  final String fileSize;
  final List<String> tags;
  final Color badgeColor;
  final String badgeText;

  const LabDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.pageCount,
    required this.lastModified,
    required this.thumbnailAsset,
    required this.pageAssets,
    required this.sourceFormat,
    required this.fileSize,
    required this.tags,
    required this.badgeColor,
    required this.badgeText,
  });

  static const List<LabDocument> sampleDocuments = [
    LabDocument(
      id: 'doc-pdf-1',
      title: 'Toán Rời Rạc — Lý thuyết Đồ thị & Cây',
      type: LabDocumentType.pdf,
      pageCount: 4,
      lastModified: 'Hôm nay · 14:15',
      thumbnailAsset: 'fixtures/document_lab/renders/a4_lecture_p1.png',
      pageAssets: [
        'fixtures/document_lab/renders/a4_lecture_p1.png',
        'fixtures/document_lab/renders/a4_lecture_p2.png',
        'fixtures/document_lab/renders/a4_lecture_p3.png',
        'fixtures/document_lab/renders/a4_lecture_p4.png',
      ],
      sourceFormat: 'Tài liệu A4 PDF (4 trang)',
      fileSize: '41.5 KB',
      tags: ['#toan-roi-rac', '#do-thi', '#dijkstra'],
      badgeColor: Color(0xFF991B1B), // Academic Crimson
      badgeText: 'PDF A4',
    ),
    LabDocument(
      id: 'doc-slide-1',
      title: 'Kiến trúc An toàn Mạng & Mật mã học',
      type: LabDocumentType.slides,
      pageCount: 6,
      lastModified: 'Hôm qua · 10:20',
      thumbnailAsset: 'fixtures/document_lab/renders/slide_16_9_s1.png',
      pageAssets: [
        'fixtures/document_lab/renders/slide_16_9_s1.png',
        'fixtures/document_lab/renders/slide_16_9_s2.png',
        'fixtures/document_lab/renders/slide_16_9_s3.png',
        'fixtures/document_lab/renders/slide_16_9_s4.png',
        'fixtures/document_lab/renders/slide_16_9_s5.png',
        'fixtures/document_lab/renders/slide_16_9_s6.png',
      ],
      sourceFormat: 'Bài giảng PPTX / PDF (16:9 6 slide)',
      fileSize: '39.8 KB',
      tags: ['#an-toan-mang', '#mat-ma', '#16-9'],
      badgeColor: Color(0xFF065F46), // Deep Emerald
      badgeText: 'SLIDE 16:9',
    ),
    LabDocument(
      id: 'doc-scan-1',
      title: 'Tài liệu Lịch sử — Bản thảo Lưu trữ 1984',
      type: LabDocumentType.scanned,
      pageCount: 1,
      lastModified: '3 ngày trước',
      thumbnailAsset: 'fixtures/document_lab/renders/scanned_doc_p1.png',
      pageAssets: [
        'fixtures/document_lab/renders/scanned_doc_p1.png',
      ],
      sourceFormat: 'Tài liệu Quét Raster PDF (1 trang)',
      fileSize: '176 KB',
      tags: ['#tu-lieu-lich-su', '#ban-quet', '#scan-1984'],
      badgeColor: Color(0xFF92400E), // Amber Ochre
      badgeText: 'SCAN',
    ),
    LabDocument(
      id: 'doc-nb-1',
      title: 'Đại số tuyến tính — Học kỳ I',
      type: LabDocumentType.notebook,
      pageCount: 16,
      lastModified: 'Vừa xong · 09:42',
      thumbnailAsset: 'fixtures/document_lab/renders/a4_lecture_p1.png', // fallback
      pageAssets: [],
      sourceFormat: 'Sổ tay PhucNote (.bfly)',
      fileSize: '24.2 KB',
      tags: ['#toan-dai-so', '#hoc-ky-1', '#chinh-thuc'],
      badgeColor: Color(0xFF1E3A8A), // Oxford Navy
      badgeText: 'SỔ TAY .BFLY',
    ),
    LabDocument(
      id: 'doc-nb-2',
      title: 'Giải tích II — Chuỗi & Vi phân',
      type: LabDocumentType.notebook,
      pageCount: 28,
      lastModified: 'Hôm qua · 16:30',
      thumbnailAsset: 'fixtures/document_lab/renders/a4_lecture_p2.png',
      pageAssets: [],
      sourceFormat: 'Sổ tay PhucNote (.bfly)',
      fileSize: '38.6 KB',
      tags: ['#giai-tich', '#toan-cao-cap'],
      badgeColor: Color(0xFF1E3A8A),
      badgeText: 'SỔ TAY .BFLY',
    ),
    LabDocument(
      id: 'doc-nb-3',
      title: 'Cấu trúc dữ liệu & Thuật toán',
      type: LabDocumentType.notebook,
      pageCount: 42,
      lastModified: '5 ngày trước',
      thumbnailAsset: 'fixtures/document_lab/renders/a4_lecture_p3.png',
      pageAssets: [],
      sourceFormat: 'Sổ tay PhucNote (.bfly)',
      fileSize: '54.0 KB',
      tags: ['#dsa', '#cay-nhi-phan', '#do-thi'],
      badgeColor: Color(0xFF1E3A8A),
      badgeText: 'SỔ TAY .BFLY',
    ),
  ];
}
