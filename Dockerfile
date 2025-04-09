FROM python:3.10-slim AS base

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
RUN rm -rf /etc/apt/sources.list.d/*
RUN rm -rf /etc/apt/sources.list

# 创建新的 sources.list 文件，仅使用 USTC 镜像
RUN echo "deb http://mirrors.ustc.edu.cn/debian bookworm main contrib non-free non-free-firmware\n\
deb http://mirrors.ustc.edu.cn/debian bookworm-updates main contrib non-free non-free-firmware\n\
deb http://mirrors.ustc.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware" > /etc/apt/sources.list

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制项目文件
COPY . /app/

ENV HF_ENDPOINT https://hf-mirror.com


RUN pip install --no-cache-dir -e . -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
RUN pip install torch diart faster-whisper huggingface_hub -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
# 暴露端口
EXPOSE 8000

 

# 启动服务
CMD ["whisperlivekit-server", "--model", "small", "--host", "0.0.0.0","--port","8000","--language","zh"]