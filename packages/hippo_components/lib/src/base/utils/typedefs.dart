/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/widgets.dart';

typedef ContextVoidCallback = void Function(BuildContext context);

typedef Contextable<T> = T Function(BuildContext context);

T contextValue<T>(BuildContext context, T value) => value;

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
