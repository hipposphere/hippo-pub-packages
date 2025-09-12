import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:hippo_components/hippo_components.dart';

part 'parts/light_theme.dart';
part 'parts/dark_theme.dart';

class HippoThemeBuilder extends StatelessWidget {
  final Brightness brightness;
  final Widget child;

  const HippoThemeBuilder({super.key, required this.brightness, required this.child});

  @override
  Widget build(BuildContext context) {
    return FTheme(
      data: brightness == Brightness.light ? lightForuiTheme : darkForuiTheme,
      child: Theme(
        data: brightness == Brightness.light ? lightMaterialTheme : darkMaterialTheme,
        child: child,
      ),
    );
  }
}
