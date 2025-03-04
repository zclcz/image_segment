# 环境安装
# pip install rembg opencv-python numpy flask
import os
from rembg import remove
from PIL import Image
import numpy as np
from flask import Flask, request, Response
import io

# 设置模型路径
os.environ['U2NET_HOME'] = '/app/models'

app = Flask(__name__)


def remove_background_and_crop(image_stream):
    """
    抠取图片中的人物并裁剪出只包含人物的区域

    参数：
    image_stream: 图片的二进制流

    返回：
    cropped_img: 裁剪后的图片（PIL.Image对象）
    """
    try:
        # 从二进制流读取图片
        original_img = Image.open(io.BytesIO(image_stream))

        # 使用U2-Net模型进行背景去除
        result_img = remove(
            original_img,
            post_process_mask=True,  # 启用后处理，减少糊边
            alpha_matting=True,      # 启用透明边缘处理
            alpha_matting_foreground_threshold=50,  # 降低前景阈值，保留复杂区域
            alpha_matting_background_threshold=0,   # 降低背景阈值，减少背景残留
            alpha_matting_erode_size=5              # 减小边缘腐蚀大小
        )

        # 将抠图结果转换为NumPy数组
        result_np = np.array(result_img)

        # 找到人物的边界框
        alpha_channel = result_np[:, :, 3]  # 获取透明度通道
        coords = np.argwhere(alpha_channel > 0)  # 找到不透明区域的坐标
        y_min, x_min = coords.min(axis=0)  # 左上角坐标
        y_max, x_max = coords.max(axis=0)  # 右下角坐标

        # 裁剪出只包含人物的区域
        cropped_img = result_img.crop((x_min, y_min, x_max, y_max))

        return cropped_img

    except Exception as e:
        raise ValueError(f"抠图失败，错误信息：{str(e)}")


@app.route('/imageSegment', methods=['POST'])
def remove_bg_api():
    """
    REST API 接口：接收图片流，返回抠图后的图片流
    """
    try:
        # 从请求中获取图片流
        if 'file' not in request.files:
            return Response("未上传文件", status=400)

        file = request.files['file']
        if file.filename == '':
            return Response("文件名为空", status=400)

        # 调用抠图函数
        cropped_img = remove_background_and_crop(file.read())

        # 将裁剪后的图片转换为二进制流
        output_stream = io.BytesIO()
        cropped_img.save(output_stream, format="PNG", quality=100)
        output_stream.seek(0)

        # 返回图片流
        return Response(output_stream.getvalue(), mimetype='image/png')

    except Exception as e:
        return Response(f"处理失败：{str(e)}", status=500)


if __name__ == "__main__":
    # 启动Flask服务
    app.run(host="0.0.0.0", port=5000)
