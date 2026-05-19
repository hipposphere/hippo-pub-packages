# hippo_utils

Curated collection of utility wrappers, re‑exports, lightweight abstractions, and reactive helpers used across Hipposphere Flutter & Dart codebases. The goal: reduce repetitive boilerplate imports while centralizing upgrade points for common third‑party packages.

## Features

### Re‑Exports / Facades
- Common packages: `filesize`, `url_launcher`, `share_plus`, `rxdart`, `package_info_plus`, `mime`, etc.
- Platform / device utilities (via thin wrappers) to keep app code clean.

### Reactive & State Helpers
- BLoC scaffolding (`bloc_provider`, `multi_bloc_provider`, typed base classes)
- `DataSubject` abstractions for simple reactive data flows
- Stream extensions (`extensions/stream_extensions.dart`)

### Storage Abstractions
- Unified key/value and file store APIs (`store/`, `file_store/`, `key_value_store/`)
- Pluggable backends enabling in‑memory, local file, or (future) secure storage implementations

### Tooling & Misc
- Convenience layer around purchases, analytics, file picking/sharing
- Guarded imports to reduce platform branching in app layer

## Installation

Add dependency (after publishing) or use local path during monorepo development:
```yaml
dependencies:
	hippo_utils: ^0.3.0
	# OR (local path outside repo root consumer)
	# hippo_utils:
	#   path: ../hippo-packages/packages/hippo_utils
```

Import the barrel:
```dart
import 'package:hippo_utils/hippo_utils.dart';
```

## Example Usage

### BLoC Provision
```dart
class CounterBloc extends BlocBase<int> {
	CounterBloc() : super(0);
	void increment() => emit(state + 1);
}

Widget build(BuildContext context) {
	return BlocProvider(
		create: () => CounterBloc(),
		child: Builder(
			builder: (context) {
				final value = context.watchBloc<CounterBloc>().state; // hypothetical extension
				return Text('$value');
			},
		),
	);
}
```

### DataSubject
```dart
final subject = DataSubject<int>(initialValue: 1);
subject.stream.listen((v) => print('value => $v'));
subject.add(2);
```

### File Size Formatting
```dart
import 'package:hippo_utils/filesize.dart';
final human = filesize(1536000); // => "1.5 MB"
```

> NOTE: Adjust examples to actual exported API names if they differ; treat above as conceptual patterns.

## Directory Highlights

```
lib/
	hippo_utils.dart        # Barrel export
	src/
		bloc/                 # BLoC helpers
		data_subject/         # Reactive subject abstraction
		extensions/           # Stream and other extensions
		implementations/      # Concrete impls (content_resolver, etc.)
		store/                # Storage abstractions & impls
		tools/                # Misc tooling (analytics, purchases, etc.)
```

## Design Principles
- Keep abstractions thin – prefer pass‑through unless value is added.
- Minimize transitive surface; only re‑export what is broadly useful.
- Encourage testability by decoupling storage & platform specifics.

## Development
From monorepo root:
```pwsh
dart run melos bootstrap
dart analyze packages/hippo_utils
dart format packages/hippo_utils -o write
```

## Contributing
1. Limit sprawl: new wrapper libs should meet a repeated‑need threshold.
2. Add doc comments for any new public symbol.
3. Record changes in `CHANGELOG.md` (breaking changes clearly flagged).
4. Avoid leaking unmaintained experimental APIs via barrel export.

## Roadmap
- Additional platform safe wrappers (share targets, intents)
- Async caching strategies (LRU, TTL) layered atop stores
- Metrics & tracing hooks
- Test coverage expansion

---

Happy hacking with `hippo_utils`! 🦛