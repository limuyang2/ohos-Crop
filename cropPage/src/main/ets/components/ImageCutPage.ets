import { common, ConfigurationConstant, EnvironmentCallback } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { CropController, CropView } from '@mumu/crop';
import { TitleBar } from './TitleBar';
import resourceManager from '@ohos.resourceManager';

@Builder
export function ImageCropPageBuilder() {
  ImageCropPage()
}

/**
 * 图片裁剪页面
 *
 * 参数：src - 图片文件路径
 *      quality - 裁剪后的文件图片质量
 *
 * 返回参数：path - 裁剪后的文件路径
 */
@Preview
@ComponentV2
export struct ImageCropPage {
  private src: string = ''
  private quality: number = 90
  private controller: CropController = new CropController()
  private pathStack?: NavPathStack = undefined
  @Local private isDark: boolean = false
  @Local private title: string | Resource = ''
  @Local private statusBarHeight: number = 0
  @Local private navBarHeight: number = 0
  private isSupportDark: boolean = false
  private originalStatusBarColor?: string = undefined
  private onAvoidAreaChange = (data: window.AvoidAreaOptions) => {
    if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
      this.statusBarHeight = px2vp(data.area.topRect.height)
    } else if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
      this.navBarHeight = px2vp(data.area.bottomRect.height)
    }
  }
  private environmentId?: number = undefined

  aboutToDisappear(): void {
    try {
      let context = getContext(this) as common.UIAbilityContext
      context.windowStage.getMainWindowSync().off('avoidAreaChange', this.onAvoidAreaChange)

      if (this.environmentId) {
        getContext().getApplicationContext().off('environment', this.environmentId)
      }

      // 恢复状态栏颜色
      context.windowStage.getMainWindowSync().setWindowSystemBarProperties({
        statusBarContentColor: this.originalStatusBarColor
      })
    } catch (exception) {
    }
  }

  @LocalBuilder
  right() {
    // 保存按钮
    Text($r('app.string.crop_page_ok'))
      .fontColor(this.isDark ? $r('app.color.crop_page_ok_dark') : $r('app.color.crop_page_ok'))
      .fontSize(14)
      .fontWeight(FontWeight.Normal)
      .borderRadius(8)
      .padding({
        left: 6,
        top: 6,
        right: 6,
        bottom: 6
      })
      .responseRegion({
        y: '-50%',
        height: '200%',
        x: '-50%',
        width: '200%'
      })
      .onClick(() => {
        this.controller.cropWithPath({ format: 'image/png', quality: this.quality }).then((path) => {
          this.pathStack?.pop(path)
        })
      })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {

        Stack({ alignContent: Alignment.Bottom }) {
          CropView({
            src: this.src,
            controller: this.controller,
            maskColor: this.isDark ? getContext().resourceManager.getColorSync($r('app.color.crop_page_mask_dark')) :
            getContext().resourceManager.getColorSync($r('app.color.crop_page_mask')),
            frameWidth: 220,
            frameHeight: 220,
          })
            .width("100%")
            .height("100%")


          // 底部操作栏
          Row({ space: 12 }) {
            Blank().layoutWeight(1)
            Column({ space: 4 }) {
              Image(this.isDark ? $r("app.media.common_crop_rotate_dark") : $r("app.media.common_crop_rotate"))
                .width(24)
                .height(24)
              Text($r('app.string.crop_page_rotate'))
                .fontSize(12)
                .fontColor(this.isDark ? $r('app.color.crop_page_action_dark') : $r('app.color.crop_page_action'))
            }
            .constraintSize({ minWidth: 48 })
            .onClick(() => {
              this.controller.rotate()
            })

            Column({ space: 4 }) {
              Image(this.isDark ? $r("app.media.common_crop_h_flip_dark") : $r("app.media.common_crop_h_flip"))
                .width(24)
                .height(24)
              Text($r('app.string.crop_page_h_flip'))
                .fontSize(12)
                .fontColor(this.isDark ? $r('app.color.crop_page_action_dark') : $r('app.color.crop_page_action'))
            }
            .constraintSize({ minWidth: 48 })
            .onClick(() => {
              this.controller.horizontalFlip()
            })

            Column({ space: 4 }) {
              Image(this.isDark ? $r("app.media.common_crop_v_flip_dark") : $r("app.media.common_crop_v_flip"))
                .width(24)
                .height(24)
              Text($r('app.string.crop_page_v_flip'))
                .fontSize(12)
                .fontColor(this.isDark ? $r('app.color.crop_page_action_dark') : $r('app.color.crop_page_action'))
            }
            .constraintSize({ minWidth: 48 })
            .onClick(() => {
              this.controller.verticalFlip()
            })

            Column({ space: 4 }) {
              Image(this.isDark ? $r("app.media.common_crop_grayscale_dark") : $r("app.media.common_crop_grayscale"))
                .width(24)
                .height(24)
              Text($r('app.string.crop_page_grayscale'))
                .fontSize(12)
                .fontColor(this.isDark ? $r('app.color.crop_page_action_dark') : $r('app.color.crop_page_action'))
            }
            .constraintSize({ minWidth: 48 })
            .onClick(() => {
              this.controller.grayscale(!this.controller.isGrayscale())
            })

            Blank().layoutWeight(1)
          }
          .alignItems(VerticalAlign.Center)
          .padding({ top: 12, bottom: 12 + this.navBarHeight })
          .width("100%")
          .backgroundBlurStyle(BlurStyle.Thin,
            {
              colorMode: this.isDark ? ThemeColorMode.DARK : ThemeColorMode.LIGHT,
              adaptiveColor: AdaptiveColor.DEFAULT,
              scale: 1.0
            })

        }
        .width("100%")
        .height("100%")


        // 顶部导航栏
        TitleBar({
          title: this.title,
          rightBuilder: this.right,
          isDark: this.isDark,
          onReturnClick: () => {
            this.pathStack?.pop()
          },
        })
          .width("100%")
          .padding({
            top: this.statusBarHeight,
          })
          .backgroundBlurStyle(BlurStyle.Thin,
            {
              colorMode: this.isDark ? ThemeColorMode.DARK : ThemeColorMode.LIGHT,
              adaptiveColor: AdaptiveColor.DEFAULT,
              scale: 1.0
            })

      }
      .width("100%")

    }.hideTitleBar(true)
    .backgroundColor(this.isDark ? $r('app.color.crop_page_bg_dark') : $r('app.color.crop_page_bg'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack

      let param = context.pathInfo.param as CropPageConfig
      if (param) {
        this.src = param.src ?? ''
        this.quality = param.quality ?? 90
        this.title = param.title ?? $r('app.string.crop_page_title')
        this.isSupportDark = param.isSupportDark ?? false

      }
      this.init()
    })

  }

  private init() {
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

      // 记录下原来的状态栏文字颜色，用于关闭页面后恢复
      this.originalStatusBarColor = mainWindow.getWindowSystemBarProperties().statusBarColor
      // 状态栏文字颜色
      getContext().resourceManager.getConfiguration().then((config) => {
        if (this.isSupportDark && config.colorMode === resourceManager.ColorMode.DARK) {
          mainWindow.setWindowSystemBarProperties({
            statusBarContentColor: '#FFFFFF'
          })
          this.isDark = true
        } else {
          mainWindow.setWindowSystemBarProperties({
            statusBarContentColor: '#000000'
          })
          this.isDark = false
        }
      })

      if (this.isSupportDark) {
        // 监听深色模式的改变
        let self = this
        let environmentCallback: EnvironmentCallback = {
          onConfigurationUpdated(config) {
            console.log(`onConfigurationUpdated config: ${JSON.stringify(config)}`)
            self.isDark = config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK
            if (config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
              mainWindow.setWindowSystemBarProperties({
                statusBarContentColor: '#FFFFFF'
              })
            } else {
              mainWindow.setWindowSystemBarProperties({
                statusBarContentColor: '#000000'
              })
            }
          },
          onMemoryLevel(level) {
            console.log(`onMemoryLevel level: ${level}`)
          }
        }
        this.environmentId = getContext().getApplicationContext().on('environment', environmentCallback)
      }
    } catch (exception) {
    }
  }
}

export type OnDarkChangeCallback = (isDark: boolean) => void

/**
 * 裁剪页面的配置
 */
export interface CropPageConfig {
  /**
   * 图片路径
   */
  src: string
  /**
   * 裁剪质量
   */
  quality?: number
  /**
   * 标题
   */
  title?: string | Resource
  /**
   * 是否支持深色模式（暗黑模式），默认不支持
   */
  isSupportDark?: boolean
}

export namespace Crop {
  /**
   * 用于便捷生成 CropPageConfig
   * @param config
   * @returns
   */
  export function pageConfig(config: CropPageConfig): CropPageConfig {
    return config
  }
}