# 智能图像分割服务（Image-Segment）

基于深度学习的通用图像分割服务，支持人物、物体等多场景精准提取，提供即开即用的Docker化部署方案。

## 🎯 核心功能

### 精准图像分割
- 采用U2-Net优化模型，支持复杂边缘识别
- 智能输出最小包围盒区域
- 支持PNG透明背景导出

### 企业级特性
- 🐳 Docker一键部署
- ⚡ ONNX Runtime加速推理
- 🔄 流式处理支持（最大100MB文件）

## 🛠️ 快速部署

### 环境要求
- Docker 20.10+
- 4GB可用内存
- 支持AVX指令集的CPU

### 启动服务
```bash
git clone https://github.com/zclcz/image_segment.git
cd image_segment/
# 构建镜像
docker build -t image-segment .

# 运行容器（推荐分配2GB共享内存）
docker run -d --shm-size=2g -p 5000:5000 image-segment
```

## ⚙️ 性能指标

| 指标               | 数值         |
|--------------------|--------------|
| 最大输入分辨率     | 4096x4096像素|
| 平均处理耗时（1080P）| 2.5s       |
| 峰值内存占用       | 1.5GB        |
| 并发处理能力       | 12 QPS（4核CPU）|

##📌 使用建议
###Docker生产部署
```Bash
# 推荐配置
docker run -d \
  -p 5000:5000 \
  --name image-segment \
  --restart always \
  --shm-size=2g \
  image-segment
```

🌐 客户端示例
Java调用（Hutool）
```Java
HttpResponse res = HttpRequest.post("http://localhost:5000/segment")
    .body(FileUtil.readBytes("input.jpg"), "image/jpeg")
    .timeout(30000)
    .execute();
```
Python调用
```Python
import requests
response = requests.post("http://localhost:5000/segment", 
    data=open("input.jpg", "rb"),
    headers={"Content-Type": "image/jpeg"}
)
```
## 📞 **技术支持**

请提供以下信息以获取帮助：
- 输入图片样本
- 完整请求头信息
- 服务日志片段
