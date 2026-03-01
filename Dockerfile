FROM python:3.15.0a6-slim@sha256:474a282e7062c23bf8399b6aac44a078670f0b81ace9b817e0000dc9e2b3e02c

LABEL org.opencontainers.image.source=https://github.com/binarly-io/fwhunt-scan

# Cf. https://github.com/rizinorg/rizin/releases
ARG rz_version=v0.8.1
ARG DEBIAN_FRONTEND=noninteractive

# add library paths
ENV LD_LIBRARY_PATH=/tmp/rizin-$rz_version/build/librz/core

RUN apt-get update && apt-get install -y ninja-build parallel wget build-essential && apt-get full-upgrade -y
RUN pip install meson

# add fwhunt_scan unprivileged user
RUN useradd -u 1001 -m fwhunt_scan

# install rizin from source code
WORKDIR /tmp
RUN wget https://github.com/rizinorg/rizin/releases/download/$rz_version/rizin-src-$rz_version.tar.xz && tar -xf rizin-src-$rz_version.tar.xz

WORKDIR /tmp/rizin-$rz_version
RUN meson build
RUN ninja -C build install

# install fwhunt_scan
COPY fwhunt_scan_analyzer.py /home/fwhunt_scan/app/
COPY requirements.txt /home/fwhunt_scan/app/
COPY fwhunt_scan /home/fwhunt_scan/app/fwhunt_scan

WORKDIR /home/fwhunt_scan/app/
RUN pip install -r requirements.txt

USER fwhunt_scan

ENTRYPOINT ["python3", "fwhunt_scan_analyzer.py"]
