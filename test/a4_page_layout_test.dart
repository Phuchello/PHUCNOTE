// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/a4_page_layout.dart';

void main() {
  test('Page indices use inclusive tops and exclusive bottoms across gaps', () {
    for (final index in [1, 2, 42]) {
      final page = A4PageLayout.pageBounds(index);
      expect(page.size, const Size(840, 1188));
      expect(A4PageLayout.pageIndexAtY(page.top), index);
      expect(A4PageLayout.pageIndexAtY(page.bottom - 0.001), index);
      expect(A4PageLayout.pageIndexAtY(page.bottom), isNull);
      expect(A4PageLayout.pageIndexAtY(page.bottom + 12), isNull);
      expect(A4PageLayout.pageIndexAtY(page.bottom + 23.999), isNull);
      expect(A4PageLayout.pageIndexAtY(page.bottom + 24), index + 1);
      expect(
        A4PageLayout.gapAfterPage(index),
        Rect.fromLTWH(0, page.bottom, 840, 24),
      );
    }
    expect(A4PageLayout.pageIndexAtY(-0.001), isNull);
    expect(A4PageLayout.pageIndexAtY(double.infinity), isNull);
    expect(A4PageLayout.pageIndexAtY(double.nan), isNull);
    expect(() => A4PageLayout.pageBounds(0), throwsArgumentError);
  });

  test('Horizontal page boundaries reject outside starts', () {
    expect(A4PageLayout.pageIndexAt(const Offset(0, 1212)), 2);
    expect(A4PageLayout.pageIndexAt(const Offset(839.999, 1212)), 2);
    expect(A4PageLayout.pageIndexAt(const Offset(840, 1212)), isNull);
    expect(A4PageLayout.pageIndexAt(const Offset(-0.001, 1212)), isNull);
    expect(A4PageLayout.pageIndexAt(const Offset(200, 1200)), isNull);
    expect(A4PageLayout.pageIndexAt(const Offset(double.nan, 200)), isNull);
  });

  test('Visible page sequence retains the existing vertical guide bounds', () {
    expect(
      A4PageLayout.visiblePageIndices(const Rect.fromLTWH(0, 0, 800, 1000)),
      [1],
    );
    expect(
      A4PageLayout.visiblePageIndices(const Rect.fromLTWH(0, 1100, 800, 1500)),
      [1, 2, 3],
    );
    expect(
      A4PageLayout.visiblePageIndices(const Rect.fromLTWH(0, 50000, 800, 1000)),
      [42, 43],
    );
  });
}
