FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Base deps
RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    ca-certificates gnupg software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# ---- Chromium (DEB, not Snap) on Ubuntu 22.04 ----
# Savoury1 PPAs provide chromium debs for jammy (amd64 & arm64)
RUN add-apt-repository -y ppa:savoury1/ffmpeg4 \
    && add-apt-repository -y ppa:savoury1/chromium \
    && apt-get update \
    && apt-get install -y chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# Wrapper so Chromium works in containers (root) + for Flutter
RUN printf '#!/usr/bin/env bash\nexec /usr/bin/chromium-browser --no-sandbox --disable-dev-shm-usage "$@"\n' \
    > /usr/local/bin/chrome \
    && chmod +x /usr/local/bin/chrome
ENV CHROME_EXECUTABLE="/usr/local/bin/chrome"

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/root/.pub-cache/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor

# Install Melos globally
RUN dart pub global activate melos