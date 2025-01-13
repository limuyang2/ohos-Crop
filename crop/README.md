# ohos-Crop
OpenHarmony Image crop（鸿蒙图片裁剪库）

# CropView
⚠️重要：此为图片裁剪的核心组件，**不包含页面！如果你不想自己实现页面，可以使用 [CropPage](https://ohpm.openharmony.cn/#/cn/detail/@mumu%2Fcrop_page) 库，里面包含了基本的裁剪功能，方便你快速使用**。
🔔 同时，依然建议你使用本库的 `CropView` 组件实现自己的页面，更符合你的样式要求。

## 安装
```
ohpm install @mumu/crop
```

## 特点
- 小巧简单，适用于普通业务的图片裁剪，非专业性的裁剪。如有图片专业性处理的需求，请需求其他开源库。
- 代码规范
- 注释规范
- 越界回弹动画
- 使用简便，支持配置及数据的响应式更改（支持UI颜色配置的变化，例如进入暗黑模式）
- 遵循鸿蒙系统设计规则，使用 controller 设计方式

## 功能介绍
- 矩形裁剪
- 图片旋转
- 左右翻转
- 上下翻转
- 亮度
- 灰度
- 色相（规划中，待实现）

## 预览
![gif](https://gitee.com/limuyang2/ohos-crop/raw/master/preview.gif)

## 使用方法
```ts
// 定义控制器
private controller: CropController = new CropController()

// 创建裁剪view，并设置参数
CropView({
  src: this.src,
  controller: this.controller, // 控制器必须设置
  maskColor: getContext().resourceManager.getColorSync($r('app.color.crop_page_mask_dark')),
  frameWidth: 220,
  frameHeight: 220,
})
.width("100%")
.height("100%")

// 使用 controller 改变图片样式
this.controller.rotate() // 旋转
this.controller.horizontalFlip() // 水平翻转


// 获取裁剪图片
Button()
.onClick(() => {
  //使用 controller 获取裁剪图片
  this.controller.cropWithPath({ format: 'image/png', quality: 90 })
    .then((path) => {
      // path 为裁剪后的文件路径
    })
}
```
## 方法及参数说明
### `CropView` 配置参数
| 参数 | 说明 | 备注 |
|:----|:----| :----|
| controller | 控制器 | 必选 |
| clipOut | 超出控件边缘是否裁剪（一般用来做UI视觉效果） |  |
| src | 图片路径/位图 | 必选 |
| maskColor | 遮罩颜色 |  |
| frameWidth | 取景框宽度(单位vp) |  |
| frameHeight | 取景框高度(单位vp) |  |
| frameRatio | 取景框宽高比（如果设置了比例，优先使用比例） |  |
| frameStrokeColor | 取景框边框颜色 |  |
| frameStrokeWidth | 取景框边框宽度（单位vp） |  |
| panEnabled | 是否可以拖动 |  |
| zoomEnabled | 是否可以缩放 |  |
| defaultZoomScale | 默认缩放比例（1为默认值，如果无法铺满，会自动重新计算缩放值） |  |
| doubleClickZoomScale | 双击放大比例 |  |
| angle | 默认旋转角度 |  |
| onLoadError | 图片资源加载错误的回掉 |  |

### CropController 控制器方法
| 方法 | 参数 | 说明 | 备注 |
|:----|:----|:----|:----|
| rotate() | number: 需要旋转的度数 | 旋转图片 | 参数可选，不传递默认90度 |
| rotateTo() | number: 目标度数 | 旋转图片到第几度 | |
| flip() | boolean: 水平方向,  boolean: 垂直方向 | 翻转图片 | |
| horizontalFlip() | | 水平翻转 | |
| verticalFlip() | | 垂直翻转 | |
| isHorizontalFlip() | | 是否水平翻转 | |
| isVerticalFlip() | | 是否垂直翻转 | |
| scale | | 缩放 | |
| blur() | number: 模糊半径 | 高斯模糊 | |
| bright() | number: 高亮度 | 高亮度 | 数值区间[0, 1] |
| grayscale() | boolean: 是否设置灰度 | 灰度 | |
| isGrayscale() |  | 获取灰度状态 | |
| crop() |  | 获取裁剪的图片位图 | 异步返回位图 |
| cropWithPath() | option: 文件编码格式、压缩大小的配置 | 获取裁剪的图片文件路径 | 异步返回为文件路径 |

_**小 Tips：`CropController` 里面包含了基本的图片处理，你也可以单独在其他地方使用哦**_


# License
MIT License

Copyright (c) 2025 limuyang

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
