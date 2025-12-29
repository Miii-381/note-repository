# 1. 介绍

OpenCV（Open Source Computer Vision Library）是一个开源的计算机视觉和机器学习软件库。
## 主要特点：
- **跨平台支持**：支持 Windows、Linux、macOS、Android 和 iOS 等多种操作系统
- **多语言接口**：提供 C++、Python、Java 等编程语言接口
- **丰富的功能**：包含图像处理、视频分析、特征检测、对象识别等众多功能模块

## 核心功能模块：
- **图像处理**：图像滤波、几何变换、色彩空间转换等
- **视频分析**：运动检测、目标跟踪、视频编解码等
- **特征检测**：角点检测、边缘检测、特征匹配等
- **机器学习**：支持向量机、决策树、神经网络等算法
- **相机标定**：相机参数标定、立体视觉等

## 在 Python 中的使用：
通过 `cv2` 模块可以方便地调用 OpenCV 功能：
```python
import cv2

# 常用函数示例
img = cv2.imread('image.png')  # 读取图像
cv2.imshow('window', img)      # 显示图像
cv2.waitKey(0)                 # 等待按键
cv2.destroyAllWindows()        # 关闭所有窗口
```

OpenCV 广泛应用于人脸识别、自动驾驶、医学图像分析、工业检测等领域。

# 2. 初见OpenCV：
``` python
import cv2  
  
# 显式创建一个窗口, 窗口名为preview， 窗口大小根据内容自动调整  
cv2.namedWindow("preview", cv2.WINDOW_AUTOSIZE)  
# 读取图片为矩阵  
img = cv2.imread("./flower.png")  
# 在窗口中显示一张图片，没有显式创建窗口的话会自动创建一个窗口  
cv2.imshow("preview", img)  
# 调整窗口大小  
cv2.waitKey()  
cv2.resizeWindow("preview", 640, 480)  
# 等待输入  
while True:  
    key = cv2.waitKey()  # 可无参，可接收整数参数（等待毫秒数，0为无限期等待，相当于无参）  
    if chr(key) == 'q':  # 返回参数是ascii值，需要转换  
        exit()  
  
# 销毁窗口  
# cv2.destroyAllWindows()
```

------
# 3. 图片操作：
## （1）读取图片：

OpenCV使用`cv2.imread()`函数读取图片

`cv2.imread()` 函数的参数如下：
- **filename**：要加载的图像文件路径
  - 支持多种图像格式（JPEG, PNG, BMP, TIFF等）
  - 可以是相对路径或绝对路径

- **flags**（可选）：指定图像加载模式。常用值如下：
  - `cv2.IMREAD_COLOR`：默认值，加载彩色图像
  - `cv2.IMREAD_GRAYSCALE`：加载灰度图像
  - `cv2.IMREAD_UNCHANGED`：加载图像包括alpha通道

### a. **常用写法示例**：
```python
# 默认加载彩色图像
img = cv2.imread("./flower.png")

# 显式指定加载模式
img = cv2.imread("./flower.png", cv2.IMREAD_COLOR)
img = cv2.imread("./flower.png", cv2.IMREAD_GRAYSCALE)
```
### b. `flags`参数完整列表：
``` cpp
enum ImreadModes {
       IMREAD_UNCHANGED            = -1, //!< If set, return the loaded image as is (with alpha channel, otherwise it gets cropped). Ignore EXIF orientation.
       IMREAD_GRAYSCALE            = 0,  //!< If set, always convert image to the single channel grayscale image (codec internal conversion).
       IMREAD_COLOR_BGR            = 1,  //!< If set, always convert image to the 3 channel BGR color image.
       IMREAD_COLOR                = 1,  //!< Same as IMREAD_COLOR_BGR.
       IMREAD_ANYDEPTH             = 2,  //!< If set, return 16-bit/32-bit image when the input has the corresponding depth, otherwise convert it to 8-bit.
       IMREAD_ANYCOLOR             = 4,  //!< If set, the image is read in any possible color format.
       IMREAD_LOAD_GDAL            = 8,  //!< If set, use the gdal driver for loading the image.
       IMREAD_REDUCED_GRAYSCALE_2  = 16, //!< If set, always convert image to the single channel grayscale image and the image size reduced 1/2.
       IMREAD_REDUCED_COLOR_2      = 17, //!< If set, always convert image to the 3 channel BGR color image and the image size reduced 1/2.
       IMREAD_REDUCED_GRAYSCALE_4  = 32, //!< If set, always convert image to the single channel grayscale image and the image size reduced 1/4.
       IMREAD_REDUCED_COLOR_4      = 33, //!< If set, always convert image to the 3 channel BGR color image and the image size reduced 1/4.
       IMREAD_REDUCED_GRAYSCALE_8  = 64, //!< If set, always convert image to the single channel grayscale image and the image size reduced 1/8.
       IMREAD_REDUCED_COLOR_8      = 65, //!< If set, always convert image to the 3 channel BGR color image and the image size reduced 1/8.
       IMREAD_IGNORE_ORIENTATION   = 128, //!< If set, do not rotate the image according to EXIF's orientation flag.
       IMREAD_COLOR_RGB            = 256, //!< If set, always convert image to the 3 channel RGB color image.
     };

```
### c. `ImreadModes` 枚举翻译: 

`ImreadModes` 枚举定义了图像读取的各种模式：

1. `IMREAD_UNCHANGED` = -1
	- 如果设置，则按原样返回加载的图像（包含 alpha 通道，否则会被裁剪）。忽略 EXIF 方向。
2. `IMREAD_GRAYSCALE` = 0
	- 如果设置，总是将图像转换为单通道灰度图像（编解码器内部转换）。
3. `IMREAD_COLOR_BGR` = 1
	- 如果设置，总是将图像转换为 3 通道 BGR 彩色图像。
4. `IMREAD_COLOR` = 1
	- 与 `IMREAD_COLOR_BGR` 相同。
5. `IMREAD_ANYDEPTH` = 2
	- 如果设置，当输入具有相应深度时返回 16 位/32 位图像，否则转换为 8 位。
6. `IMREAD_ANYCOLOR` = 4
	- 如果设置，以任何可能的颜色格式读取图像。
7. `IMREAD_LOAD_GDAL` = 8
	- 如果设置，使用 gdal 驱动程序加载图像。
8. `IMREAD_REDUCED_GRAYSCALE_2` = 16
	- 如果设置，总是将图像转换为单通道灰度图像，并且图像尺寸缩小 1/2。
9. `IMREAD_REDUCED_COLOR_2` = 17
	- 如果设置，总是将图像转换为 3 通道 BGR 彩色图像，并且图像尺寸缩小 1/2。
10.  `IMREAD_REDUCED_GRAYSCALE_4` = 32
	- 如果设置，总是将图像转换为单通道灰度图像，并且图像尺寸缩小 1/4。
11.  `IMREAD_REDUCED_COLOR_4` = 33
	- 如果设置，总是将图像转换为 3 通道 BGR 彩色图像，并且图像尺寸缩小 1/4。
12. `IMREAD_REDUCED_GRAYSCALE_8` = 64
	- 如果设置，总是将图像转换为单通道灰度图像，并且图像尺寸缩小 1/8。
13.  `IMREAD_REDUCED_COLOR_8` = 65
	- 如果设置，总是将图像转换为 3 通道 BGR 彩色图像，并且图像尺寸缩小 1/8。
14.  `IMREAD_IGNORE_ORIENTATION` = 128
	- 如果设置，不根据 EXIF 的方向标志旋转图像。
15.  `IMREAD_COLOR_RGB` = 256
	- 如果设置，总是将图像转换为 3 通道 RGB 彩色图像。
## （2） 保存图片：

OpenCV使用`cv2.imread()`函数读取图片
### a. 参数列表如下：

- **filename**: 要保存的文件路径和名称
  - 支持多种图像格式（PNG, JPEG, BMP, TIFF等）
  - 可以是相对路径或绝对路径

- **img**: 要保存的图像数据（numpy数组格式）
  - 通常是通过 `cv2.imread()` 或其他OpenCV函数处理后的图像矩阵

- **params**（可选）: 保存参数列表
  - 用于指定特定格式的保存选项
  - 常见参数：
    - `cv2.IMWRITE_JPEG_QUALITY`: JPEG质量（0-100，默认95）
    - `cv2.IMWRITE_PNG_COMPRESSION`: PNG压缩级别（0-9，默认3）
- 注意：这里传入的参数是键+值组成的列表，而不是键值对或字典

### b. **基本用法示例**：
```python
# 基本保存
cv2.imwrite("./output.png", img)

# 指定JPEG质量
cv2.imwrite("./output.jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 90])
```
### c. `params`参数完整列表：
``` cpp
//! Imwrite flags
enum ImwriteFlags {
       IMWRITE_JPEG_QUALITY        = 1,  //!< For JPEG, it can be a quality from 0 to 100 (the higher is the better). Default value is 95.
       IMWRITE_JPEG_PROGRESSIVE    = 2,  //!< Enable JPEG features, 0 or 1, default is False.
       IMWRITE_JPEG_OPTIMIZE       = 3,  //!< Enable JPEG features, 0 or 1, default is False.
       IMWRITE_JPEG_RST_INTERVAL   = 4,  //!< JPEG restart interval, 0 - 65535, default is 0 - no restart.
       IMWRITE_JPEG_LUMA_QUALITY   = 5,  //!< Separate luma quality level, 0 - 100, default is -1 - don't use. If JPEG_LIB_VERSION < 70, Not supported.
       IMWRITE_JPEG_CHROMA_QUALITY = 6,  //!< Separate chroma quality level, 0 - 100, default is -1 - don't use. If JPEG_LIB_VERSION < 70, Not supported.
       IMWRITE_JPEG_SAMPLING_FACTOR = 7, //!< For JPEG, set sampling factor. See cv::ImwriteJPEGSamplingFactorParams.
       IMWRITE_PNG_COMPRESSION     = 16, //!< For PNG, it can be the compression level from 0 to 9. A higher value means a smaller size and longer compression time. If specified, strategy is changed to IMWRITE_PNG_STRATEGY_DEFAULT (Z_DEFAULT_STRATEGY). Default value is 1 (best speed setting).
       IMWRITE_PNG_STRATEGY        = 17, //!< For PNG, One of cv::ImwritePNGFlags, default is IMWRITE_PNG_STRATEGY_RLE.
       IMWRITE_PNG_BILEVEL         = 18, //!< For PNG, Binary level PNG, 0 or 1, default is 0. For APNG, it is not supported.
       IMWRITE_PNG_FILTER          = 19, //!< For PNG, One of cv::ImwritePNGFilterFlags, default is IMWRITE_PNG_FILTER_SUB. For APNG, it is not supported.
       IMWRITE_PNG_ZLIBBUFFER_SIZE = 20, //!< For PNG with libpng, sets the size of the internal zlib compression buffer in bytes, from 6 to 1048576(1024 KiB). Default is 8192(8 KiB). For normal use, 131072(128 KiB) or 262144(256 KiB) may be sufficient. If WITH_SPNG=ON, it is not supported. For APNG, it is not supported.
       IMWRITE_PXM_BINARY          = 32, //!< For PPM, PGM, or PBM, it can be a binary format flag, 0 or 1. Default value is 1.
       IMWRITE_EXR_TYPE            = (3 << 4) + 0 /* 48 */, //!< override EXR storage type (FLOAT (FP32) is default)
       IMWRITE_EXR_COMPRESSION     = (3 << 4) + 1 /* 49 */, //!< override EXR compression type (ZIP_COMPRESSION = 3 is default)
       IMWRITE_EXR_DWA_COMPRESSION_LEVEL = (3 << 4) + 2 /* 50 */, //!< override EXR DWA compression level (45 is default)
       IMWRITE_WEBP_QUALITY        = 64, //!< For WEBP, it can be a quality from 1 to 100 (the higher is the better). By default (without any parameter) and for quality above 100 the lossless compression is used.
       IMWRITE_HDR_COMPRESSION     = (5 << 4) + 0 /* 80 */, //!< specify HDR compression
       IMWRITE_PAM_TUPLETYPE       = 128,//!< For PAM, sets the TUPLETYPE field to the corresponding string value that is defined for the format
       IMWRITE_TIFF_RESUNIT        = 256,//!< For TIFF, use to specify which DPI resolution unit to set. See ImwriteTiffResolutionUnitFlags. Default is IMWRITE_TIFF_RESOLUTION_UNIT_INCH.
       IMWRITE_TIFF_XDPI           = 257,//!< For TIFF, use to specify the X direction DPI
       IMWRITE_TIFF_YDPI           = 258,//!< For TIFF, use to specify the Y direction DPI
       IMWRITE_TIFF_COMPRESSION    = 259,//!< For TIFF, use to specify the image compression scheme. See cv::ImwriteTiffCompressionFlags. Note, for images whose depth is CV_32F, only libtiff's SGILOG compression scheme is used. For other supported depths, the compression scheme can be specified by this flag; LZW compression is the default.
       IMWRITE_TIFF_ROWSPERSTRIP   = 278,//!< For TIFF, use to specify the number of rows per strip.
       IMWRITE_TIFF_PREDICTOR      = 317,//!< For TIFF, use to specify predictor. See cv::ImwriteTiffPredictorFlags. Default is IMWRITE_TIFF_PREDICTOR_HORIZONTAL .
       IMWRITE_JPEG2000_COMPRESSION_X1000 = 272,//!< For JPEG2000, use to specify the target compression rate (multiplied by 1000). The value can be from 0 to 1000. Default is 1000.
       IMWRITE_AVIF_QUALITY        = 512,//!< For AVIF, it can be a quality between 0 and 100 (the higher the better). Default is 95.
       IMWRITE_AVIF_DEPTH          = 513,//!< For AVIF, it can be 8, 10 or 12. If >8, it is stored/read as CV_32F. Default is 8.
       IMWRITE_AVIF_SPEED          = 514,//!< For AVIF, it is between 0 (slowest) and 10(fastest). Default is 9.
       IMWRITE_JPEGXL_QUALITY      = 640,//!< For JPEG XL, it can be a quality from 0 to 100 (the higher is the better). Default value is 95. If set, distance parameter is re-calicurated from quality level automatically. This parameter request libjxl v0.10 or later.
       IMWRITE_JPEGXL_EFFORT       = 641,//!< For JPEG XL, encoder effort/speed level without affecting decoding speed; it is between 1 (fastest) and 10 (slowest). Default is 7.
       IMWRITE_JPEGXL_DISTANCE     = 642,//!< For JPEG XL, distance level for lossy compression: target max butteraugli distance, lower = higher quality, 0 = lossless; range: 0 .. 25. Default is 1.
       IMWRITE_JPEGXL_DECODING_SPEED = 643,//!< For JPEG XL, decoding speed tier for the provided options; minimum is 0 (slowest to decode, best quality/density), and maximum is 4 (fastest to decode, at the cost of some quality/density). Default is 0.
       IMWRITE_BMP_COMPRESSION     = 768,  //!< For BMP, use to specify compress parameter for 32bpp image. Default is IMWRITE_BMP_COMPRESSION_BITFIELDS. See cv::ImwriteBMPCompressionFlags.
       IMWRITE_GIF_LOOP            = 1024, //!< Not functional since 4.12.0. Replaced by cv::Animation::loop_count.
       IMWRITE_GIF_SPEED           = 1025, //!< Not functional since 4.12.0. Replaced by cv::Animation::durations.
       IMWRITE_GIF_QUALITY         = 1026, //!< For GIF, it can be a quality from 1 to 8. Default is 2. See cv::ImwriteGifCompressionFlags.
       IMWRITE_GIF_DITHER          = 1027, //!< For GIF, it can be a quality from -1(most dither) to 3(no dither). Default is 0.
       IMWRITE_GIF_TRANSPARENCY    = 1028, //!< For GIF, the alpha channel lower than this will be set to transparent. Default is 1.
       IMWRITE_GIF_COLORTABLE      = 1029  //!< For GIF, 0 means global color table is used, 1 means local color table is used. Default is 0.
};
```
### d. `ImwriteFlags` 枚举翻译

#### JPEG 相关参数:
- `IMWRITE_JPEG_QUALITY` = 1
	- JPEG 质量，范围 0-100（数值越高质量越好）。默认值是 95。
- `IMWRITE_JPEG_PROGRESSIVE` = 2
	- 启用 JPEG 特性，0 或 1，默认是 False。
- `IMWRITE_JPEG_OPTIMIZE` = 3
	- 启用 JPEG 特性，0 或 1，默认是 False。
- `IMWRITE_JPEG_RST_INTERVAL` = 4
	- JPEG 重启间隔，0 - 65535，默认是 0（无重启）。
- `IMWRITE_JPEG_LUMA_QUALITY` = 5
	- 单独的亮度质量等级，0 - 100，默认是 -1（不使用）。如果 JPEG_LIB_VERSION < 70，则不支持。
- `IMWRITE_JPEG_CHROMA_QUALITY` = 6
	- 单独的色度质量等级，0 - 100，默认是 -1（不使用）。如果 JPEG_LIB_VERSION < 70，则不支持。
- `IMWRITE_JPEG_SAMPLING_FACTOR` = 7
	- JPEG 采样因子。参见 `cv::ImwriteJPEGSamplingFactorParams`。

#### PNG 相关参数:
- `IMWRITE_PNG_COMPRESSION` = 16
	- PNG 压缩级别，范围 0-9。数值越高文件越小但压缩时间越长。如果指定，策略会改为 `IMWRITE_PNG_STRATEGY_DEFAULT` (Z_DEFAULT_STRATEGY)。默认值是 1（最佳速度设置）。
- `IMWRITE_PNG_STRATEGY` = 17
	- PNG 策略之一，参见 `cv::ImwritePNGFlags`，默认是 `IMWRITE_PNG_STRATEGY_RLE`。
- `IMWRITE_PNG_BILEVEL` = 18
	- PNG 二值级别，0 或 1，默认是 0。对于 APNG 不支持。
- `IMWRITE_PNG_FILTER` = 19
	- PNG 过滤器之一，参见 `cv::ImwritePNGFilterFlags`，默认是 `IMWRITE_PNG_FILTER_SUB`。对于 APNG 不支持。
- `IMWRITE_PNG_ZLIBBUFFER_SIZE` = 20
	- 使用 libpng 时，设置内部 zlib 压缩缓冲区大小（字节），范围 6-1048576(1024 KiB)。默认是 8192(8 KiB)。正常使用时，131072(128 KiB) 或 262144(256 KiB) 可能足够。如果 WITH_SPNG=ON 则不支持。对于 APNG 不支持。

#### 其他格式参数:
- `IMWRITE_PXM_BINARY` = 32
	- PPM、PGM 或 PBM 的二进制格式标志，0 或 1。默认值是 1。
- `IMWRITE_WEBP_QUALITY` = 64
	- WEBP 质量，范围 1-100（数值越高质量越好）。默认情况下（无参数）且质量高于 100 时使用无损压缩。
- `IMWRITE_PAM_TUPLETYPE` = 128
	- PAM 格式，设置 TUPLETYPE 字段为相应的字符串值。

#### TIFF 相关参数:
- `IMWRITE_TIFF_RESUNIT` = 256
	- TIFF 分辨率单位。参见 `ImwriteTiffResolutionUnitFlags`。默认是 `IMWRITE_TIFF_RESOLUTION_UNIT_INCH`。
- `IMWRITE_TIFF_XDPI` = 257
	- TIFF X 方向 DPI。
- `IMWRITE_TIFF_YDPI` = 258
	- TIFF Y 方向 DPI。
- `IMWRITE_TIFF_COMPRESSION` = 259
	- TIFF 图像压缩方案。参见 `cv::ImwriteTiffCompressionFlags`。
- `IMWRITE_TIFF_ROWSPERSTRIP` = 278
	- TIFF 每条带的行数。
- `IMWRITE_TIFF_PREDICTOR` = 317
	- TIFF 预测器。参见 `cv::ImwriteTiffPredictorFlags`。默认是 `IMWRITE_TIFF_PREDICTOR_HORIZONTAL`。

#### 其他格式参数（续）:
- `IMWRITE_JPEG2000_COMPRESSION_X1000` = 272
	- JPEG2000 目标压缩率（乘以 1000）。范围 0-1000。默认是 1000。
- `IMWRITE_AVIF_QUALITY` = 512
	- AVIF 质量，范围 0-100（数值越高质量越好）。默认是 95。
- `IMWRITE_AVIF_DEPTH` = 513
	- AVIF 位深，可选 8、10 或 12。如果 >8，则以 `CV_32F` 格式存储/读取。默认是 8。
- `IMWRITE_AVIF_SPEED` = 514
	- AVIF 编码速度，范围 0（最慢）-10（最快）。默认是 9。

#### GIF 相关参数:
- `IMWRITE_GIF_QUALITY` = 1026
	- GIF 质量，范围 1-8。默认是 2。参见 `cv::ImwriteGifCompressionFlags`。
- `IMWRITE_GIF_DITHER` = 1027
	- GIF 抖动质量，范围 -1（最多抖动）到 3（无抖动）。默认是 0。
- `IMWRITE_GIF_TRANSPARENCY` = 1028
	- GIF 透明度阈值，低于此值的 alpha 通道将被设为透明。默认是 1。
- `IMWRITE_GIF_COLORTABLE` = 1029
	- GIF 颜色表，0 表示使用全局颜色表，1 表示使用局部颜色表。默认是 0。
## （3）代码示例：
``` python
import cv2  
  
# 创建窗口  
cv2.namedWindow("preview", cv2.WINDOW_AUTOSIZE)  
# 加载图片  
img = cv2.imread("./flower.png", cv2.IMREAD_GRAYSCALE)  # 显示灰度图
# 显示图片  
cv2.imshow("preview", img)  

cv2.waitKey()

# 保存图片  
cv2.imwrite("./flower_save.png", img)
```

------

# 4. 视频采集：
## （1）常用方法：

### 1. 创建视频捕获对象
- `cv2.VideoCapture()`: 创建视频捕获对象
  - 参数可以是设备索引（如 0 表示默认摄像头）或视频文件路径
### 2. 读取视频帧
- `cap.read()`: 从视频流中读取一帧
  - 返回值：`(ret, frame)` 
  - `ret`: 布尔值，表示是否成功读取帧
  - `frame`: 实际的图像数据（numpy数组）
### 3. 设置和获取视频属性
- `cap.set(propId, value)`: 设置视频属性
- `cap.get(propId)`: 获取视频属性
- 常用属性：
	- `cv2.CAP_PROP_FRAME_WIDTH`: 帧宽度
	- `cv2.CAP_PROP_FRAME_HEIGHT`: 帧高度
	- `cv2.CAP_PROP_FPS`: 帧率
	- `cv2.CAP_PROP_FRAME_COUNT`: 总帧数
### 4. 释放资源
- `cap.release()`: 释放视频捕获对象
- `cv2.destroyAllWindows()`: 关闭所有OpenCV窗口
## （2）基本使用示例：
```python
import cv2

# 打开默认摄像头
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    cv2.imshow('video', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

# 5. 读取视频
## （1）常用方法

### 1. 视频捕获初始化
- `cv2.VideoCapture()` - 创建视频捕获对象
	- 参数可以是视频文件路径（如 `"./vtest.avi"`）
	- 也可以是摄像头索引（如 `0` 表示默认摄像头）
### 2. 视频属性获取方法
- `cap.get(cv2.CAP_PROP_FPS)` - 获取视频帧率
- `cap.get(cv2.CAP_PROP_FRAME_WIDTH)` - 获取帧宽度
- `cap.get(cv2.CAP_PROP_FRAME_HEIGHT)` - 获取帧高度
- `cap.get(cv2.CAP_PROP_FRAME_COUNT)` - 获取总帧数
### 3. 视频读取核心方法
- `cap.read()` - 读取下一帧
  - 返回值：`(ret, frame)`
  - `ret`：布尔值，表示是否成功读取帧
  - `frame`：实际的图像帧数据
### 4. 视频播放控制方法
- `cv2.waitKey()` - 等待按键输入，控制播放速度
- `cv2.imshow()` - 显示视频帧
- `cv2.destroyAllWindows()` - 关闭所有显示窗口
### 5. 资源释放方法
- `cap.release()` - 释放视频捕获资源
## (2) 代码示例：
``` python
import cv2  
  
# 创建窗口  
cv2.namedWindow('video', cv2.WINDOW_AUTOSIZE)  
  
# 获取视频设备(视频和摄像头都认为是视频设备)  
cap = cv2.VideoCapture("./vtest.avi")  
  
# 获取视频的帧率  
fps = cap.get(cv2.CAP_PROP_FPS)  
wait_time = int(1000 / fps)  
  
while True:  
    ret, frame = cap.read()  
    if not ret:  
        break  
  
    cv2.imshow('video', frame)  
  
    if cv2.waitKey(wait_time) & 0xFF == ord('q'):  
        break  
  
# 释放资源  
cap.release()  
cv2.destroyAllWindows()
```
------
# 6. 录制视频
## （1）常用方法
## OpenCV录制视频的常用方法

### 1. 视频写入初始化
- `cv2.VideoWriter()` - 创建视频写入对象
  - 参数包括：输出文件名、编解码器、帧率、帧大小等
### 2. 视频写入核心方法
- `out.write(frame)` - 写入视频帧
  - `frame`：要写入的图像帧
### 3. 编解码器设置
- 常用编解码器：
	- `cv2.VideoWriter_fourcc(*'XVID')` - XVID编码
	- `cv2.VideoWriter_fourcc(*'MP4V')` - MP4编码
	- `cv2.VideoWriter_fourcc(*'MJPG')` - Motion JPEG编码
### 4. 视频写入属性设置
- 帧率设置：与 `VideoWriter` 初始化时指定的帧率一致
- 分辨率设置：通过 [(width, height)](file://D:\Desktop\Coding\Python\OpenCV_Learning\opencv-master源码\opencv-master\opencv\特征匹配\img_stitch.py#L106-L106) 元组指定
### 5. 资源管理
- `out.release('output.avi', fourcc, 20.0, (640,480))` 
	- 将缓冲区内现有的所有数据流写入视频文件，结束视频写入，释放视频写入资源。
	- 参数为视频名，文件格式，帧率及分辨率
- 通常配合 `cap.release()` 一起使用（当同时读取和写入时）

典型的录制视频流程是打开摄像头捕获帧，然后使用 `VideoWriter` 将帧逐个写入到文件中。

## （2）代码示例
``` python
import cv2  
  
# 创建视频设备、fourcc和视频写入对象  
cap = cv2.VideoCapture(0, cv2.CAP_ANY)  
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)  
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)  
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))  
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))  
fourcc = cv2.VideoWriter.fourcc(*'mp4v')  
out = cv2.VideoWriter('output.mp4', fourcc, 25.0, (width, height))  
  
# VideoWriter的参数只是设置的视频的元数据，并不是实际视频的数据  
target_fps = 25  
wait_time = int(1000 / target_fps)  # 40ms for 25fps  
  
# 写入视频  
while True:  
    ret, frame = cap.read()  
    if not ret:  
        break  
    print(f"width:{width}, height:{height}")  
  
    # 裁剪(NumPy的数组切片)  
    # height, width = frame.shape[:2]  
    # start_x = (width - 640) // 2    # start_y = (height - 480) // 2    # cropped_frame = frame[start_y:start_y + 480, start_x:start_x + 640]
      
    # 改变比例  
    # frame_resized = cv2.resize(frame, (640, 480))  
  
    cv2.imshow('video', frame)  
    out.write(frame)  # 写入视频  
  
    if cv2.waitKey(wait_time) & 0xFF == ord('q'):  
        break  
  
cap.release()  
out.release()  
cv2.destroyAllWindows()
```

## （3）问题

- Pycharm的自动补全里没有VideoWriter_fourcc()这个方法，其对应的是VideoWriter.fourcc()。
- `VideoWriter.write(frame)`方法对帧尺寸有严格要求，读取到的帧大小必须与`VideoWriter`初始化时给定的帧大小严格相等，差一点都会报错
	- 解决方法分两种，一种是调整摄像头分辨率，比如创建好摄像头之后直接使用`cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)`和`cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)`调整摄像头分辨率
	- 另一种是裁剪获取到的帧，这里需要使用NumPy的数组切片操作，从帧元素中裁剪。代码如下：
``` python
height, width = frame.shape[:2]  
start_x = (width - 640) // 2  
start_y = (height - 480) // 2  
cropped_frame = frame[start_y:start_y + 480, start_x:start_x + 640]
```
------
# 7. 鼠标操作
## （1）机制介绍：

### 1. 操作方式
- OpenCV的鼠标操作是**被动监听**方式，不是模拟点击
- 通过 `cv2.setMouseCallback` 注册回调函数来响应鼠标事件
- 不影响系统鼠标的正常运作
### 2. 工作原理
- OpenCV创建窗口时会注册系统级鼠标事件监听器
- 当用户在OpenCV窗口内进行鼠标操作时，系统将事件传递给OpenCV
- OpenCV再调用用户定义的回调函数处理事件
### 3. 对系统的影响
- ✅ **不影响系统鼠标**：系统鼠标可以正常使用
- ✅ **独立事件处理**：只监听OpenCV窗口内的鼠标事件
- ✅ **无冲突**：与其他应用程序的鼠标操作互不干扰

因此，OpenCV鼠标操作是安全的事件监听机制，不会干扰系统正常鼠标功能。

## （2）常用方法

### 1. 核心组件
- `cv2.setMouseCallback()` - 设置鼠标回调函数
- 鼠标事件处理函数 - 自定义处理鼠标动作
### 2. 鼠标事件类型
- `cv2.EVENT_LBUTTONDOWN` - 左键按下
- `cv2.EVENT_LBUTTONUP` - 左键释放
- `cv2.EVENT_RBUTTONDOWN` - 右键按下
- `cv2.EVENT_MOUSEMOVE` - 鼠标移动
- `cv2.EVENT_LBUTTONDBLCLK` - 左键双击
### 3. 回调函数格式
```python
# 这是自定义的鼠标事件处理函数，需要5个参数
def mouse_callback(event, x, y, flags, param):
    # event: 鼠标事件类型
    # x, y: 鼠标坐标
    # flags: 鼠标状态标志
    # param: 传递的额外参数
    pass

cv2.setMouseCallback('window_name', mouse_callback)
```
### 4. 常用flags标志
- `cv2.EVENT_FLAG_LBUTTON` - 左键被按下
- `cv2.EVENT_FLAG_CTRLKEY` - Ctrl键被按下
- `cv2.EVENT_FLAG_SHIFTKEY` - Shift键被按下
### 5. 典型应用场景
- 图像标注和绘图
- ROI(感兴趣区域)选择
- 坐标点获取
- 交互式图像处理

使用时需要先创建窗口，然后绑定鼠标回调函数来处理各种鼠标事件。
## （3）示例代码
``` python
import cv2  
  
# 鼠标事件回调函数  
def mouse_callback(event, x, y, flags, param):  
    if event == cv2.EVENT_LBUTTONDOWN:  
        print('LBUTTONDOWN','x:', x, 'y:', y)  
    elif event == cv2.EVENT_LBUTTONUP:  
        print('LBUTTONUP','x:', x, 'y:', y)  
    elif event == cv2.EVENT_MOUSEMOVE:  
        print('MOUSEMOVE','x:', x, 'y:', y)  
  
cv2.namedWindow('mouse', cv2.WINDOW_AUTOSIZE)  
cv2.resizeWindow('mouse', 640, 480)  
img = cv2.imread('./flower.png')  
# 为窗口绑定鼠标事件的回调函数  
cv2.setMouseCallback('mouse', mouse_callback)  
# 函数隐式向回调函数中传入鼠标状态flags，无需手动设置；回调函数的自定义参数param需要显式传入  
cv2.setMouseCallback('mouse', mouse_callback, param=None)  
  
while True:  
    cv2.imshow('mouse', img)  
    if cv2.waitKey(1) & 0xFF == ord('q'):  
        break  
    # 检测窗口是否被关闭  
    if cv2.getWindowProperty('mouse', cv2.WND_PROP_VISIBLE) < 1:  
        break  
  
cv2.destroyAllWindows()
```
------
# 8. TrackBar

## （1） 基本概念
- `cv2.createTrackbar`：创建滑动条控件
- 用于在OpenCV窗口中添加交互式调节控件
- 可以实时调整参数值并观察效果
## （2）主要函数
#### a. 创建Trackbar
```python
cv2.createTrackbar(trackbar_name, window_name, value, count, onChange)
```
- `trackbar_name`：滑动条名称
- `window_name`：所属窗口名称
- `value`：初始值
- `count`：最大值
- `onChange`：回调函数
#### b. 获取Trackbar值
```python
cv2.getTrackbarPos(trackbar_name, window_name)
```
#### c. 设置Trackbar值
```python
cv2.setTrackbarPos(trackbar_name, window_name, value)
```
### 3. 回调函数格式
```python
def on_trackbar(val):
    # val: 当前滑动条的值
    pass
```
### 4. 典型应用场景
- 图像处理参数调节（亮度、对比度等）
- 阈值分割参数调整
- 滤波器参数控制
- 实时效果预览
## （3）代码示例——通过滑块修改背景的RGB值：
``` python
import cv2  
import numpy as np  
  
def trackbar_callback(pos):  
    print(pos)  
  
cv2.namedWindow('pic', cv2.WINDOW_AUTOSIZE)  
  
cv2.createTrackbar('R', 'pic', 0, 255, trackbar_callback)  
cv2.createTrackbar('G', 'pic', 0, 255, trackbar_callback)  
cv2.createTrackbar('B', 'pic', 0, 255, trackbar_callback)  
  
img = np.zeros((480, 640, 3), np.uint8)  
  
while True:  
    # 通过TrackBar控制背景图片颜色  
    r = cv2.getTrackbarPos('R', 'pic')  
    g = cv2.getTrackbarPos('G', 'pic')  
    b = cv2.getTrackbarPos('B', 'pic')  
    img[:] = [b, g, r]  # opencv的像素颜色存储顺序为BGR
  
    cv2.imshow('pic', img)  
  
    if cv2.waitKey(10) & 0xFF == ord('q'):  
        break  
    if cv2.getWindowProperty('pic', cv2.WND_PROP_VISIBLE) < 1:  
        break  
  
  
cv2.destroyAllWindows()
```
