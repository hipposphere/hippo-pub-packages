/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
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
