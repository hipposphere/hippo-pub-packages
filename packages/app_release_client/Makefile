.PHONY: build

build:
	flutter pub get
	dart run tool/normalize_openapi.dart specs/openapi.json
	dart run build_runner build --delete-conflicting-outputs
