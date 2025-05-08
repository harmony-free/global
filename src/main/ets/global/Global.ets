import { BaseGlobal } from './BaseGlobal';
import { bundleManager } from '@kit.AbilityKit';
import { System } from './System';
import { Window } from './Window';
import { Tools } from './Tools';
import { applyMixins } from '../mixins/Mixins';
import { Error } from './Error';
import { Utils } from './Utils';


export class Global extends BaseGlobal{
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

applyMixins(Global,[System,Window,Tools,Error,Utils])

export const global = new Global()
