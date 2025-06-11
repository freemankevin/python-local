# 使用官方 Python 3.10 slim 镜像作为基础
ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim

# 获取架构信息
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM, targeting $TARGETPLATFORM"

# 设置非交互式环境和上海时区
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        libgdal-dev \
        gdal-bin \
        libpq5 \
        curl \
        g++ \
        libreoffice \
        net-tools \
        iputils-ping \
        dnsutils \
        telnet \
        tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 升级 pip，使用默认 PyPI 源
RUN pip install -qq --upgrade pip

# 设置工作目录
WORKDIR /home

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1