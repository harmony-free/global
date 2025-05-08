import { webview } from '@kit.ArkWeb'
import { window } from '@kit.ArkUI';
import { uri } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { JSBridge } from '../system/JSBridge';
import { global } from '../system/Global';
import { NavBar, router } from '../../../../Index';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';

const baseUrl = 'https://www.baidu.com/'

/**
 * url?:string 网页地址
 * title?:string 网页名称
 * isNavBar?: boolean 是否需要顶部导航
 * isTabBar?: boolean 是否需要底部导航
 * isShare?: boolean 是否可以分享
 * args?: object 参数
 */
export  interface  WebParam{
  url?:string
  title?:string
  isNavBar?: boolean
  isTabBar?: boolean
  isShare?: boolean
  args?: object
}

enum WebStatus {
  normal,
  begin,
  progress,
  end
}

@Builder
export function WebBuilder(param: WebParam | undefined) {
  NavDestination() {
    WebPage({param:param ?? {}})
  }.hideTitleBar(true)
}

router.requestBuilder("web", wrapBuilder(WebBuilder))

@Entry
@Component
export struct WebPage{
  @Prop param: WebParam = {
    url: baseUrl,
    title: "网页",
    isNavBar: true,
    isTabBar: true,
    isShare: true,
  }
  @State controller: webview.WebviewController = new webview.WebviewController()
  @State title:string = this.param.title ?? "网页"
  @State url:string = this.param.url ?? baseUrl
  @State progress:number = 0.0
  @State webStatus: WebStatus = WebStatus.normal
  @State isNavBar: boolean = this.param.isNavBar ?? true
  @State isTabBar: boolean =  this.param.isTabBar ?? true
  @State isShare: boolean =  this.param.isShare ?? true
  @State currentUrl: string =  this.url

  // 返回方法
  backAction = () => {
    if (!this.isTabBar && this.controller.accessBackward()) {
      this.controller.backward()
    }else {
      router.back()
    }
  }
  @Builder
  rightBuilder(){
    Row(){
      if (this.isShare){
        Image($r('sys.media.ohos_ic_public_share')).margin({right:10}).width(25).height(25).onClick(()=>{
          global.share({
            utd: utd.UniformDataType.HYPERLINK,
            title: this.title,
            content: this.currentUrl,
          });
        })
      }
      Image($r('sys.media.ohos_ic_public_web')).margin({right:10}).width(25).height(25).onClick(()=>{
        global.toWeb(this.url)
      })
    }
  }

  getWebHeight(): number{
    let height:number = global.height
    if (this.isNavBar == true) {
      height = height - global.top - 44 - 1
    }else{
      height = height - global.top - 1
    }
    if (this.isTabBar == true) {
      height = height - global.bottom - 40 - 1
    }else{
      height = height - global.bottom - 1
    }
    return height
  }

  onIntercept = (event: OnLoadInterceptEvent):OnLoadInterceptEvent=>{
    this.currentUrl = event.data.getRequestUrl()
    return event
  }
  
  build() {
    Column(){
      if (this.isNavBar){
        NavBar({
          leftIcon: this.isTabBar ? $r('sys.media.ohos_ic_public_cancel') : $r('sys.media.ohos_ic_public_arrow_left'),
          backAction: this.backAction,
          title: this.title,
          rightBuilderParam:this.rightBuilder.bind(this)
        })
      } else {
        Blank().height(global.top)
      }
      if (this.progress !== 0){
        Progress({
          type: ProgressType.Linear,
          value: this.progress,
          total: 100,
        }).height(1)
      }else{
        Divider().height(1)
      }
      WebBase({
        url:this.url,
        title:this.title,
        controller:this.controller,
        progress: this.progress,
        webStatus:this.webStatus,
        onIntercept:this.onIntercept
      }).width(global.width).height(this.getWebHeight())
      if (this.isTabBar){
        this.bottomView()
      }else{
        Blank().height(global.bottom)
      }

    }
  }

  @Builder
  bottomView(){
    Row(){
      Image($r("sys.media.ohos_ic_public_arrow_left"))
        .width(30)
        .height(30)
        .fillColor((this.webStatus != WebStatus.normal && this.controller.accessBackward())?Color.Black:Color.Grey)
        .onClick(()=>{
          if (this.controller.accessBackward()) {
            this.controller.backward()
          }
        })
      Blank().width(30)
      Image($r("sys.media.ohos_ic_public_arrow_right"))
        .width(30)
        .height(30)
        .fillColor((this.webStatus != WebStatus.normal && this.controller.accessForward())?Color.Black:Color.Grey)
        .onClick(()=>{
          if (this.controller.accessForward()) {
            this.controller.forward()
          }
        })
    }.height(global.bottom + 40).padding({bottom:global.bottom})
  }
}


@Component
export struct WebBase {
  @Link title: string
  @Prop url: string | Resource = baseUrl

  @Link controller: webview.WebviewController
  @Link progress:number
  @Link webStatus:WebStatus
  private jsBridge: JSBridge = new JSBridge(this.controller);
  @State screenHeight: number | string = '100%';

  onIntercept = (event: OnLoadInterceptEvent): OnLoadInterceptEvent =>{

		return event;
	}

  aboutToAppear(): void {
    // 配置Web开启调试模式
    if (global.debug) {
      try {
        webview.WebviewController.setWebDebuggingAccess(true);
      } catch (error) {
        console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      }
    }
    window.getLastWindow(getContext(this)).then(currentWindow => {
      // 监视软键盘的弹出和收起
      currentWindow.on('avoidAreaChange', async data => {
        this.screenHeight = '100%'
      });
    })

  }

  nativeAction = () => {

  }

  build() {
    Web({ src: this.url, controller: this.controller })
      .overScrollMode(OverScrollMode.NEVER)
      .height(this.screenHeight)
      .metaViewport(true)
      .fileAccess(true)
      .zoomAccess(true)
      .geolocationAccess(true)
      .onProgressChange((p)=>{
        this.webStatus = WebStatus.progress
        if (this.progress == p.newProgress) {
          this.progress = 0
        }else{
          this.progress = p.newProgress
        }
        console.log(this.progress.toString());
      })
      .onPageBegin(() => {
        this.webStatus = WebStatus.begin
        this.jsBridge.initJsBridge();
      })
      .onPageEnd(async (data) => {
        this.webStatus = WebStatus.end
        this.title = this.controller.getTitle()
      })
      .onAppear(() => {
        // 指定第二个参数为true，代表要进行预连接，如果为false该接口只会对网址进行dns预解析
        // 第三个参数为要预连接socket的个数。最多允许6个。
        // webview.WebviewController.prepareForPageLoad('http://m-test.jianbaolife.com/', true, 4);
      })
      .domStorageAccess(true)
      .javaScriptAccess(true)
      .mixedMode(MixedMode.All)
      .javaScriptProxy(this.jsBridge.javaScriptProxy)
      .onControllerAttached(() => {
        try {
          // 应用侧用法示例，定制UserAgent。
          let ua = this.controller.getUserAgent();
          this.controller.setCustomUserAgent(ua);
        } catch (error) {
          console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
        }
      })
      .onLoadIntercept((event) => {
        if (event) {
          event = this.onIntercept(event);
          let currentUrl: string = event.data.getRequestUrl()
          let currentUri = new uri.URI(currentUrl)
          if (currentUri.scheme == "alipay" || currentUri.scheme == "alipays") {
            global.openLink(currentUrl)
          } else if (currentUri.scheme == "tel") {
            call.makeCall(currentUri.ssp)
            return true
          }
        }
        // 返回true表示阻止此次加载，否则允许此次加载
        return false
      })
      .onGeolocationShow((event) => { // 地理位置权限申请通知
        AlertDialog.show({
          title: '位置权限请求',
          message: '是否允许获取位置信息',
          primaryButton: {
            value: '不允许',
            action: () => {
              if (event) {
                event.geolocation.invoke(event.origin, false, false); // 不允许此站点地理位置权限请求
              }
            }
          },
          secondaryButton: {
            value: '允许',
            action: () => {
              if (event) {
                event.geolocation.invoke(event.origin, true, true); // 允许此站点地理位置权限请求
              }
            }
          },
          cancel: () => {
            if (event) {
              event.geolocation.invoke(event.origin, false, false); // 不允许此站点地理位置权限请求
            }
          }
        })

      })
  }
}