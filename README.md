# global

#### 介绍 [English](README.en.md)

这是一个全局功能,全局信息、请求权限、日志信息、异常捕获、Navigation路由封装、首选项才存储封装、屏幕适配等app相关信息。

1、刘海屏适配参数，top，bottom，contextWidth，contextHeight等屏幕参数。

2、window 沉浸式导航设置以及路由跳转监听。

3、app 包的信息，版本好，包名，打包环境等信息。

4、router 基于 Navigation封装的 router 使用方式和原router一致

5、Preferences 工具类，可直接引用或者继承。

| 主要功能 | 模块          | 使用方式                                                           | 介绍                                                                                                 |
|------|-------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| 全局信息 | global      | global.setWindow(mainWindow)                                   | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Global.ets)           |
| 请求权限 | permissions | // 权限请求会弹窗提示<br/>global.requestPermissions()                   | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Global.ets)           |
| 日志信息 | Log         | // 摇晃手机会打开日志 <br/>global.openLog()                             | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Log.ets)              |
| 异常捕获 | Error       | global.onError() // 开启异常捕获 <br/> global.offError() // 关闭异常捕获   | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Global.ets)           |
| 路由信息 | router      | router.push(name:string) // 跳转页面 <br/> router.back() // 返回上一页面 | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Router.ets)           |
| 首选项  | Preferences | PreferencesUtils // 可以继承                                       | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/PreferencesUtils.ets) |

| global信息  | api               | 介绍                                                                                                                          |
|-----------|-------------------|-----------------------------------------------------------------------------------------------------------------------------|
| 屏幕信息      | global.dis        | [详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-display-V5#displaygetdisplaybyidsync12) |
| 主window信息 | global.main       | [详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-window-V5)                              |
| 应用信息      | global.appInfo    | [详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-applicationinfo-V5)       |
| 打包信息      | global.bundleInfo | [详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-bundleinfo-V5)            |
| 刘海屏高度     | global.top        | 计算得出                                                                                                                        |
| 底部凹陷高度    | global.bottom     | 计算得出                                                                                                                        |
| 内容宽度      | global.width      | 计算得出                                                                                                                        |
| 内容高度      | global.height     | 计算得出                                                                                                                        |
| 应用名称      | global.appName    | 计算得出                                                                                                                        |
| 应用包名      | global.bundleName | 计算得出                                                                                                                        |
| 版本号       | global.version    | 计算得出                                                                                                                        |
| 打包环境      | global.env        | 计算得出                                                                                                                        |

#### 软件架构

软件架构说明

#### 安装教程

`ohpm install @free/global`

#### 使用说明

##### 一、全局参数使用方式

1、引入头文件

`import { global } from '@free/global';`

~~2、设置主window：在 EntryAbility 文件 onWindowStageCreate 方法中添加代码~~

`global.setWindow(windowStage.getMainWindowSync())`

```
  onWindowStageCreate(windowStage: window.WindowStage): void {
    ...
    global.setWindow(windowStage.getMainWindowSync())
    ...
  }
```


3、开启错误拦截功能：在 EntryAbility 文件 onCreate 方法中添加代码

`global.onError()`

```
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    global.onError()
    ...
  }
  
  onDestroy(): void {
    global.offError()
    ...
  }
```

4、关闭错误拦截功能：在 EntryAbility 文件 onCreate 方法中添加代码

`global.offError()`

```
  onDestroy(): void {
    global.offError()
    ...
  }
```

5、开启打印日志功能：在 EntryAbility 文件 onCreate 方法中添加代码

`global.openLog()`

```
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // type:"router"|"navigation" = "navigation" 设置路由模式 默认navigation
    // num:number = 20 设置手机摇晃幅度
    global.openLog()
    ...
  }
  
  onDestroy(): void {
    global.closeLog()
    ...
  }
  
```
配置 router
```
/// index.ets 文件
import { router, routerMap } from '@free/global';

// 配置 router.navPathStack 和 routerMap 使用 '@free/global' 中的 Navigation 路由 Router（如下）
Navigation(router.navPathStack){}.navDestination(routerMap)

```

##### 二、router使用方式

1、引入头文件

`import { NavBar, router, routerMap } from '@free/global';`

2、将 `router.navPathStack` 添加到 `Navigation`
`Navigation(router.navPathStack)`

3、再 `Navigation` 设置 `.navDestination(routerMap)`
`Navigation(router.navPathStack){}.navDestination(routerMap)`

4、通过 `router.push("name",new Object())` 进行路由跳转,第一个参数是待跳转组件，第二个参数为传递数据

5、通过 `then` 接受下个页面回传过来的数据

6、提供了导航组件 `NavBar({ title: "首页" })`

```
struct RootPage {
  @State message: string = 'Hello World';

  build() {
    Navigation(router.navPathStack) {
      NavBar({ title: "首页" })
      Text(this.message).onClick(() => {
        router.push("name",new Object()).then((o:object)=>{
            // o 为下个页面传回的数据
        })
      })
    }.navDestination(routerMap)
  }
}
```

7、待跳转的组件 `NamePage`，返回上个页面 `router.back(new Object())` 参数是传到上个页面的参数

```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage({o:o}) // 待跳转的组件,o为传递数据 可以不传
  }.hideTitleBar(true) // 隐藏默认导航
}

router.requestBuilder("name", wrapBuilder(NameBuilder)) // 注册组件到路由容器中

@Component
export struct NamePage {
  /// 接收数据
  o: object | undefined 
  build() {
    Text("返回")
    .onClick(() => {
       router.back(new Object())
    })
  }
}
```
注意：router 跳转 需要注册组件
```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage() // 待跳转的组件
  }.hideTitleBar(true) // 隐藏默认导航
}

router.requestBuilder("name", wrapBuilder(NameBuilder)) // 注册组件到路由容器中
```

#### 插件明细

hello 各位同学，大家好！ 今天我们来讲讲关于鸿蒙里常用的global全局属性。在开发的过程中通常会需要获取屏幕的宽度、高度、横竖屏、应用相关信息、打包相关信息等与app开发相关的信息

一、屏幕信息Display[详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-display-V5#displaygetdisplaybyidsync12)

1、屏幕的宽高
```arkts
// 屏幕相关信息
let dis = display.getDefaultDisplaySync()
// 屏幕宽度
this.width = px2vp(dis.width)
// 屏幕高度
this.height = px2vp(dis.height)

```

2、刘海屏幕、挖空屏上下占据的高度

```arkts
// 屏幕顶部占据的高度
let top = this.main.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
// 屏幕底部占据的高度
let bottom = this.main.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
// px转换vp
top = px2vp(top)
bottom = px2vp(bottom)
```

3、屏幕内容宽高以及导航栏选择栏的高度

```arkts
// 屏幕宽度
let contextWidth = width
// 屏幕高度
let contextHeight = height - bottom - top
// 导航栏高度
let navBarHeight = top + 44;
// 选择栏高度
let tabBarHeight = bottom + 49 + 10;
// 内容高度
let contentHeight = height - navBarHeight - tabBarHeight
// 内容加导航栏高度
let contentNavBar = height - tabBarHeight
// 内容加导航栏高度
let contentTabBar = height - navBarHeight
```

二、应用相关信息[详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-applicationinfo-V5)


```arkts
// 应用相关信息
let appInfo = bundleManager.getBundleInfoForSelfSync(flags).appInfo
// 应用包名
appInfo.name
// 应用名称
appInfo.label
// 应用环境
appInfo.appProvisionType
// 打包环境
appInfo.releaseType
// tokenId
appInfo.accessTokenId

```

三、打包相关信息[详细文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-bundleinfo-V5)

```arkts
// 打包信息
bundleInfo = bundleManager.getBundleInfoForSelfSync(flags)
// 版本号
bundleInfo.versionName
// 签名信息
bundleInfo.signatureInfo
// 安装时间
bundleInfo.installTime
// 作者
bundleInfo.vendor
```

注意：完整代码我已提交到[鸿蒙三方库](https://ohpm.openharmony.cn/#/cn/home)中，使用一下命令安装


```
ohpm install @free/global
```


调用方式

```arkts
// 屏幕相关信息等...
global.top
global.bottom
global.width
global.height
global.getNavBarHeight()
global.getTabBarHeight()
global.getContentHeight()
global.getContentNavBar()
global.getContentTabBar()
// 应用相关信息等...
global.appInfo
global.appName
global.bundleName
global.env
global.releaseType
global.release
global.debug
global.tokenId
// 打包相关信息...
global.bundleInfo
global.bundleInfo.signatureInfo
global.bundleInfo.installTime
global.bundleInfo.vendor
global.bundleInfo.name
```

喜欢本篇内容的话给个小爱心！



#### 参与贡献

1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

#### 特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5. Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6. Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
