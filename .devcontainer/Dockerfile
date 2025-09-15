FROM ubuntu:22.04

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome (for Flutter Web)
# Use keyrings per Debian/Ubuntu best practices
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-linux.gpg \
    && chmod a+r /etc/apt/keyrings/google-linux.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Wrapper to allow Chrome to run inside containers (root) without sandbox issues
RUN echo '#!/usr/bin/env bash' > /usr/local/bin/chrome \
    && echo 'exec /usr/bin/google-chrome --no-sandbox --disable-dev-shm-usage "$@"' >> /usr/local/bin/chrome \
    && chmod +x /usr/local/bin/chrome
ENV CHROME_EXECUTABLE="/usr/local/bin/chrome"

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/root/.pub-cache/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor

# Install Melos globally
RUN dart pub global activate melos