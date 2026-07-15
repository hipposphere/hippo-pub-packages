# desktop_autopaste_platform_interface

Platform contract for the federated `desktop_autopaste` package family.

It owns the public data models, implementation registration point, safe
unsupported fallback, and shared C-ABI marshalling used by endorsed packages.
Applications should depend on `desktop_autopaste`, not this package directly.
