import { global } from "../../../../Index"
import { router as nav } from "../system/Router"
import { router } from "@kit.ArkUI"

export  interface LaunchParam{
  image: PixelMap | ResourceStr | DrawableDescriptor
  time: number
  type:"router"|"navigation"
  toHome: Function
}

@Builder
export function LaunchBuilder(param: LaunchParam | undefined) {
  NavDestination() {
    LaunchPage({param:param})
  }.hideTitleBar(true)
}

nav.requestBuilder("launch", wrapBuilder(LaunchBuilder))

@Entry({ routeName: 'launch' })
@Component
export  struct LaunchPage{
  param: LaunchParam = {
    image: "",
    time: 3,
    toHome: () => {
    },
    type: "navigation"
  };
  @State time:number = 3
  timeoutID:number = 3

  aboutToAppear(): void {
    this.timeoutID = setInterval(()=>{
      this.time -= 1;
      if (this.time<=0) {
        // clearInterval(this.timeoutID);
        this.back()
      }
    }, 1000)
  }

  back(){
    clearInterval(this.timeoutID);
    if (this.param.type == "router") {
      router.back()
    }else{
      nav.pop(undefined,false)
    }

  }

  build() {
    Stack(){
      Image(this.param.image).width(global.width).height(global.height).onClick(()=>{
        this.back()
        this.param.toHome()
      })
      Button(`跳过${this.time}`).backgroundColor(0x30000000).onClick(()=>this.back()).position({right:20,top:global.top + 20})
    }
  }
}