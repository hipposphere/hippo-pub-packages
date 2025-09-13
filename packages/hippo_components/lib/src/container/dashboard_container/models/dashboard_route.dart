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

sealed class GenericDashboardRoute<T> {
  Widget? get badge;
  IconData get icon;
  Contextable<String> get label;
}

class DashboardRoute<T> implements GenericDashboardRoute<T> {
  @override
  final IconData icon;
  final IconData selectedIcon;
  @override
  final Widget? badge;
  @override
  final Contextable<String> label;
  final T value;

  const DashboardRoute({
    this.badge,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.value,
  });
}

class CustomDashboardRoute<T> implements GenericDashboardRoute<T> {
  @override
  final IconData icon;
  @override
  final Widget? badge;
  @override
  final Contextable<String> label;

  final ContextVoidCallback? onTap;

  const CustomDashboardRoute({this.badge, required this.label, required this.icon, this.onTap});
}
