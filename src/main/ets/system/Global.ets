import { abilityAccessCtrl, bundleManager, errorManager, PermissionRequestResult, Permissions } from '@kit.AbilityKit'
import { display, promptAction, window } from '@kit.ArkUI'
import { LogUtils } from './Log'
import { JSON } from '@kit.ArkTS'
import { PreferencesLog, PreferencesPermission } from './PreferencesUtils'

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

class Tools extends Display {
  /**
   * 请求权限，如果权限被拒接，弹窗提示前往设置打开权限
   * @param permissions 权限名称
   * @returns Map<Permissions, boolean> 对应权限的开关
   */
  requestPermissions(...permissions: Array<Permissions>): Promise<Map<Permissions, boolean>> {
    return new Promise<Map<Permissions, boolean>>((res, rej) => {
      let map = new Map<Permissions, boolean>()
      let ac = abilityAccessCtrl.createAtManager()
      ac.requestPermissionsFromUser(getContext(this), permissions).then(async (v: PermissionRequestResult) => {
        for (let index = 0; index < v.permissions.length; index++) {
          let permission = v.permissions[index] as Permissions
          let authResult = v.authResults[index]
          let first = v.dialogShownResults == undefined
          let i = permissions.indexOf(permission)
          if (i != -1) {
            console.log(authResult.toString())
            if (authResult == 0) {
              map.set(permission, true)
            } else if (authResult == -1) {
              map.set(permission, false)
              if (!first) {
                let req = await new PreferencesPermission().open(permissions.toString())
                if (req) {
                  ac.requestPermissionOnSetting(getContext(this), permissions)
                    .then((status: abilityAccessCtrl.GrantStatus[]) => {
                      status.forEach((s, i) => {
                        map.set(permissions[i], s == 0)
                      })
                      res(map)
                    })
                    .catch((e: Error) => {
                      rej(e)
                    })
                } else {
                  res(map)
                }
                return
              }
            }
          }
        }
        res(map)
      })
    })
  }

  /**
   * map 转化为Record类型
   * @param map
   * @returns
   */
  toRecord(map: Map<string, object>): Record<string, object> {
    let r: Record<string, object> = {}
    map.forEach((value, key) => {
      if (key !== undefined && value !== undefined) {
        r[key] = value;
      }
    })
    return r
  }

  /**
   * object 转化为map类型
   * @param obj
   * @returns
   */
  toMap<T = object>(obj: object): Map<string, T> {
    return new Map<string, T>(Object.entries(obj))
  }

  /**
   * 根据参数取数组
   * @param list
   * @param k
   * @returns
   */
  listParams<T>(list: object[], k: string): Array<T> {
    let l: Array<T> = []
    list.forEach((v) => {
      l.push(v[k] as T)
    })
    return l
  }

  /**
   * 计算当前组件的中心位置
   * @param e
   * @returns
   */
  toCenter(e: ClickEvent): Offset {
    let x = parseFloat(e.target.area.globalPosition.x!.toString())
    let y = parseFloat(e.target.area.globalPosition.y!.toString())
    let w = parseFloat(e.target.area.width.toString())
    let h = parseFloat(e.target.area.height.toString())
    let cenX = x + w / 2
    let cenY = y + h / 2
    return { dx: cenX, dy: cenY }
  }
}


class Window extends Tools {
  /**
   * 主window信息
   */
  main!: window.Window
  /**
   * 窗口属性
   */
  properties!: window.WindowProperties
  /**
   * Log 日志
   */
  log: LogUtils = new LogUtils()
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
    this.resize()
    this.setFullScreen()
    this.setOrientation()
  }

  /**
   * 设置打印日志
   * @param num:number = 100 设置日志展示的数量
   */
  openLog(num: number = 100) {
    this.log.max = 100
    this.log.sen.sensorNum()
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
      console.log("组件显示：" + info.name)
    }
  }

  /**
   * 监听路由跳转
   * @param info
   */
  routerPageUpdate(info: RouterPageInfo) {
    if (info.state == 0) {
      console.log("页面即将显示：" + info.name)
    }
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

export class Error extends Window {
  /**
   * 错误监听id
   */
  errorId: number = -1
  /**
   * 耗时监听id
   */
  observerId: number = -1
  /**
   * 错误监听方法
   */
  callback: errorManager.ErrorObserver = {
    onUnhandledException: (errMsg: string) => this.onUnhandledException(errMsg),
    onException: (errObject: globalThis.Error) => this.onException(errObject)
  }
  /**
   * 监听主线程消息处理耗时
   */
  observer: errorManager.LoopObserver = {
    onLoopTimeOut(timeout: number) {
      // console.log('Duration timeout: ' + timeout);
    }
  };

  /**
   * 开启监听主线程
   */
  onObserver() {
    errorManager.on("loopObserver", 1, this.observer);
  }

  /**
   * 关闭监听主线程
   */
  offObserver() {
    errorManager.off("loopObserver");
  }

  /**
   * 开启错误监听
   */
  onError() {
    this.observerId = errorManager.on('error', this.callback);
  }

  /**
   * 关闭错误监听
   */
  offError() {
    errorManager.off("error", this.errorId, (result) => {
      console.log('[Demo] result' + result.code + ';' + result.message);
    })
  }

  /**
   * 捕获的异常信息
   * @param errMsg 错误提示
   */
  onUnhandledException(errMsg: string) {
    console.log('产生未捕获异常时的回调，onUnhandledException:', errMsg);
  }

  /**
   * 捕获的JS异常信息
   * @param errObject:globalThis.Error 错误信息
   */
  onException(errObject: globalThis.Error) {
    console.log('产生异常上报JS层时的回调，onException', errObject);
    promptAction.showToast({ message: errObject.message })
    if (typeof (errObject.stack) === 'string') {
      console.log('onException, stack: ', errObject.stack);
    }
  }
}

class Global extends Error {
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

