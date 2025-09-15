#!/usr/bin/env bash
set -e

# Install dependencies
apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
if [ ! -d "/usr/local/flutter" ]; then
  git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
fi
export PATH="$PATH:/usr/local/flutter/bin"

# Verify Flutter install
flutter doctor -v

# Activate Melos globally
dart pub global activate melos

# Ensure global packages are in PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Clone repo if not already mounted (Coder usually mounts your repo into /workspace)
if [ ! -d "/workspace/.git" ]; then
  git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_FLUTTER_REPO.git /workspace
fi

cd /workspace

# Bootstrap Melos workspace
melos bootstrap
