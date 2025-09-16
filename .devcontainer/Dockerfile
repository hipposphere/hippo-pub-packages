FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Base tools (combined to keep layers small)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev libstdc++-12-dev \
    chromium-browser ca-certificates

ENV CHROME_EXECUTABLE="/usr/bin/chromium"

# ---- Flutter ----
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/root/.pub-cache/bin:${PATH}"

# Pre-download Flutter artifacts
RUN dart --disable-analytics
RUN flutter doctor

# Download Web SDK
RUN flutter config --enable-web
RUN flutter precache


# Install Melos globally
RUN dart pub global activate melos