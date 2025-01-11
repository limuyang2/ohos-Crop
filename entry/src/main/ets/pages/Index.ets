import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { image } from '@kit.ImageKit';
import { Crop } from '@mumu/crop_page';

@Entry
@ComponentV2
struct Index {
  private pathStack: NavPathStack = new NavPathStack()
  @Local private statusBarHeight: number = 0
  @Local private navBarHeight: number = 0
  @Local private cropPixelMap?: PixelMap = undefined
  private onAvoidAreaChange = (data: window.AvoidAreaOptions) => {
    if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
      this.statusBarHeight = px2vp(data.area.topRect.height)
    } else if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
      this.navBarHeight = px2vp(data.area.bottomRect.height)
    }
  }

  aboutToAppear(): void {
    try {
      let context = getContext(this) as common.UIAbilityContext
      let mainWindow = context.windowStage.getMainWindowSync()

      // 获取当前的状态栏高度
      this.statusBarHeight = px2vp(mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
      this.navBarHeight =
        px2vp(
          mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
        )
      // 监听状态栏高度变化。（例如进入小窗模式）
      mainWindow.on('avoidAreaChange', this.onAvoidAreaChange)
    } catch (exception) {
    }
  }

  build() {
    Navigation(this.pathStack) {
      Row() {
        Column({ space: 15 }) {
          Image(this.cropPixelMap)
            .width(200)
            .height(200)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#ffc6c6c6')

          Button('图片裁剪')
            .fontSize(13)
            .onClick(() => {
              this.getPictureFromLight()
            })



        }
      }.padding({ top: this.statusBarHeight + 15 })
    }
  }

  async getPictureFromLight() {
    // 拉起相册，选择图片
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    PhotoSelectOptions.maxSelectNumber = 1
    PhotoSelectOptions.isEditSupported = true
    let photoPicker = new photoAccessHelper.PhotoViewPicker()
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(PhotoSelectOptions)
    // this.albumPath = photoSelectResult.photoUris[0]

    let pickPath = photoSelectResult.photoUris[0]

    if (pickPath === undefined) {
      return
    }

    // 图片裁剪
    this.pathStack.pushPath({
      name: 'crop://image_crop_page', param: Crop.pageConfig({
        src: pickPath,
        isSupportDark: true
      }),

      onPop: (popInfo) => {
        let cropPath = popInfo.result as string
        if (cropPath) {
          fs.open(cropPath, fs.OpenMode.READ_ONLY)
            .then((file) => {
              let imageSource: image.ImageSource = image.createImageSource(file.fd)
              let decodingOptions: image.DecodingOptions = {
                editable: false
              }
              // 创建pixelMap
              this.cropPixelMap = imageSource.createPixelMapSync(decodingOptions)
            })
        }
      }
    })
  }
}