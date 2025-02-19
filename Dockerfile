ARG BUILD_FROM=ghcr.io/home-assistant/armv7-base:latest
FROM $BUILD_FROM

# Install system dependencies, including build tools for Python packages
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bluez \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    openssl-dev

# Upgrade pip to the latest version
RUN pip3 install --upgrade pip

# Install Python packages
RUN pip3 install --no-cache-dir \
    bleak==0.20.2 \
    paho-mqtt

# Copy add-on files
COPY run.sh /run.sh
COPY renogy_bt.py /renogy_bt.py

# Set permissions
RUN chmod a+x /run.sh

# Run the script
CMD ["/run.sh"]
