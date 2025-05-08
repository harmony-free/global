import { global } from '../system/Global';
import { router } from '../system/Router';
import { image } from '@kit.ImageKit';

export  interface TabBarFace{
  title:string,
  icon: image.PixelMap | ResourceStr | DrawableDescriptor,
  selectIcon: image.PixelMap | ResourceStr | DrawableDescriptor,
  router:string
}

@Component
export struct TabBar {
  // 背景颜色
  backColor: ResourceColor = Color.White;
  // 文字颜色
  textColor: ResourceColor = Color.Black;

  @Link selectIndex: number;

  // tabBar 数据
  @Prop tabs: Array<TabBarFace> = []

  // 点击方法
  onAction = (index:number) => {
    this.selectIndex = index;
  }



  build() {

    // Row() {
    //   ForEach(this.tabs,(item: TabBarFace, index: number)=>{
    //     Column(){
    //       Image(this.selectIndex == index ? item.selectIcon : item.icon).width(22).aspectRatio(1).margin({bottom:3}).fillColor(this.selectIndex == index ? Color.Blue : Color.Gray)
    //       Text(item.title).fontSize(13).fontColor(this.selectIndex == index ? Color.Blue : Color.Gray)
    //     }
    //     .height(49)
    //     .flexGrow(1)
    //     .justifyContent(FlexAlign.Center)
    //     .backgroundColor(this.backColor)
    //     .onClick(()=>this.onAction(index));
    //   },(item: TabBarFace)=>item.title)
    // }
    // .border({width:{top:0.5},color:{top:0xFFDDDDDD}})
    // .backgroundColor(this.backColor)
    // .width('100%')
    // .height(49 + global.bottom)
    // .padding({ bottom: global.bottom })

  }
}
