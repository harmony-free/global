import { preferences } from '@kit.ArkData';
import { webview } from '@kit.ArkWeb';
import { uri } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { global } from './Global';

export class PreferencesError extends Error {
  name: string = "PreferencesError"
  message: string = "preferencesUtils is null !"
}

export class PreferencesUtils {
  private _preferencesUtils: preferences.Preferences;
  protected options: preferences.Options = { name: 'base' }

  constructor(option?: preferences.Options) {
    this._preferencesUtils = preferences.getPreferencesSync(getContext(), option ?? this.options);
  }

  get preferencesUtils(): preferences.Preferences {
    if (this._preferencesUtils == null) {
      throw new PreferencesError()
    }
    return this._preferencesUtils
  }

  get(key: string, def?: preferences.ValueType): preferences.ValueType {
    return this.preferencesUtils.getSync(key, def)
  }

  getForKeys(...keys: string[]): Map<string, preferences.ValueType> {
    let map: Map<string, preferences.ValueType> = new Map<string, preferences.ValueType>()
    keys.forEach((key) => {
      let value = this.get(key)
      map.set(key, value)
    })
    return map
  }

  getAll(): Object {
    return this.preferencesUtils.getAllSync();
  }

  getMap<T = object>(): Map<string, T> {
    return new Map<string, T>(Object.entries(this.getAll()))
  }

  put(key: string, value: preferences.ValueType) {
    this.preferencesUtils.putSync(key, value)
    this.preferencesUtils.flush()
  }

  putFlush(key: string, value: preferences.ValueType): Promise<void> {
    this.put(key, value)
    return this.flush();
  }

  putMap(map: Map<string, preferences.ValueType>) {
    map.forEach((v, k) => {
      this.put(k, v)
    })
  }

  putMapFlush(map: Map<string, preferences.ValueType>) {
    map.forEach((v, k) => {
      this.put(k, v)
    })
    this.flush()
  }

  has(key: string) {
    return this.preferencesUtils.hasSync(key)
  }

  delete(key: string) {
    if (this.has(key)) {
      this.preferencesUtils.deleteSync(key)
    }
  }

  deleteFlush(key: string) {
    if (this.has(key)) {
      this.delete(key)
      this.flush()
    }
  }

  flush(): Promise<void> {
    return this.preferencesUtils.flush();
  }

  clear() {
    this.preferencesUtils.clearSync();
  }

  clearFlush() {
    this.preferencesUtils.clearSync();
    this.flush()
  }

  keys(): string[] {
    return Object.keys(this.getAll());
  }

  values(): preferences.ValueType[] {
    return Object.values(this.getAll())
  }
}

export class PreferencesSystem extends PreferencesUtils {
  constructor() {
    super({ name: 'system' })
  }
}

export class PreferencesLog extends PreferencesUtils {
  constructor() {
    super({ name: 'log' })
  }
}

export class PreferencesPermission extends PreferencesUtils {
  constructor() {
    super({ name: 'permission' })
  }

  open(permission: string): Promise<boolean> {
    return new Promise<boolean>(async (res, rej) => {
      let isReq = new PreferencesPermission().get(permission, true)
      if (isReq == true) {
        let req: promptAction.ShowDialogSuccessResponse = await promptAction.showDialog({
          title: "权限被禁止",
          message: permission + "权限已被禁止，请修改系统设置开启。",
          buttons: [
            { text: "不再提示", color: '#000000' },
            { text: "修改", color: '#0000FF' }
          ]
        })
        if (req.index == 1) {
          res(true)
        } else {
          if (req.index == 0) {
            this.put(permission, false)
          }
          res(false)
        }
      } else {
        let req: promptAction.ShowDialogSuccessResponse = await promptAction.showDialog({
          title: "权限被禁止",
          message: "请前往：设置 > 隐私和安全 > 权限类型 > 具体应用 打开相关权限",
          buttons: [
            { text: "取消", color: '#000000' },
            { text: "去设置", color: '#0000FF' }
          ]
        })
        if (req.index == 1) {
          this.put(permission, true)
          global.toAppInfo()
        }
        res(false)
      }
    })
  }
}

export class WebCookieUtils {
  static install: WebCookieUtils = new WebCookieUtils()

  setCookie(url: string, value: string) {
    webview.WebCookieManager.configCookieSync(url, value);
  }

  setCookieSave(url: string, value: string): Promise<void> {
    this.setCookie(url, value)
    return this.save()
  }

  setCookieKeys(url: string, ...keys: string[]) {
    keys.forEach((key) => {
      // this.setCookieKey(url, key)
    })
  }

  // setCookieKey(url: string, key: string) {
  //   let value: string = PreferencesCookie.install.get(key) as string
  //   this.setCookie(url, value)
  // }

  // setCookieKeysSave(url: string, ...keys: string[]) {
  //   keys.forEach((key) => {
  //     this.setCookieKeySave(url, key)
  //   })
  // }

  // async setCookieUrl(url: Resource | string) {
  //   if (typeof url != "string") {
  //     url = await getContext().resourceManager.getStringValue(url.id)
  //   }
  //   let data: string[] = PreferencesCookie.install.get("cookie", []) as string[]
  //   this.setCookieList(url, data)
  // }

  setCookieList(url: string, list: string[]) {
    if (list == undefined || list.length == 0) {
      return
    }
    let currentUri = new uri.URI(url)
    const domain = currentUri.host
    const path = '/'
    // this.clear()
    list.forEach((value) => {
      value = `${value};domain=${domain};path=${path}`
      this.setCookie(url, value)
    })
    this.save()
  }

  // setCookieKeySave(url: string, key: string) {
  //   let value: string = PreferencesCookie.install.get(key) as string
  //   this.setCookieSave(url, value)
  // }


  getCookie(url: string) {
    webview.WebCookieManager.fetchCookieSync(url)
  }

  save(): Promise<void> {
    return webview.WebCookieManager.saveCookieAsync()
  }

  clear() {
    webview.WebCookieManager.clearAllCookiesSync()
  }
}
