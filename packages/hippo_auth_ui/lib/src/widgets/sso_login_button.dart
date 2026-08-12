import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_components/hippo_components.dart';

class HippoAuthSSOLoginButton extends StatelessWidget {
  final HippoAuthSSOProvider provider;
  final VoidCallback onTap;

  const HippoAuthSSOLoginButton({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      onTap: onTap,
      prefix:
          provider.branding?.logoBuilder(context) ??
          const Icon(Icons.person_outline),
      label: 'Mit ${provider.name} anmelden',
      type: ButtonType.outline,
    );
  }
}
