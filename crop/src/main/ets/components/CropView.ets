import Matrix4 from '@ohos.matrix4';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { fileIo } from '@kit.CoreFileKit';
import { curves } from '@kit.ArkUI';
import effectKit from '@ohos.effectKit';

/**
 * 图片裁剪组件
 */
@Preview
@ComponentV2
export struct CropView {
  /**
   * 控制器，只能设置一次
   */
  @Require @Once @Param controller: CropController = new CropController()
  @Param clipOut: boolean = true
  /**
   * 图片路径/位图
   */
  @Require @Param src: string | PixelMap = ''
  /**
   * 遮罩颜色，默认70%透明度的黑色
   */
  @Param maskColor: string | number | CanvasGradient | CanvasPattern = '#b3000000'
  /**
   * 取景框宽度(单位vp)，默认值220
   */
  @Param frameWidth: number = 220
  /**
   * 取景框高度(单位vp)
   */
  @Param frameHeight: number = this.frameWidth
  /**
   * 取景框宽高比（如果设置了比例，优先使用比例）
   */
  @Param frameRatio?: number = undefined
  /**
   * 取景框边框颜色，默认70%透明度的白色
   */
  @Param frameStrokeColor: ResourceColor = '#b3ffffff'
  /**
   * 取景框边框宽度（单位vp），默认值1
   */
  @Param frameStrokeWidth: number = 1
  /**
   * 是否可以拖动，默认为true
   */
  @Param panEnabled: boolean = true
  /**
   * 是否可以缩放，默认为true
   */
  @Param zoomEnabled: boolean = true
  /**
   * 默认缩放比例（1为默认值，如果无法铺满，会自动重新计算缩放值）
   */
  @Param defaultZoomScale: number = 1
  /**
   * 双击放大比例，默认2倍
   */
  @Param doubleClickZoomScale: number = 2
  /**
   * 旋转角度（默认为0，不旋转）
   */
  @Param angle: number = 0
  /**
   * 图片资源加载错误的回掉
   */
  @Param onLoadError?: ImageErrorCallback = undefined
  //=================================================================================================================
  @Local private animateParam?: AnimateParam = undefined
  // Canvas配置
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  /** 临时变量 **/
  private tempScale: number = 1
  private startOffsetX: number = 0
  private startOffsetY: number = 0
  private minZoomScale: number = 1

  @Monitor('src')
  onSrcChange() {
    this.controller.init(this.src, this.angle, this.defaultZoomScale)
    this.checkImageAdapt()
  }

  @Monitor('maskColor')
  onAngleChange() {
    this.canvasDraw()
  }

  @Monitor('frameWidth', 'frameHeight', 'frameRatio')
  onFrameChange() {
    // 取景框数据变换，需要重新绘制取景框，并且重新矫正图片显示
    this.canvasDraw()
    this.controller.changeFrameSize(vp2px(this.frameWidth), vp2px(this.realFrameHeight))
  }

  aboutToAppear(): void {
    this.controller.init(this.src, this.angle, this.defaultZoomScale)
    this.controller.changeFrameSize(vp2px(this.frameWidth), vp2px(this.realFrameHeight))
  }

  aboutToDisappear(): void {
    this.controller.srcPixelMap?.release()
  }

  private canvasDraw() {
    let height = this.context.height
    let width = this.context.width

    // 清理画布内容
    this.context.globalCompositeOperation = 'source-over'
    this.context.clearRect(0, 0, width, height)


    this.context.fillStyle = this.maskColor
    this.context.fillRect(0, 0, width, height)

    // 把中间的取景框透出来
    this.context.globalCompositeOperation = 'destination-out'
    this.context.fillStyle = Color.White
    let frameWidth = this.frameWidth
    let frameHeight = this.realFrameHeight
    let x = (width - frameWidth) / 2
    let y = (height - frameHeight) / 2

    // 矩形
    this.context.fillRect(x, y, frameWidth, frameHeight)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.controller.srcPixelMap)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .transform(this.controller.matrix)
        .animation(this.animateParam)
        .transition(TransitionEffect.OPACITY.animation({ curve: curves.springMotion(0.25, 0.8) }))
        .onComplete((msg) => {
          if (msg && msg.loadingStatus == 1) { // 图片加载成功
            this.controller.changeImageSize(msg.width, msg.height)
            this.minZoomScale = this.controller.zoomScale
          }
        })
        .onError((err) => {
          this.onLoadError?.(err)
        })
        .onAreaChange((_, n) => {
          if (typeof n.width === "number" && typeof n.height === "number") {
            this.controller.changeViewSize(vp2px(n.width as number), vp2px(n.height as number))
            this.minZoomScale = this.controller.zoomScale
          }

        })


      Canvas(this.context)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .enabled(false)
        .onReady(() => {
          this.canvasDraw()
        })

      // 边框
      Rect()
        .fillOpacity(0)
        .borderWidth(this.frameStrokeWidth)
        .borderColor(this.frameStrokeColor)
        .width(this.frameWidth)
        .height(this.realFrameHeight)
    }
    .clip(this.clipOut)
    .width('100%')
    .height('100%')
    .priorityGesture(
      // 双击放大
      TapGesture({ count: 2, fingers: 1 })
        .onAction((event: GestureEvent) => {
          if (!event) {
            return
          }
          if (this.zoomEnabled) {
            this.addAnimate()
            if (this.controller.zoomScale != this.minZoomScale) {
              // 恢复尺寸
              this.controller.offsetX = 0
              this.controller.offsetY = 0
              this.controller.scale = this.minZoomScale
            } else {
              this.controller.scale = this.doubleClickZoomScale * this.minZoomScale
            }
          }
        })
    )
    .gesture(
      GestureGroup(GestureMode.Parallel,
        // 拖动手势
        PanGesture({ fingers: 1 })
          .onActionStart(() => {
            this.clearAnimate()

            this.startOffsetX = this.controller.offsetX
            this.startOffsetY = this.controller.offsetY
          })
          .onActionUpdate((event: GestureEvent) => {
            if (event) {
              if (this.panEnabled) {
                let distanceX: number = this.startOffsetX + vp2px(event.offsetX) / this.controller.zoomScale
                let distanceY: number = this.startOffsetY + vp2px(event.offsetY) / this.controller.zoomScale
                this.controller.offsetX = distanceX
                this.controller.offsetY = distanceY
                this.controller.updateMatrix()
              }
            }
          })
          .onActionEnd(() => {
            this.addAnimate()
            this.checkImageAdapt()
          }),

        // 缩放手势处理
        PinchGesture({ fingers: 2 })
          .onActionStart(() => {
            this.clearAnimate()
            this.tempScale = this.controller.zoomScale
          })
          .onActionUpdate((event) => {
            if (event) {
              if (!this.zoomEnabled) {
                return
              }
              this.controller.scale = this.tempScale * event.scale
            }
          })
          .onActionEnd(() => {
            this.addAnimate()
            this.checkImageAdapt()
          })
      )
    )
  }

  private checkImageAdapt() {
    this.controller.checkImageAdapt()
    this.controller.updateMatrix()
  }

  private addAnimate() {
    if (this.animateParam !== undefined) {
      return
    }
    this.animateParam = {
      duration: 300,
      curve: Curve.Ease,
      iterations: 1,
      playMode: PlayMode.Normal
    }
  }

  private clearAnimate() {
    this.animateParam = undefined
  }

  private get realFrameHeight(): number {
    if (this.frameRatio) {
      // 优先使用比例
      return this.frameWidth / this.frameRatio
    } else {
      return this.frameHeight
    }
  }
}


@ObservedV2
export class CropController {
  private _src: string | PixelMap = ''
  /**
   * 位图
   */
  @Trace srcPixelMap?: PixelMap = undefined
  /**
   * Image变换矩阵
   */
  @Trace matrix: Matrix4.Matrix4Transit = Matrix4.identity()
    .translate({ x: 0, y: 0 })
    .scale({ x: 1, y: 1 }) //这里不能使用 矩阵的 rotate，因为会导致移动图片的x/y值难以计算

  /**
   * 取景框宽度(单位px)
   */
  private _frameWidthPx: number = 0
  /**
   * 取景框高度(单位px)
   */
  private _frameHeightPx: number = 0
  /**
   * 图片宽/高
   */
  private _imageWidth: number = 0
  private _imageHeight: number = 0
  /**
   * image控件宽/高
   */
  private _viewWidth: number = 0
  private _viewHeight: number = 0
  /**
   * x轴方向偏移量
   */
  offsetX: number = 0
  /**
   * y轴方向偏移量
   */
  offsetY: number = 0
  /**
   * 缩放比例
   * 图片经过了两重缩放，一是适配控件的时候进行了缩放，二是手势操作的时候进行了缩放
   */
  private _zoomScale: number = 1
  /**
   * 是否有水平翻转
   */
  private _horizontalFlip: boolean = false
  /**
   * 是否有垂直翻转
   */
  private _verticalFlip: boolean = false
  /**
   * 记录当前已模糊的半径
   */
  private _blurRadius: number = 0
  /**
   * 记录高亮度
   */
  private _bright: number = 0
  /**
   * 记录灰度
   */
  private _grayscale: boolean = false
  /**
   * 记录当前已旋转的角度
   */
  private _angle: number = 0
  private totalScale: number = 0
  private cutX: number = 0
  private cutY: number = 0

  init(src: string | PixelMap, angle: number, defaultZoomScale: number) {
    this._src = src
    this._zoomScale = defaultZoomScale
    this._angle = this.calculateTotalAngle(angle)

    this.reloadSrc().then((pm) => {
      if (this._angle > 0) {
        pm.rotate(this._angle)
      }
      this.srcPixelMap = pm
    })
  }

  private reloadSrc() {
    if (typeof this._src === 'string') {
      return fs.open(this._src, fs.OpenMode.READ_ONLY)
        .then((file) => {
          let imageSource: image.ImageSource = image.createImageSource(file.fd)
          let decodingOptions: image.DecodingOptions = {
            editable: true,
            desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
          }
          // 创建pixelMap
          return imageSource.createPixelMapSync(decodingOptions)
        })
    } else {
      return Promise.resolve(this._src)
    }
  }

  /**
   * 图片大小
   * @param w 单位px
   * @param h 单位px
   */
  changeImageSize(w: number, h: number) {
    this._imageWidth = w
    this._imageHeight = h
    this.checkImageAdapt()
    this.updateMatrix()
  }

  /**
   * 显示图片的控件尺寸
   * @param w 单位px
   * @param h 单位px
   */
  changeViewSize(w: number, h: number) {
    this._viewWidth = w
    this._viewHeight = h
    this.checkImageAdapt()
    this.updateMatrix()
  }

  /**
   * 取景框大小
   * @param w 单位px
   * @param h 单位px
   */
  changeFrameSize(w: number, h: number) {
    this._frameWidthPx = w
    this._frameHeightPx = h

    if (this._viewWidth == 0 || this._viewHeight == 0) {
      return
    }
    this.checkImageAdapt()
    this.updateMatrix()
  }

  /**
   * 检查手势操作后，图片是否填满取景框，没填满则进行调整
   */
  checkImageAdapt() {
    let offsetX = this.offsetX
    let offsetY = this.offsetY
    let scale = this.zoomScale
    console.info("CropView", `offsetX: ${offsetX}, offsetY: ${offsetY}, scale: ${scale}`)

    if (this._viewWidth == 0 || this._viewHeight == 0) {
      return
    }
    if (this._imageWidth == 0 || this._imageHeight == 0) {
      return
    }
    // 图片适配控件的时候也进行了缩放，计算出这个缩放比例
    let widthScale = this._viewWidth / this._imageWidth
    let heightScale = this._viewHeight / this._imageHeight
    let adaptScale = Math.min(widthScale, heightScale)
    console.info("CropView",
      `Image scale ${adaptScale} while attaching the component[${this._viewWidth}, ${this._viewHeight}]`)

    // 经过两次缩放(适配控件、手势)后，图片的实际显示大小
    this.totalScale = adaptScale * this.zoomScale
    let showWidth = this._imageWidth * this.totalScale
    let showHeight = this._imageHeight * this.totalScale
    let imageX = (this._viewWidth - showWidth) / 2
    let imageY = (this._viewHeight - showHeight) / 2
    console.info("CropView", `Image left top is (${imageX}, ${imageY})`)

    // 取景框的左上角坐标
    let frameX = (this._viewWidth - this._frameWidthPx) / 2
    let frameY = (this._viewHeight - this._frameHeightPx) / 2

    // 图片左上角坐标
    let showX = imageX + offsetX * scale
    let showY = imageY + offsetY * scale
    console.info("CropView", `Image show at (${showX}, ${showY})`)


    if (this._frameWidthPx > showWidth || this._frameHeightPx > showHeight) { // 图片缩放后，大小不足以填满取景框
      let xScale = this._frameWidthPx / showWidth
      let yScale = this._frameHeightPx / showHeight
      let newScale = Math.max(xScale, yScale)
      this._zoomScale = this._zoomScale * newScale
      this.checkImageAdapt()
      return
    }

    // 调整x轴方向位置，使图像填满取景框
    if (showX > frameX) {
      showX = frameX
    } else if (showX + showWidth < frameX + this._frameWidthPx) {
      showX = frameX + this._frameWidthPx - showWidth
    }
    // 调整y轴方向位置，使图像填满取景框
    if (showY > frameY) {
      showY = frameY
    } else if (showY + showHeight < frameY + this._frameHeightPx) {
      showY = frameY + this._frameHeightPx - showHeight
    }
    this.offsetX = (showX - imageX) / scale
    this.offsetY = (showY - imageY) / scale


    // 裁剪的坐标
    this.cutX = (frameX - (imageX + this.offsetX * this.zoomScale)) / this.totalScale
    this.cutY = (frameY - (imageY + this.offsetY * this.zoomScale)) / this.totalScale
  }

  public get zoomScale() {
    return this._zoomScale
  }

  /**
   * 旋转图片
   * @param angle 需要旋转的度数，默认一次旋转90度
   */
  public rotate(angle: number | undefined = undefined) {
    // 默认旋转90度
    let a = angle ?? 90

    this.rotatePixelMap(this._angle + a)
  }

  /**
   * 旋转图片到几度
   * @param angle 目标度数
   */
  public rotateTo(toAngle: number) {
    if (this._angle == toAngle) {
      return
    }

    let realAngle = this.calculateTotalAngle(toAngle)
    // 减去已经旋转的，计算出需要旋转的角度
    let angle = realAngle - this._angle

    if (angle == 0) {
      return
    }

    this.rotatePixelMap(toAngle)
  }

  /**
   * 翻转图片
   * @param horizontal 是否需要水平翻转
   * @param vertical 是否需要垂直翻转
   */
  public flip(horizontal: boolean, vertical: boolean): Promise<void> {
    if (!this.srcPixelMap) {
      return Promise.reject('PixelMap is undefined')
    }

    if (horizontal) {
      this._horizontalFlip = !this._horizontalFlip
    }
    if (vertical) {
      this._verticalFlip = !this._verticalFlip
    }

    return this.copyPixelMap(this.srcPixelMap).then(pm => {
      pm.flip(horizontal, vertical)
      this.srcPixelMap?.release()
      this.srcPixelMap = pm
    })
  }

  /**
   * 水平翻转
   */
  public horizontalFlip(): Promise<void> {
    return this.flip(true, false)
  }

  /**
   * 垂直翻转
   */
  public verticalFlip(): Promise<void> {
    return this.flip(false, true)
  }

  public isHorizontalFlip() {
    return this._horizontalFlip
  }

  public isVerticalFlip() {
    return this._verticalFlip
  }

  /**
   * 缩放
   */
  public set scale(scale: number) {
    this._zoomScale = scale
    this.updateMatrix()
  }

  /**
   * 高斯模糊
   */
  public blur(blurRadius: number): Promise<void> {
    if (blurRadius < 0) {
      blurRadius = 0
    }
    return this.reloadSrc().then(pm => {
      pm.flipSync(this._horizontalFlip, this._verticalFlip)
      pm.rotateSync(this._angle)

      let headFilter = effectKit.createEffect(pm) // create Filter Instance
      if (headFilter !== null) {
        headFilter = headFilter.blur(blurRadius).brightness(this._bright)
        if (this._grayscale) {
          return headFilter.grayscale().getEffectPixelMap()
        } else {
          return headFilter.getEffectPixelMap()
        }
      }
      return undefined
    }).then((pm) => {
      this._blurRadius = blurRadius
      this.srcPixelMap?.release()
      this.srcPixelMap = pm
    })
  }

  /**
   * 高亮度
   * @param num 数值区间[0, 1]
   */
  public bright(num: number): Promise<void> {
    if (num < 0) {
      num = 0
    }
    if (num > 1) {
      num = 1
    }

    return this.reloadSrc().then(pm => {
      pm.flipSync(this._horizontalFlip, this._verticalFlip)
      pm.rotateSync(this._angle)

      let headFilter = effectKit.createEffect(pm) // create Filter Instance
      if (headFilter !== null) {
        headFilter = headFilter.blur(this._blurRadius).brightness(num)
        if (this._grayscale) {
          return headFilter.grayscale().getEffectPixelMap()
        } else {
          return headFilter.getEffectPixelMap()
        }
      }
      return undefined
    }).then((pm) => {
      this._bright = num
      this.srcPixelMap?.release()
      this.srcPixelMap = pm
    })
  }

  /**
   * 灰度
   */
  public grayscale(isSet: boolean): Promise<void> {
    if (isSet == this._grayscale) {
      return Promise.resolve()
    }

    return this.reloadSrc().then(pm => {
      pm.flipSync(this._horizontalFlip, this._verticalFlip)
      pm.rotateSync(this._angle)

      let headFilter = effectKit.createEffect(pm) // create Filter Instance
      if (headFilter !== null) {
        headFilter = headFilter.blur(this._blurRadius).brightness(this._bright)
        if (isSet) {
          return headFilter.grayscale().getEffectPixelMap()
        } else {
          return headFilter.getEffectPixelMap()
        }
      }

      return undefined
    }).then((pm) => {
      this._grayscale = isSet
      this.srcPixelMap?.release()
      this.srcPixelMap = pm
    })
  }

  public isGrayscale() {
    return this._grayscale
  }

  /**
   * 获取裁剪的图片位图
   */
  public crop(): Promise<PixelMap> {
    if (!this.srcPixelMap) {
      throw new Error('Please set src first')
    }
    if (this._imageWidth == 0 || this._imageHeight == 0) {
      throw new Error('The image is not loaded')
    }

    return this.copyPixelMap(this.srcPixelMap)
      .then((cp) => {
        let region: image.Region = {
          x: this.cutX,
          y: this.cutY,
          size: { width: this._frameWidthPx / this.totalScale, height: this._frameHeightPx / this.totalScale }
        }

        cp.cropSync(region)
        return cp
      })
  }

  /**
   * 获取裁剪的图片文件路径
   */
  public cropWithPath(option: image.PackingOption = { format: 'image/png', quality: 100 }) {
    return this.crop().then((pm) => {
      let imagePackerApi = image.createImagePacker()
      let tempDir: string = getContext().getApplicationContext().tempDir
      let dstUri: string = tempDir + '/IMG_crop_temp_' + new Date().getTime() // 保存文件uri
      let file: fs.File = fs.openSync(dstUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      return imagePackerApi.packToFile(pm, file.fd, option).then(() => {
        pm.release()
        return imagePackerApi.release().then(() => {
          fileIo.close(file.fd)
          return file.path
        })
      })
    })
  }

  private calculateTotalAngle(angle: number): number {
    if (angle >= 0) {
      // 顺时针
      if (angle >= 360) {
        let result = angle - 360
        if (result > 360) {
          return this.calculateTotalAngle(result)
        }
        return result
      } else {
        return angle
      }
    } else {
      // 逆时针
      if (angle <= -360) {
        let result = angle + 360
        if (result < -360) {
          return this.calculateTotalAngle(result)
        }
        return result
      } else {
        return angle
      }
    }
  }

  private copyPixelMap(pm: PixelMap): Promise<PixelMap> {
    return pm.getImageInfo().then((imageInfo) => {
      const buffer: ArrayBuffer = new ArrayBuffer(pm.getPixelBytesNumber())
      pm.readPixelsToBufferSync(buffer)
      const opts: image.InitializationOptions = {
        editable: false,
        srcPixelFormat: imageInfo.pixelFormat,
        pixelFormat: imageInfo.pixelFormat,
        size: imageInfo.size
      }
      return image.createPixelMap(buffer, opts)
    })
  }

  /**
   * 旋转位图，必须从源文件重新读取位图进行设置，不能用已经显示的位图，否则会导致图片越旋转越小
   * @param toAngle
   */
  private rotatePixelMap(toAngle: number) {
    this.reloadSrc().then(async (pm) => {
      // 由于是重新读取的源文件，所以需要恢复翻转、模糊等效果
      this._angle = this.calculateTotalAngle(toAngle)
      pm.flipSync(this._horizontalFlip, this._verticalFlip)
      pm.rotateSync(this._angle)

      if (this._blurRadius > 0 || this._bright > 0 || this._grayscale) {
        let headFilter = effectKit.createEffect(pm)
        if (headFilter !== null) {
          if (this._grayscale) {
            headFilter = headFilter.grayscale()
          }
          pm = await headFilter.blur(this._blurRadius).brightness(this._bright).getEffectPixelMap()
        }
      }

      this.srcPixelMap?.release()
      this.srcPixelMap = pm
    })
  }


  updateMatrix(): void {
    this.matrix = Matrix4.identity()
      .translate({ x: this.offsetX, y: this.offsetY })
      .scale({ x: this.zoomScale, y: this.zoomScale })
    //这里不能使用 矩阵的 rotate，因为会导致移动图片的x/y值难以计算
  }
}