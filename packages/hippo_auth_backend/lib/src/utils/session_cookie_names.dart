const betterAuthSessionCookieName = 'better-auth.session_token';
const legacyBetterAuthSessionCookieName = 'better-auth.session-token';

const _betterAuthSessionCookieBaseNames = <String>[
  betterAuthSessionCookieName,
  'better-auth-session_token',
  legacyBetterAuthSessionCookieName,
];

List<String> betterAuthSessionCookieAliases([String? primary]) {
  final names = <String>[];
  void add(String? value) {
    if (value == null || value.isEmpty || names.contains(value)) {
      return;
    }
    names.add(value);
  }

  add(primary);
  for (final name in _betterAuthSessionCookieBaseNames) {
    add(name);
    add('__Secure-$name');
    add('__Host-$name');
  }
  return names;
}

bool isBetterAuthSessionCookieName(String name) {
  return betterAuthSessionCookieAliases().contains(name);
}
