/**
 * 使用的时候需要注册相关@Builder组件
 */
import * as nav from '../components/NavBar'

/**
 * Router回调用的参数
 */
interface RouterCallBackFace {
  name: string
  resp: RouterResp
  res: (value: RouterRespFace | PromiseLike<RouterRespFace>) => void
}

/**
 * Router回调用的参数
 */
class RouterCallBack implements RouterCallBackFace {
  name: string
  resp: RouterResp = new RouterResp()
  res: (value: RouterRespFace | PromiseLike<RouterRespFace>) => void =
    (value: RouterRespFace | PromiseLike<RouterRespFace>) => {
    }

  constructor(name: string, res: (value: RouterRespFace | PromiseLike<RouterRespFace>) => void) {
    this.name = name
    this.res = res
  }
}

/**
 * Router:返回数据
 */
interface RouterRespFace {
  code: number
  message: string
  error: Error | undefined
  data: object | undefined
}

/**
 * Router:返回数据
 */
class RouterResp implements RouterRespFace {
  code: number = 0
  message: string = "跳转成功"
  error: Error | undefined = undefined
  data: object | undefined = undefined
}


/**
 * Router:系统Map数据
 */
interface RouterInfoFace {
  name: string
  pageSourceFile: string
  buildFunction: string
  moduleName: string
}


/**
 * Router: 实体接口类
 */
interface RouterFace {
  push(url: string, params?: object, animation?: boolean): Promise<RouterRespFace>

  replace(url: string, params?: object, animation?: boolean): Promise<RouterRespFace>

  pop(params: object, animation?: boolean): Promise<RouterRespFace>

  // remove(id: number | string): Promise<RouterRespFace>
  //
  // clear(): Promise<RouterRespFace>
}

/**
 * Router: 实体类
 */
class Router implements RouterFace {
  navPathStack: NavPathStack = new NavPathStack();
  routerMap: Map<string, RouterInfoFace> = new Map();
  callBack: Array<RouterCallBack> = new Array<RouterCallBack>()
  builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();
  is404: boolean = true

  constructor() {
    this.navPathStack.setInterception({
      willShow: (from: NavDestinationContext | NavBar) => {
      }
    })
  }

  /**
   * 注册builder
   * @param name builder 名称标识
   * @param builder 全局UI组件
   */
  requestBuilder(name: string, builder: WrappedBuilder<[object]>) {
    this.builderMap.set(name, builder)
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
   * 路由跳转
   * @param name:string | WrappedBuilder 需要跳转的页面名称或者页面组件
   * @param params 跳转传入的参数
   * @param animation 跳转动画
   * @returns
   */
  push(name: string | WrappedBuilder<[object]>, params?: object,
    animation?: boolean | undefined): Promise<RouterRespFace> {
    return new Promise<RouterRespFace>((res, rej) => {
      let url = ""
      if (typeof name != 'string') {
        url = this.generateUUID()
        this.requestBuilder(url, name)
      } else {
        url = name
      }
      if (!this.builderMap.has(url) && !this.is404) {
        return;
      }
      this.callBack.push(new RouterCallBack(url, res))
      this.navPathStack.pushPathByName(url, params, animation)
    })
  }

  /**
   * 路由重载
   * @param name:string | WrappedBuilder 需要重载的页面名称或者页面组件
   * @param params 跳转传入的参数
   * @param animation 跳转动画
   * @returns
   */
  replace(name: string | WrappedBuilder<[object]>, params?: object,
    animation?: boolean | undefined): Promise<RouterRespFace> {
    return new Promise<RouterRespFace>((res, rej) => {
      let url = ""
      if (typeof name != 'string') {
        url = this.generateUUID()
        this.requestBuilder(url, name)
      } else {
        url = name
      }
      if (!this.builderMap.has(url) && !this.is404) {
        return;
      }
      this.call()
      this.callBack.push(new RouterCallBack(url, res))
      this.navPathStack.replacePathByName(url, params, animation)
    })
  }

  back(params?: object, animation?: boolean | undefined): Promise<RouterRespFace> {
    return new Promise<RouterRespFace>((res, rej) => {
      this.call(params)
      this.navPathStack.pop(params, animation)
    })
  }

  backName(name: string, params?: object,
    animation?: boolean | undefined): Promise<RouterRespFace> {
    return new Promise<RouterRespFace>((res, rej) => {
      if (!this.builderMap.has(name)) {
        if (this.is404) {
          this.push("")
        } else {
          return;
        }
      } else {
        this.callName(name, params)
        this.navPathStack.popToName(name, params, animation)
      }
    })
  }

  pop(params?: object, animation?: boolean | undefined): Promise<RouterRespFace> {
    return new Promise<RouterRespFace>((res, rej) => {
      this.call(params)
      this.navPathStack.pop(params, animation)
    })
  }

  builder(url: string): WrappedBuilder<[object]> | undefined {
    return this.builderMap.get(url)
  }

  private callName(name: string, params?: object) {
    let url = this.call(params)
    if (url != undefined) {
      if (url != name) {
        this.call(params)
      }
    }
  }

  private call(params?: object): string | undefined {
    let call = this.callBack.pop()
    if (call) {
      call.resp.data = params
      call.res(call.resp)
      return call.name
    }
    return undefined
  }

  size(): number {
    return this.navPathStack.size()
  }

  // remove(id: string | number): Promise<RouterRespFace> {
  //   return new Promise<RouterRespFace>((res, rej) => {
  //     let resp = new RouterResp()
  //     res(resp)
  //   })
  // }
  //
  // clear(): Promise<RouterRespFace> {
  //   return new Promise<RouterRespFace>((res, rej) => {
  //
  //   })
  // }
}

/**
 * 在Navigation 页面 navDestination 注册 routerMap方法
 * @param builderName
 * @param p
 */

@Builder
export function routerMap(builderName: string, p: object) {
  if (router.builderMap.has(builderName)) {
    router.builder(builderName)!.builder(p)
  } else {
    wrapBuilder(page404).builder({ name: builderName, state: 404 })
  }
}

/**
 * 系统默认页面参数
 */
interface PageState {
  name?: string
  state?: number
  msg?: string
}

/**
 * 系统默认404页面
 * @param o:PageState 传参对象
 */
@Builder
export function page404(o: PageState) {
  NavDestination() {
    nav.NavBar({ title: "页面未找到" })
    Text() {
      Span('404\n').fontSize(30)
      Span(`很抱歉，您所访问的页面${o.name}不存在\n，请联系系统管理员~`)
    }.textAlign(TextAlign.Center).margin({ top: 50 })
  }.hideTitleBar(true)
}

export const router = new Router()

