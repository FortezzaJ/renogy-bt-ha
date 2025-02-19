ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
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

# Ensure pip is installed and upgraded correctly
RUN python3 -m ensurepip --upgrade
RUN pip3 install --no-cache-dir --upgrade pip

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
