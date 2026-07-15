# speech_utils_platform_interface

Typed recorder backend contract for the federated `speech_utils` family.

Platform implementations own capture lifecycle, native resources, permissions,
device discovery, and native assets. The app-facing package owns shared policy
and orchestration.
