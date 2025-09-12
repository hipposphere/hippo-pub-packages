import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';

class ElevatedElement extends StatelessWidget {
  final bool isElevated;
  final Widget child;
  const ElevatedElement({super.key, required this.isElevated, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: isElevated ? 5.0 : 0.0, // Line height animation on hover
            width: double.infinity,

            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: HippoColors.black.withValues(alpha: 0.3),
                  blurRadius: 10.0, // Blur to spread the shadow like a line
                  offset: Offset(0, 2), // Offset to position the shadow slightly below
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
