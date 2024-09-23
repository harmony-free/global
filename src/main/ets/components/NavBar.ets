import { global } from '../system/Global';
import { router } from '../system/Router';

@Component
export struct NavBar {
  // 背景颜色
  backColor: ResourceColor = Color.White;
  // 文字颜色
  textColor: ResourceColor = Color.Black;
  // 文字位置
  textAlign: TextAlign = TextAlign.Center
  // 标题
  @Prop title: string = ""

  // 默认左侧按钮
  @Builder
  leftBuilder() {
    // parseInt(router.getLength()) > 1
    if (router.size() >= 1) {
      Text() {
        SymbolSpan($r('sys.symbol.chevron_left'))
          .fontSize(30)
      }.onClick(this.backAction).padding({ left: 10 }).fontColor(this.textColor)
    }
  }

  // 默认右侧按钮
  @Builder
  rightBuilder() {

  }

  // 自定义左侧按钮
  @BuilderParam leftBuilderParam: () => void = this.leftBuilder;
  // 自定义右侧按钮
  @BuilderParam rightBuilderParam: () => void = this.rightBuilder;
  // 返回方法
  backAction = () => {
    router.back()
  }

  build() {
    Stack() {
      Text(this.title)
        .width('70%')
        .textAlign(this.textAlign)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .fontColor(this.textColor)
      Row() {
        this.leftBuilderParam()
        Blank()
        this.rightBuilderParam()
      }.padding(10).height(44).width('100%')
    }.height(44 + global.top).width('100%').padding({ top: global.top }).backgroundColor(this.backColor)
  }
}
