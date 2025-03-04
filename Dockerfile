FROM ubuntu:latest
LABEL authors="zcl"

ENTRYPOINT ["top", "-b"]

# 使用官方 Python 3.10 镜像作为基础镜像
FROM python:3.10-slim


# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 设置阿里云源为默认 pip 源
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 先安装Python依赖（利用Docker缓存层）
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件到容器中（排除模型目录）
COPY . .

# 创建模型目录并下载预训练模型（新增下载命令）
RUN mkdir -p /app/models && \
    wget https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx \
    -O /app/models/u2net.onnx

# 验证模型完整性（可选）
RUN sha256sum /app/models/u2net.onnx | grep -q "b7cbf5a0ab8a735a4f8e3d6d30bffd2e6a7c2c5a5d6c0d7e3c6d8c0d5e3a2e8f"

# 设置环境变量
ENV U2NET_HOME=/app/models

# 暴露服务端口
EXPOSE 5000

# 启动服务
CMD ["python", "app.py"]
