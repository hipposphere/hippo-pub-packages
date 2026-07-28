import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';

void main() {
  test('forwards the system overlay brightness to CupertinoNavigationBar', () {
    final header = PageHeader(title: 'Title', brightness: Brightness.light);

    expect(header.brightness, Brightness.light);
  });
}
