import { BaseGlobal } from './BaseGlobal'
import { window } from '@kit.ArkUI'


export  class Window extends BaseGlobal {
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

  constructor() {
    super()
    this.main.on('windowSizeChange', () => this.resize())
    this.resize()
    this.setFullScreen()
    this.setOrientation()
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
    console.log(`navInfo：${JSON.stringify(info)}`)
  }

  /**
   * 监听路由跳转
   * @param info
   */
  routerPageUpdate(info: RouterPageInfo) {
    console.log(`routerInfo:${JSON.stringify(info)}`)
  }

  /**
   * 重新计算位置信息
   */
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