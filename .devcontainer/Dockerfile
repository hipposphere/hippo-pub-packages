FROM ubuntu:22.04

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/root/.pub-cache/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor

# Install Melos globally
RUN dart pub global activate melos