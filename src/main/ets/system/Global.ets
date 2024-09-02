import { bundleManager } from '@kit.AbilityKit'
import { display, window } from '@kit.ArkUI'
import { log } from './Log'

/**
 * 使用前需要在 windowStage.loadContent 中设置使用 globalInfo.setWindow(w) 设置mainWindow
 */

const flags: bundleManager.BundleFlag =
  bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE

const bundleInfo = bundleManager.getBundleInfoForSelfSync(flags)

export const appInfo = bundleInfo.appInfo

class Display {
  /**
   * 屏幕信息
   */
  dis: display.Display
  /**
   * 屏幕的宽度
   */
  width: number
  /**
   * 屏幕的高度
   */
  height: number

  constructor() {
    this.dis = display.getDefaultDisplaySync()
    this.width = px2vp(this.dis.width)
    this.height = px2vp(this.dis.height)
  }
}


class Window extends Display {
  /**
   * 主window信息
   */
  main!: window.Window
  /**
   * 窗口属性
   */
  properties!: window.WindowProperties
  /**
   * 屏幕顶部刘海屏的高度
   */
  top: number = 0
  /**
   * 屏幕底部挖底屏的高度
   */
  bottom: number = 0
  /**
   * 屏幕内容的宽度
   */
  contextWidth: number = 0
  /**
   * 屏幕内容的高度
   */
  contextHeight: number = 0

  /**
   * 设置系统zhu窗口
   * @param main:window.Window 系统主窗口
   */
  setWindow(main: window.Window) {
    this.main = main
    this.properties = this.main.getWindowProperties()
    this.main.on('windowSizeChange', () => this.resize())
    this.setFullScreen()
    this.setOrientation()
    this.resize()
    // this.setLister()
  }

  /**
   * 设置路由监听
   */
  setLister() {
    this.main.getUIContext().getUIObserver().on("routerPageUpdate", this.routerPageUpdate)
    this.main.getUIContext().getUIObserver().on("navDestinationUpdate", this.navDestinationUpdate)
  }

  /**
   * 监听组件跳转
   * @param info
   */
  navDestinationUpdate(info: NavDestinationInfo) {
    if (info.state == 0) {
      log("组件显示：" + info.name)
    }
  }

  /**
   * 监听路由跳转
   * @param info
   */
  routerPageUpdate(info: RouterPageInfo) {
    if (info.state == 0) {
      log("页面即将显示：" + info.name)
    }
  }

  resize() {
    let top = this.main.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
    let bottom = this.main.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
    this.top = px2vp(top)
    this.bottom = px2vp(bottom)
    this.contextWidth = this.width
    this.contextHeight = this.height - this.bottom - this.top
  }

  /**
   * 设置沉浸式窗口
   * @param full: boolean 默认true
   */
  setFullScreen(full: boolean = true) {
    this.main.setWindowLayoutFullScreen(full)
  }

  /**
   * 设置窗口显示方向
   * @param orientation: window.Orientation 默认: window.Orientation.PORTRAIT 竖屏
   */
  setOrientation(orientation: window.Orientation = window.Orientation.PORTRAIT) {
    this.main.setPreferredOrientation(orientation)
  }

  /**
   * 设置主窗口三键导航栏、状态栏、底部导航条的显示和隐藏，使用Promise异步回调
   * @param name:  'status' | 'navigation' | 'navigationIndicator'
   */
  setSpecific(name: 'status' | 'navigation' | 'navigationIndicator') {
    this.main.setSpecificSystemBarEnabled(name, false, true)
  }

  /**
   * 设置主窗口三键导航栏、状态栏、底部导航条的可见模式，状态栏与底部导航条通过status控制、三键导航栏通过navigation控制，使用Promise异步回调
   * @param names: ("status" | "navigation")[]
   */
  setBarEnable(names: ("status" | "navigation")[]) {
    this.main.setWindowSystemBarEnable(names)
  }

  /**
   * 设置主窗口三键导航栏、状态栏的属性，使用Promise异步回调
   * @param p: window.SystemBarProperties
   */
  setBarProperties(p: window.SystemBarProperties) {
    this.main.setWindowSystemBarProperties(p)
  }

  /**
   * 设置主窗口状态栏文字颜色
   * @param color
   */
  setBarContentColor(color: string) {
    this.setBarProperties({ statusBarContentColor: color })
  }
}

class Error extends Window {
  registerId: number = -1

  setWant() {
    this.main
  }

  // let callback: errorManager.ErrorObserver = {
  //   onUnhandledException: (errMsg) => {
  //     console.log('产生未捕获异常时的回调，onUnhandledException:', errMsg);
  //     // promptCustom.showDialog({ message: errMsg, title: "系统代码异常" })
  //   },
  //   onException: (errorObj) => {
  //     console.log('产生异常上报JS层时的回调，onException');
  //     // promptCustom.showToast({ message: errorObj.message })
  //     console.log('onException, name: ', errorObj.name);
  //     console.log('onException, message: ', errorObj.message);
  //     if (typeof (errorObj.stack) === 'string') {
  //       console.log('onException, stack: ', errorObj.stack);
  //     }
  //   }
  // }

}

class Global extends Window {
  /**
   * 应用包信息
   */
  bundleInfo: bundleManager.BundleInfo
  /**
   * 应用程序信息
   */
  appInfo: bundleManager.ApplicationInfo
  /**
   * 应用名称
   */
  appName: string
  /**
   * 应用包名
   */
  bundleName: string
  /**
   * 版本号
   */
  version: string
  /**
   * 当前环境：release：发布打包签名环境，debug：调试打包签名环境
   */
  env: string
  /**
   * 当前环境类型： Canary、Beta、Release
   */
  releaseType: string
  /**
   * 是否是发布打包签名环境
   */
  release: boolean
  /**
   * 是否是调试打包签名环境
   */
  debug: boolean
  /**
   * 应用程序的uid
   */
  uid: number

  constructor(bundleInfo: bundleManager.BundleInfo) {
    super()
    this.bundleInfo = bundleInfo
    this.appInfo = bundleInfo.appInfo
    this.version = bundleInfo.versionName
    this.bundleName = this.appInfo.name
    this.appName = this.appInfo.label
    this.env = this.appInfo.appProvisionType
    this.releaseType = this.appInfo.releaseType
    this.release = this.appInfo.appProvisionType == 'release'
    this.debug = this.appInfo.appProvisionType == 'debug'
    this.uid = this.appInfo.uid
  }
}

export const global = new Global(bundleInfo)

