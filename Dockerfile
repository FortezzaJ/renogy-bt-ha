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
    jq  # Required for parsing JSON in run.sh

# Install bashio
RUN mkdir -p /usr/local/bin/bashio && \
    wget -O /usr/local/bin/bashio/bashio "https://github.com/hassio-addons/bashio/archive/main.tar.gz" && \
    tar -xzf /usr/local/bin/bashio/bashio --strip 1 && \
    chmod a+x /usr/local/bin/bashio/bashio

# Ensure pip is installed and upgraded correctly, with retries for network issues
RUN python3 -m ensurepip --upgrade || (sleep 5 && python3 -m ensurepip --upgrade)
RUN pip3 install --no-cache-dir --upgrade pip || (sleep 5 && pip3 install --no-cache-dir --upgrade pip)

# Install Python packages with retries for network or dependency issues
RUN pip3 install --no-cache-dir \
    bleak \
    paho-mqtt \
    || (sleep 5 && pip3 install --no-cache-dir bleak paho-mqtt)

# Copy add-on files
COPY run.sh /run.sh
COPY renogy_bt.py /renogy_bt.py

# Set permissions
RUN chmod a+x /run.sh

# Run the script
CMD ["/run.sh"]
