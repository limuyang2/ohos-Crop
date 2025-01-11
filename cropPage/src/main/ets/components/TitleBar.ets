/**
 * 自定义顶部导航栏
 */
@ComponentV2
export struct TitleBar {
  /**
   * 是否暗色模式
   */
  @Param isDark: boolean = false
  /**
   * 返回按钮点击事件
   */
  @Param onReturnClick: (event: ClickEvent) => void = () => {
  }
  /**
   * 标题
   */
  @Param title: string | Resource = ''
  /**
   * title 对齐方式
   */
  @Param titleAlign: TextAlign = TextAlign.Center
  /**
   * 右边的自定义控件
   */
  @BuilderParam rightBuilder?: () => void
  /**
   * 记录左边的view宽度
   */
  @Local private leftW: number = 0
  /**
   * 记录右边的view宽度
   */
  @Local private rightW: number = 0
  /**
   * btn按钮尺寸
   */
  private btnSize = 20

  build() {
    Row() {

      // 左边布局
      Image(this.isDark ? $r('app.media.common_crop_icon_titlebar_return_dark') :
      $r('app.media.common_crop_icon_titlebar_return'))
        .width(this.btnSize)
        .height(this.btnSize)
        .responseRegion({
          x: '-50%',
          y: '-50%',
          width: '200%',
          height: '200%'
        })
        .objectFit(ImageFit.ScaleDown)
        .onClick(this.onReturnClick)
        .onAreaChange((_, n) => {
          if (typeof n.width === "number") {
            if (n.width >= 0) {
              this.leftW = n.width
            }
          }
        })

      if (this.titleAlign == TextAlign.Center) {
        if (this.rightW > this.leftW) {
          // 添加占位控件，让title保持居中
          Blank().width(this.rightW - this.leftW)
        }
      }

      // 中间title布局
      Text(this.title)
        .maxLines(1)
        .textAlign(this.titleAlign)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isDark ? $r('app.color.crop_page_title_dark') : $r('app.color.crop_page_title'))
        .fontSize(16)
        .layoutWeight(1)
        .margin({ left: 16, right: 16 })


      if (this.titleAlign == TextAlign.Center) {
        if (this.rightW < this.leftW) {
          Blank().width(this.leftW - this.rightW)
        }
      }

      // 右边布局
      if (this.rightBuilder != undefined) {
        Row() {
          this.rightBuilder()
        }.onAreaChange((_, n) => {
          if (typeof n.width === "number") {
            if (n.width >= 0) {
              this.rightW = n.width
            }
          }
        })
      }

    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
    .alignItems(VerticalAlign.Center)
    .width("100%")
    .constraintSize({
      minHeight: 44
    })
  }
}

