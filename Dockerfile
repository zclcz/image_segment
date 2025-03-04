FROM ubuntu:latest
LABEL authors="赵成亮"

ENTRYPOINT ["top", "-b"]

# 使用官方 Python 3.9 镜像作为基础镜像
FROM python:3.10-slim


# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制项目文件到容器中
COPY .. .

# 设置阿里云源为默认 pip 源
RUN  pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 创建模型目录并将模型文件复制到镜像中
RUN mkdir -p /app/models
COPY models/u2net.onnx /app/models/u2net.onnx

# 设置环境变量
ENV U2NET_HOME=/app/models

# 暴露服务端口
EXPOSE 5000

# 启动服务
CMD ["python", "app.py"]
