# ohos-Crop
OpenHarmony Image crop（鸿蒙图片裁剪库）

# CropView
⚠️重要：此为图片裁剪的核心组件，**不包含页面！如果你不想自己实现页面，可以使用 [CropPage](https://gitee.com/limuyang2/ohos-crop/tree/master/cropPage) 库，里面包含了基本的裁剪功能，方便你快速使用**。
🔔 同时，依然建议你使用本库的 `CropView` 组件实现自己的页面，更符合你的样式要求。

## 安装
仓库地址：
- [crop](https://ohpm.openharmony.cn/#/cn/detail/@mumu%2Fcrop)
- [cropPage](https://ohpm.openharmony.cn/#/cn/detail/@mumu%2Fcrop_page)

## 特点
- 小巧简单，适用于普通业务的图片裁剪，非专业性的裁剪。如有图片专业性处理的需求，请寻求其他开源库。
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
[CropView](https://gitee.com/limuyang2/ohos-crop/blob/master/crop/README.md)
[CropPage](https://gitee.com/limuyang2/ohos-crop/blob/master/cropPage/README.md)

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
