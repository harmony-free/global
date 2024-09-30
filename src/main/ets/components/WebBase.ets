import { webview } from '@kit.ArkWeb'
import { window } from '@kit.ArkUI';
import { uri } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { JSBridge } from '../system/JSBridge';
import { global } from '../system/Global';

const baseUrl = 'https://www.huawei.com/cn/'

@Component
export struct WebBase {
  @Link title: string
  @Prop url: string | Resource = baseUrl
  @Link controller: webview.WebviewController
  private jsBridge: JSBridge = new JSBridge(this.controller);
  @State screenHeight: number | string = '100%';

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
      .metaViewport(true)
      .fileAccess(true)
      .zoomAccess(true)
      .geolocationAccess(true)
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
      .height(this.screenHeight)
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
      .onPageBegin(() => {
        this.jsBridge.initJsBridge();
      })
      .onPageEnd(async (data) => {
        this.title = this.controller.getTitle()
      })
      .onAppear(() => {
        // 指定第二个参数为true，代表要进行预连接，如果为false该接口只会对网址进行dns预解析
        // 第三个参数为要预连接socket的个数。最多允许6个。
        webview.WebviewController.prepareForPageLoad('http://m-test.jianbaolife.com/', true, 4);
      })
      .onLoadIntercept((event) => {
        if (event) {
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
  }
}