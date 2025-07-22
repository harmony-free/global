import { global } from '../system/Global';
import { router } from '../system/Router';
import { router as route } from '@kit.ArkUI';

@Component
export struct NavBar {
  // 背景颜色
  backColor: ResourceColor = Color.White;
  // 文字颜色
  textColor: ResourceColor = Color.Black;
  // 文字位置
  textAlign: TextAlign = TextAlign.Center
  // type
  type: 'nav' | 'router' = 'nav'
  // 返回数据
  backData:object | undefined = undefined
  // 标题
  @Prop title: string = ""

  @Prop leftIcon:Resource = $r('sys.media.ohos_ic_public_arrow_left')

  // 默认左侧按钮
  @Builder
  leftBuilder() {
    if (this.queryNavigationInfo()?.pathStack.size() != 0 || Number(route.getLength()) >= 2) {
      Image(this.leftIcon).width(30).aspectRatio(1).onClick(this.backAction).padding({ left: 10 }).fillColor(this.textColor)
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
    if (router.size() >= 1) {
      router.back(this.backData)
    }else if (Number(route.getLength()) >= 2) {
      route.back({url:"",params:this.backData});
    }
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
      }.padding({left:10,right:10}).height(44).width('100%')
    }
    .height(44 + global.top)
    .width('100%')
    .padding({ top: global.top })
    .backgroundColor(this.backColor)
  }
}
