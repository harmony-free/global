import {
  abilityAccessCtrl,
  bundleManager,
  common,
  errorManager,
  PermissionRequestResult,
  Permissions,
  Want
} from '@kit.AbilityKit'
import { componentSnapshot, display, promptAction, router, window } from '@kit.ArkUI'
import { AnimatorUtils } from './AnimatorUtils'
import { LogUtils, SensorUtils } from './Log'
import { PreferencesPermission, PreferencesSystem } from './PreferencesUtils'
import { systemShare } from '@kit.ShareKit'
import { filePreview } from '@kit.PreviewKit'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { interactiveLiveness } from '@kit.VisionKit'
import { image } from '@kit.ImageKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { productViewManager, updateManager } from '@kit.StoreKit'
import { pushService } from '@kit.PushKit'


interface ContextDir {
  cacheDir: string
  cloudFileDir: string
  tempDir: string
  filesDir: string
  preferencesDir: string
  bundleCodeDir: string
  resourceDir: string
}

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
  /**
   * 像素密度
   */
  density: number
  /**
   * 帧率
   */
  hz: number
  /**
   * 设备id
   */
  id: number

  constructor() {
    this.dis = display.getDefaultDisplaySync()
    this.id = this.dis.id
    this.density = this.dis.densityPixels
    this.hz = this.dis.refreshRate
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
   * Log 日志
   */
  log: LogUtils = new LogUtils()
  /**
   * 摇晃传感器
   */
  sen: SensorUtils = new SensorUtils()
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
   * 推送token
   */
  pushToken!: string

  constructor() {
    super()
    this.stage()
  }

  getNavBarHeight(){
    return this.top + 44;
  }
  getTabBarHeight(){
    return this.bottom + 49 + 10;
  }
  getContentHeight(){
    return this.height - this.getNavBarHeight() - this.getTabBarHeight();
  }
  getContentNavBar(){
    return this.height - this.getTabBarHeight();
  }
  getContentTabBar(){
    return this.height - this.getNavBarHeight();
  }

  /**
   * 获取Context
   * @returns
   */
  getContext(): common.UIAbilityContext | undefined {
    return getContext() as common.UIAbilityContext
  }

  /**
   * 本地储存
   */
  get storage():PreferencesSystem{
    return new PreferencesSystem()
  }

  /**
   * 文件夹
   * @returns: ContextDir 文件夹路径
   */
  contextDir(): ContextDir | undefined {
    let context = this.getContext()
    if (context == undefined) {
      return undefined
    } else {
      return {
        cacheDir: context.cacheDir,
        cloudFileDir: context.cloudFileDir,
        tempDir: context.tempDir,
        filesDir: context.filesDir,
        preferencesDir: context.preferencesDir,
        bundleCodeDir: context.bundleCodeDir,
        resourceDir: context.resourceDir,
      }
    }

  }

  /**
   * 获取stage
   */
  protected stage() {
    let context = this.getContext()
    if (context == undefined) {
      setTimeout(() => {
        this.stage()
      }, 50)
    } else {
      this.setWindow(context.windowStage.getMainWindowSync())
    }
  }

  getToken(): Promise<string> {
    return new Promise<string>((res, rej) => {
      try {
        pushService.getToken().then((token) => {
          this.pushToken = token
          res(token)
        });
      } catch (err) {
        rej(err)
      }
    })
  }

  /**
   * 设置系统主窗口
   * @param main:window.Window 系统主窗口
   */
  setWindow(main: window.Window) {
    if (this.main == undefined) {
      this.main = main
      this.getToken()
      this.properties = this.main.getWindowProperties()
      this.main.on('windowSizeChange', () => this.resize())
      this.resize()
      this.setFullScreen()
      this.setOrientation()
    }
  }

  /**
   * 设置打印日志
   * @param type:"router"|"navigation" = "navigation" 设置路由模式 默认navigation
   * @param num:number = 20 设置手机摇晃幅度
   */
  openLog(type:"router"|"navigation" = "navigation",num: number = 20) {
    if (global.debug) {
      this.sen.num = num
      this.sen.type = type
      this.sen.open();
    }
  }
  /**
   * 关闭打印日志
   */
  closeLog(){
    this.sen.close();
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

class Tools extends Window {
  /**
   * 动画
   */
  animation: AnimatorUtils = new AnimatorUtils().run()



  /**
   * 打开应用权限管理
   */
  toAppInfo() {
    let context = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings', //设置应用bundleName
      abilityName: 'com.huawei.hmos.settings.MainAbility', //设置应用abilityName
      uri: "application_info_entry", //应用管理页面
      parameters: {
        pushParams: {
          bundleName: context.abilityInfo.bundleName//拉起方应用包名
        }
      }
    }
    context.startAbility(want)
  }



  /**
   * 打开网页
   * @param url 网页地址
   */
  toWeb(url:string){
    let context = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      abilityName: 'MainAbility',
      uri: url,
    }
    context.startAbility(want)
  }

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
                      this.toAppInfo()
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
   * 分享弹窗
   * @param record: systemShare.SharedRecord 弹窗数据
   * import { uniformTypeDescriptor as utd } from '@kit.ArkData';
   * utd:string 统一数据类型，参考[https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-data-uniformtypedescriptor] (标准化数据定义与描述)
   * @returns
   */
  share(record: systemShare.SharedRecord): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      let data: systemShare.SharedData = new systemShare.SharedData(record);
      let controller: systemShare.ShareController = new systemShare.ShareController(data);
      let context = this.getContext()
      if (context != undefined) {
        if (record.thumbnail != undefined && record.thumbnail.byteLength > 32 * 1024) {
          console.log("thumbnail size is not 32Kb")
          rej("thumbnail size is not 32Kb")
        } else {
          let callback = () => {
            res(true)
            controller.off('dismiss', callback);
          };
          controller.on('dismiss', callback);
          controller.show(context, {
            previewMode: systemShare.SharePreviewMode.DETAIL,
            selectionMode: systemShare.SelectionMode.SINGLE
          });
        }
      } else {
        rej("context is not find")
      }
    })
  }

  /**
   * 文件预览
   * @param info: filePreview.PreviewInfo 预览信息 详情请查看
   * 详情请查看 {@link https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/preview-introduction }
   */
  preview(info: filePreview.PreviewInfo) {
    let context = this.getContext()
    if (context != undefined) {
      let displayInfo: filePreview.DisplayInfo = {
        x: 100,
        y: 100,
        width: 800,
        height: 800
      };
      filePreview.openPreview(context, info, displayInfo).then(() => {
        console.info('Succeeded in opening preview');
      }).catch((err: BusinessError) => {
        console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
      });
    }
  }

  /**
   * app检查更新
   * @returns: boolean 是否更新成功
   */
  appUpdate(): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      let context = this.getContext()
      if (context != undefined) {
        try {
          updateManager.checkAppUpdate(context).then((data: updateManager.CheckUpdateResult) => {
            if (data.updateAvailable == updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
              updateManager.showUpdateDialog(context).then((code: updateManager.ShowUpdateResultCode) => {
                res(code == updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS)
              }).catch((error: BusinessError) => {
                rej(error)
              })
            } else {
              rej({
                code: 10010,
                name: "updateManager",
                message: "version not update"
              })
            }
          }).catch((error: BusinessError) => {
            rej(error)
          })
        } catch (error) {
          rej(error)
        }
      } else {
        rej({
          code: 404,
          name: "updateManager",
          message: "context not found"
        })
      }
    })
  }

  /**
   * 打开要应用信息页面
   * @param bundleName: 引用包名
   * @returns: 是否打开
   */
  appProduct(bundleName: string): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      let context = this.getContext()
      if (context != undefined) {
        const wantParam: Want = {
          parameters: {
            // 此处填入要加载的应用包名，例如： bundleName: 'com.huawei.hmsapp.books'
            bundleName: bundleName
          }
        }
        const callback: productViewManager.ProductViewCallback = {
          onError: (error: BusinessError) => {
            if (error.code == 0) {
              res(true)
            } else {
              let want: Want = {
                action: 'ohos.want.action.appdetail', //隐式指定action为ohos.want.action.appdetail
                uri: 'store://appgallery.huawei.com/app/detail?id=' + bundleName, //  bundleName为需要打开应用详情的应用包名
              };
              context!.startAbility(want).then(() => {
                res(true)
              }).catch((error: BusinessError) => {
                res(false)
                rej(error)
              });
            }
          }
        }
        productViewManager.loadProduct(context, wantParam, callback);
      } else {
        rej({
          code: 404,
          name: "productViewManager",
          message: "context not found"
        })
      }
    })
  }

  /**
   * 复制到粘贴板
   * @param text: string 复制内容
   */
  copy(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        promptAction.showToast({ message: '复制成功' });
      } else {
        promptAction.showToast({ message: '复制失败' });
      }
    })
  }

  /**
   * 黏贴
   */
  paste(): pasteboard.PasteData {
    const systemPasteboard = pasteboard.getSystemPasteboard();
    let data = systemPasteboard.getDataSync()
    return data
  }

  /**
   * 截屏组件 和 系统截屏
   * @param key: string 被截屏的组件
   * @param options
   * @returns
   */
  snapshot(key?: string,
    options: componentSnapshot.SnapshotOptions = {
      scale: this.density,
      waitUntilRenderFinished: true
    }): Promise<image.PixelMap> {
    return new Promise<image.PixelMap>((res, rej) => {
      if (key == undefined) {
        this.main.snapshot((err, data) => {
          if (data) {
            res(data)
          } else {
            console.log(err.message)
            rej(err)
          }
        })
      } else {
        componentSnapshot.get(key, (err, data) => {
          if (data) {
            res(data)
          } else {
            console.log(err.message)
            rej(err)
          }
        }, options)
      }

    })
  }

  /**
   * 保存图片到相册
   * @param data: ArrayBuffer | image.PixelMap 图片数据
   * @returns: boolean 是否保存成功
   */
  async savePhoto(data: ArrayBuffer | image.PixelMap): Promise<boolean> {
    return new Promise<boolean>(async (res, rej) => {
      let context = this.getContext()
      if (context == undefined) {
        rej(false)
      } else {
        try {
          await global.requestPermissions("ohos.permission.WRITE_IMAGEVIDEO")
          let helper = photoAccessHelper.getPhotoAccessHelper(context);
          let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
          let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          if (!(data instanceof ArrayBuffer)) {
            let packer = image.createImagePacker()
            data = await packer.packing(data, { format: "image/png", quality: 100 })
          }
          await fileIo.write(file.fd, data);
          await fileIo.close(file.fd);
          promptAction.showToast({ message: '保存到相册' })
          res(true)
        } catch (error) {
          rej(false)
        }
      }
    })
  }

  /**
   * 人脸识别
   * @param options: interactiveLiveness.InteractiveLivenessConfig 人脸识别配置信息
   * @returns: interactiveLiveness.InteractiveLivenessResult 人脸识别后图片
   */
  async face(options: interactiveLiveness.InteractiveLivenessConfig = {
    actionsNum: 1 as interactiveLiveness.ActionsNumber,
    isSilentMode: "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode,
    routeMode: "back" as interactiveLiveness.RouteRedirectionMode
  }): Promise<interactiveLiveness.InteractiveLivenessResult> {
    return new Promise(async (res, rej) => {
      let map = await global.requestPermissions("ohos.permission.CAMERA", "ohos.permission.PRIVACY_WINDOW")
      if (map.get("ohos.permission.CAMERA") == false) {
        rej("需要打开ohos.permission.CAMERA权限")
      } else if (options.isPrivacyMode == false &&
        map.get("ohos.permission.PRIVACY_WINDOW") == false) {
        rej("需要打开ohos.permission.PRIVACY_WINDOW权限")
      } else {
        interactiveLiveness.startLivenessDetection(options,
          (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
            if (result != undefined && err.code == 0) {
              res(result)
            } else {
              rej(err ?? "result is undefined")
              return;
            }
          })
      }
    })
  }

  /**
   * 打开应用
   * @param url: 应用地址
   * @returns: 是否打开
   */
  openLink(url: string): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      try {
        // 判断是否安装应用
        // module.json5 中设置 检查安装名称 "querySchemes": [],
        if (bundleManager.canOpenLink(url)) {
          let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
          context.startAbility({
            uri: url
          }, (err: BusinessError) => {
            res(err.code == 0)
            console.log(err.message)
          })
        } else {
          rej("没有找到该应用")
        }
      } catch (e) {
        console.log(JSON.stringify(e))
        rej(e)
      }
    })

  }

  /**
   * 生成随机UUID
   * @returns
   */
  generateUUID(): string {
    return 'xxxxyxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  /**
   * 滑动动效
   * @param edge 滑出方式
   * @returns 返回动效
   */
  moveEffect(edge: TransitionEdge | undefined, duration: number = 200): TransitionEffect {
    return TransitionEffect.asymmetric(
      TransitionEffect.move(edge).animation({ duration: duration })
      ,
      TransitionEffect.move(edge).animation({ duration: duration })
    )
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

  getParams<T = Map<string,object>>(key?:string):T | object | undefined{
    if (router.getParams() == undefined){
      return undefined;
    }
    if (key!=undefined) {
      return (router.getParams() as Map<string,object>)[key];
    }
    return router.getParams() as T
  }
}

export class Error extends Tools {
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
  /**
   * 应用程序的accessTokenID
   */
  tokenId: number

  constructor() {
    super()
    /**
     * 使用前需要在 windowStage.loadContent 中设置使用 globalInfo.setWindow(w) 设置mainWindow
     */
    const flags: bundleManager.BundleFlag =
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE

    this.bundleInfo = bundleManager.getBundleInfoForSelfSync(flags)
    this.appInfo = this.bundleInfo.appInfo
    this.version = this.bundleInfo.versionName
    this.bundleName = this.appInfo.name
    this.appName = this.appInfo.label
    this.env = this.appInfo.appProvisionType
    this.releaseType = this.appInfo.releaseType
    this.release = this.appInfo.appProvisionType == 'release'
    this.debug = this.appInfo.appProvisionType == 'debug'
    this.uid = this.appInfo.uid
    this.tokenId = this.appInfo.accessTokenId
  }
}

export const global = new Global()

