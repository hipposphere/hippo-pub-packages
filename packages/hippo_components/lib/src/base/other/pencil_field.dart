import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:pencil_kit/pencil_kit.dart';

class PencilFieldBloc extends BlocBase {
  PencilKitController? pencilKitController;

  PencilFieldBloc._({required this.pencilKitController});

  factory PencilFieldBloc.create() => PencilFieldBloc._(pencilKitController: null);

  void setPencilKitController(PencilKitController controller) {
    pencilKitController = controller;
    controller.setPKTool(toolType: ToolType.marker, color: Colors.green.withValues(alpha: 0.5));
  }

  @override
  void dispose() {}

  static PencilFieldBloc of(BuildContext context) {
    return BlocProvider.of(context);
  }
}

class PencilField extends StatelessWidget {
  const PencilField({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = PencilFieldBloc.of(context);
    return PencilKit(
      onPencilKitViewCreated: (controller) {
        bloc.setPencilKitController(controller);
      },
    );
  }
}

/// DEMO:
///   runApp(CupertinoApp(
//     home: CupertinoPageScaffold(
//       child: Center(
//         child: SizedBox(
//           height: 400,
//           width: 400,
//           child: Stack(
//             children: [
//               Text(
//                 '''
// Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam
//  suscipit, nunc nec ultricies ultricies, nunc nunc ultricies
//  ultricies, nunc nunc ultricies ultricies, nunc nunc ultricies
//  ultricies, nunc nunc ultricies ultricies, nunc nunc ultricies
//  ultricies, nunc nunc ultricies ultricies, nunc nunc ultricies
//  ultricies, nunc nunc ultricies ultricies, nunc nunc ultricies''',
//                 style: TextStyle(fontSize: 16),
//               ),
//               BlocProvider<PencilFieldBloc>(
//                 bloc: PencilFieldBloc.create(),
//                 child: PencilField(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   ));
