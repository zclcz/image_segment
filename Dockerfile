# 使用官方Python镜像并切换阿里云源
FROM python:3.10-slim

LABEL authors="zcl"

# 替换Debian阿里云镜像源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖（使用阿里云源加速）
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        wget \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 设置阿里云PyPI镜像
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip config set global.trusted-host mirrors.aliyun.com

# 分步复制文件以利用缓存
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 下载模型（使用国内CDN加速）
RUN mkdir -p /app/models \
    && wget https://openbayes-public.oss-cn-hangzhou.aliyuncs.com/u2net.onnx \
        -O /app/models/u2net.onnx \
    && echo "b7cbf5a0ab8a735a4f8e3d6d30bffd2e6a7c2c5a5d6c0d7e3c6d8c0d5e3a2e8f  /app/models/u2net.onnx" | sha256sum -c

# 最后复制项目代码
COPY . .

# 环境变量配置
ENV U2NET_HOME=/app/models

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["python", "app.py"]
