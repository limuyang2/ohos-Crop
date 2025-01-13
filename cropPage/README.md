# ohos-Crop
OpenHarmony Image crop（鸿蒙图片裁剪库）

# CropPage
⚠️**仅适用 Stage 模式**
⚠️重要：CropPage 库，页面里面包含了基本的裁剪功能，方便你快速使用，**如果你需要完全自由且个性化的页面样式，请使用 CropView 库，自行实现页面**。

## 安装
```
ohpm install @mumu/crop_page
```

## 特点
- 高斯模糊
- 简单快捷
- 支持深色模式（暗黑模式）

## 功能介绍
- 矩形裁剪
- 图片旋转
- 左右翻转
- 上下翻转
- 亮度（规划中，待实现）
- 灰度
- 色相（规划中，待实现）

## 预览
![gif](https://img.picgo.net/2025/01/11/preview13411380f796a56a.gif)
[预览](https://img.picgo.net/2025/01/11/preview13411380f796a56a.gif)

## 使用方法
```ts
    // 拉起图片裁剪页面
    this.pathStack.pushPath({
      name: 'crop://image_crop_page', param: Crop.pageConfig({
        src: pickPath,
        isSupportDark: true
      }),
      onPop: (popInfo) => {
        let cropPath = popInfo.result as string
        // cropPath 为最终图片文件的路径
      }
    })
```
## 方法及参数说明
### CropPageConfig 配置参数
| 参数 | 说明 | 备注 |
|:----|:----| :----|
| src | 图片路径 | 必选 |
| quality | 裁剪质量 | 取值范围[1-100] |
| title | 标题 | 可选 |
| isSupportDark | 是否支持深色模式（暗黑模式） | 默认不开启 |




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
