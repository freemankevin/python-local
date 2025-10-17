# 使用官方 Python 3.10 slim 镜像作为基础
ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim

LABEL maintainer="https://github.com/freemankevin/python-local"

# 设置非交互式环境和上海时区
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        fonts-noto-cjk \
        libgdal-dev \
        poppler-utils \
        gdal-bin \
        libpq5 \
        libgl1 \
        curl \
        g++ \
        libreoffice \
        net-tools \
        iputils-ping \
        dnsutils \
        telnet \
        xvfb \
        libfuse2 \
        libfontconfig1 \
        vim \
        tesseract-ocr \
        libtesseract-dev \
        tesseract-ocr-eng \
        tesseract-ocr-chi-sim \
        tesseract-ocr-chi-tra \
        tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 安装 wkhtmltopdf (支持多架构)
RUN set -eux; \
    TARGETARCH=$(dpkg --print-architecture); \
    if [ "$TARGETARCH" = "amd64" ]; then \
        WKHTMLTOPDF_URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        WKHTMLTOPDF_URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_arm64.deb"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi; \
    curl -sSL -o /tmp/wkhtmltox.deb "$WKHTMLTOPDF_URL" && \
    dpkg -i /tmp/wkhtmltox.deb --force-depends || true && \
    rm -f /tmp/wkhtmltox.deb && \
    apt-get install -y -qq --no-install-recommends \
        fontconfig \
        fonts-dejavu \
        fonts-liberation \
        xfonts-encodings && \
    rm -rf /var/lib/apt/lists/*

# 升级 pip，使用默认 PyPI 源
RUN pip install -qq --upgrade pip

# 设置工作目录
WORKDIR /home

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1