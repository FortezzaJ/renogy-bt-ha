ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM $BUILD_FROM

# Install system dependencies, including build tools for Python packages and bashio
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bluez \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    openssl-dev \
    build-base \
    jq

# Install bashio
RUN mkdir -p /usr/local/bin/bashio && \
    wget -O /usr/local/bin/bashio/bashio "https://github.com/hassio-addons/bashio/archive/main.tar.gz" && \
    tar -xzf /usr/local/bin/bashio/bashio --strip 1 && \
    chmod a+x /usr/local/bin/bashio/bashio

# Ensure pip is installed and upgraded correctly, with multiple retries for network issues
RUN for i in {1..3}; do \
    python3 -m ensurepip --upgrade && break || sleep 5; \
    done || (echo "Failed to install ensurepip after retries" && exit 1)
RUN for i in {1..3}; do \
    pip3 install --no-cache-dir --upgrade pip && break || sleep 5; \
    done || (echo "Failed to upgrade pip after retries" && exit 1)

# Install Python packages with retries for network or dependency issues
RUN for i in {1..3}; do \
    pip3 install --no-cache-dir \
        bleak \
        paho-mqtt && \
    break || sleep 5; \
    done || (echo "Failed to install Python packages after retries" && exit 1)

# Copy add-on files
COPY run.sh /run.sh
COPY renogy_bt.py /renogy_bt.py

# Set permissions
RUN chmod a+x /run.sh

# Run the script
CMD ["/run.sh"]
