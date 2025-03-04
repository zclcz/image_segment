# 环境依赖：pip install rembg opencv-python numpy flask
import os
from rembg import remove
from PIL import Image
import numpy as np
from flask import Flask, request, Response, send_file
import io

# 设置模型路径
os.environ['U2NET_HOME'] = '/app/models'

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024  # 允许最大100MB文件上传


def process_image_stream(image_stream):
    """
    处理原始图片流的通用方法
    """
    try:
        # 从二进制流读取图片
        original_img = Image.open(io.BytesIO(image_stream))

        # 转换格式处理
        if original_img.mode not in ['RGB', 'RGBA']:
            original_img = original_img.convert('RGB')

        # 执行抠图处理
        result_img = remove(
            original_img,
            post_process_mask=True,
            alpha_matting=True,
            alpha_matting_foreground_threshold=50,
            alpha_matting_background_threshold=0,
            alpha_matting_erode_size=5
        )

        # 转换为NumPy数组进行裁剪处理
        result_np = np.array(result_img)
        alpha_channel = result_np[:, :, 3]
        coords = np.argwhere(alpha_channel > 0)
        if coords.size == 0:
            raise ValueError("未检测到有效人物区域")

        y_min, x_min = coords.min(axis=0)
        y_max, x_max = coords.max(axis=0)
        cropped_img = result_img.crop((x_min, y_min, x_max, y_max))

        return cropped_img

    except Exception as e:
        raise RuntimeError(f"图片处理失败: {str(e)}")


@app.route('/segment', methods=['POST'])
def image_segment():
    """
    流式处理接口
    接收：原始图片二进制流（Content-Type: application/octet-stream）
    返回：PNG格式抠图结果
    """
    try:
        # 验证输入数据
        if not request.data:
            return Response("请求体为空", status=400, mimetype='text/plain')

        # 处理图片流
        cropped_img = process_image_stream(request.data)

        # 准备输出流
        output_stream = io.BytesIO()
        cropped_img.save(output_stream, format="PNG", optimize=True)
        output_stream.seek(0)

        # 流式响应
        return send_file(
            output_stream,
            mimetype='image/png',
            as_attachment=True,
            download_name='result.png'
        )

    except RuntimeError as e:
        return Response(str(e), status=400, mimetype='text/plain')
    except Exception as e:
        app.logger.error(f"服务器错误: {str(e)}")
        return Response("内部服务器错误", status=500, mimetype='text/plain')


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)