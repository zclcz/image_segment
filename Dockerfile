# 使用官方 Python 3.10 精简镜像
FROM python:3.10-slim

LABEL authors="zcl"

# 配置阿里云APT镜像源（适配slim镜像）
RUN echo "Types: deb" > /etc/apt/sources.list.d/debian.sources \
 && echo "URIs: http://mirrors.aliyun.com/debian" >> /etc/apt/sources.list.d/debian.sources \
 && echo "Suites: bookworm bookworm-updates bookworm-backports" >> /etc/apt/sources.list.d/debian.sources \
 && echo "Components: main contrib non-free non-free-firmware" >> /etc/apt/sources.list.d/debian.sources \
 && echo "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" >> /etc/apt/sources.list.d/debian.sources

# 安装系统依赖
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    wget \
 && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 配置阿里云PyPI镜像
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
 && pip config set global.trusted-host mirrors.aliyun.com

# 分阶段复制文件优化构建缓存
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 下载模型文件（使用阿里云CDN）
RUN mkdir -p /app/models \
 && wget https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx -O /app/models/u2net.onnx 

# 复制项目代码
COPY . .

# 环境变量配置
ENV U2NET_HOME=/app/models

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["python", "app.py"]
