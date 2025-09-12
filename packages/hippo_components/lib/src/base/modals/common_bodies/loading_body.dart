import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class LoadingModalBody extends ModalBody {
  LoadingModalBody({required BuildContext context})
    : super(
        title: context.cl.common_loading,
        slivers: [
          SliverGap(32),
          SliverChild(
            crossAxisAlignment: CrossAxisAlignment.center,
            child: CircularProgressIndicator.adaptive(),
          ),
          SliverGap(32),
        ],
      );
}
