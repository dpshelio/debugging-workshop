ARG UV_VERSION=latest
ARG DEBIAN_VERSION=bookworm


FROM ghcr.io/astral-sh/uv:$UV_VERSION AS uv


FROM mcr.microsoft.com/vscode/devcontainers/base:$DEBIAN_VERSION

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    # For OpenCV etc...
    libgl1 libglib2.0-0 libopenmpi-dev gfortran gdb \
    # To remove the image size, it is recommended refresh the package cache as follows
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install valgrind
RUN wget https://sourceware.org/pub/valgrind/valgrind-3.25.0.tar.bz2 \
    && tar xf valgrind-3.25.0.tar.bz2 \
    && cd valgrind-3.25.0 \
    && ./configure --prefix=/usr \
    && make -j 4 \
    && sudo make install \
    && cd \
    && rm -rf valgrind-3.25.0

COPY --from=uv --chown=vscode: /uv /uvx /bin/
