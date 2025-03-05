# 智能图像分割服务（Image-Segment）

基于深度学习的通用图像分割服务，支持人物、物体等多场景精准提取，提供即开即用的Docker化部署方案。

## 🎯 核心功能

### 精准图像分割
- 采用U2-Net优化模型，支持复杂边缘识别。
- 智能输出最小包围盒区域。
- 支持PNG透明背景导出。

### 企业级特性
- 🐳 Docker一键部署。
- ⚡ ONNX Runtime加速推理。
- 🔄 流式处理支持（最大100MB文件）。

## 🛠️ 快速部署

### 环境要求
- Docker 20.10+。
- 4GB可用内存。
- 支持AVX指令集的CPU。

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

## 📝 使用建议

### Docker生产部署
```bash
# 推荐配置
docker run -d \
  -p 5000:5000 \
  --name image-segment \
  --restart always \
  --shm-size=2g \
  image-segment
```

## 🌐 调用示例

### Java调用（Hutool）
```java

import cn.hutool.core.io.FileUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.http.HttpStatus;

import java.io.InputStream;
import java.nio.file.Paths;

public class ImageSegmentTest {
    // 服务地址(根据实际情况修改)
    private static final String API_URL = "http://localhost:5000/segment";
    // 输入图片路径(测试前需替换实际路径)
    private static final String INPUT_PATH = "before.png";
    // 输出图片保存路径
    private static final String OUTPUT_PATH = "result.png";

    public static void main(String[] args) {
        try {
            // 1. 读取图片文件为字节数组
            byte[] imageBytes = FileUtil.readBytes(INPUT_PATH);

            // 2. 构建HTTP请求(自动识别超时和重试)
            HttpResponse response = HttpRequest.post(API_URL)
                    .timeout(30000) // 30秒超时
                    .body(imageBytes)
                    .contentType("image/jpeg") // 根据实际图片类型修改
                    .execute();

            // 3. 处理响应
            if (response.getStatus() == HttpStatus.HTTP_OK) {
                try (InputStream resultStream = response.bodyStream()) {
                    // 保存结果图片
                    FileUtil.writeFromStream(resultStream, Paths.get(OUTPUT_PATH).toFile());
                    System.out.println("处理成功，结果保存至: " + OUTPUT_PATH);
                }
            } else {
                System.err.println("请求失败: " + response.getStatus()
                        + " | 错误信息: " + response.body());
            }
        } catch (Exception e) {
            // 异常处理(包含网络错误、文件IO错误等)
            System.err.println("发生错误: " + e.getClass().getSimpleName());
            System.err.println("错误详情: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

```

### Python调用
```python
import requests

response = requests.post(
    "http://localhost:5000/segment",
    data=open("input.jpg", "rb"),
    headers={"Content-Type": "image/jpeg"}
)
```

## 📞 技术支持

请提供以下信息以获取帮助：
- 输入图片样本。
- 完整请求头信息。
- 服务日志片段。
```
