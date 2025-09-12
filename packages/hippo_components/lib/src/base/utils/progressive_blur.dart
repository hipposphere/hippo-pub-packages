import 'package:flutter/material.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class ProgressiveBlur extends StatelessWidget {
  final Widget child;
  final double height;
  final double sigma;
  const ProgressiveBlur({
    super.key,
    required this.child,
    required this.height,
    required this.sigma,
  });

  @override
  Widget build(BuildContext context) {
    return SoftEdgeBlur(
      edges: [
        EdgeBlur(
          type: EdgeType.bottomEdge,
          size: height,
          sigma: sigma,
          tileMode: TileMode.mirror,
          controlPoints: [
            ControlPoint(position: 0.5, type: ControlPointType.visible),
            ControlPoint(position: 1, type: ControlPointType.transparent),
          ],
        ),
      ],
      child: child,
    );
  }
}
