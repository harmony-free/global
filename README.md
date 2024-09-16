# global

#### 介绍

这是一个全局功能,全局信息、请求权限、日志信息、异常捕获、Navigation路由封装、首选项才存储封装、屏幕适配等app相关信息。

1、刘海屏适配参数，top，bottom，contextWidth，contextHeight等屏幕参数。

2、window 沉浸式导航设置以及路由跳转监听。

3、app 包的信息，版本好，包名，打包环境等信息。

4、router 基于 Navigation封装的 router 使用方式和原router一致

5、Preferences 工具类，可直接引用或者继承。

| 主要功能 | 模块          | 使用方式                                                            | 介绍                                                                                                 |
|------|-------------|-----------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| 全局信息 | global      | ~~global.setWindow(windowStage.getMainWindowSync())~~(不在需要手动获取) | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Global.ets)           |
| 请求权限 | permissions | global.requestPermissions() // 非首次请求会弹窗提示，点击不再提示将不再提示           | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Global.ets)           |
| 日志信息 | Log         | global.openLog() // 摇晃手机会打开日志                                   | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Log.ets)              |
| 异常捕获 | Error       | global.onError() // 开启异常捕获 <br/> global.offError() // 关闭异常捕获    | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Global.ets)           |
| 路由信息 | router      | router.push(name:string) // 跳转页面 <br/> router.back() // 返回上一页面  | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/Router.ets)           |
| 首选项  | Preferences | PreferencesUtils // 可以继承                                        | [详细代码](https://gitee.com/harmony-free/global/blob/master/src/main/ets/system/PreferencesUtils.ets) |

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

2、设置主window：在 EntryAbility 文件 onWindowStageCreate 方法中添加代码

`global.setWindow(windowStage.getMainWindowSync())`

```
  onWindowStageCreate(windowStage: window.WindowStage): void {
    ...
    global.setWindow(windowStage.getMainWindowSync())
    ...
  }
```

3、开启打印日志功能：在 EntryAbility 文件 onCreate 方法中添加代码

`global.openLog()`

```
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    global.openLog()
    ...
  }
```

4、开启错误拦截功能：在 EntryAbility 文件 onCreate 方法中添加代码

`global.onError()`

```
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    global.onError()
    ...
  }
```

5、关闭错误拦截功能：在 EntryAbility 文件 onCreate 方法中添加代码

`global.offError()`

```
  onDestroy(): void {
    global.offError()
    ...
  }
```

##### 二、router使用方式

1、引入头文件

`import { NavBar, router, routerMap } from '@free/global';`

2、将 `router.navPathStack` 添加到 `Navigation`

3、在 `Navigation` 设置 `.navDestination(routerMap)`

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

6、待跳转的组件 `NamePage`

7、返回上个页面 `router.back(new Object())` 参数是传到上个页面的参数

```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage() // 待跳转的组件
  }.hideTitleBar(true) // 隐藏默认导航
}

router.requestBuilder("name", wrapBuilder(NameBuilder)) // 注册组件到路由容器中

@Component
export struct NamePage {
  build() {
    Text("返回")
    .onClick(() => {
       router.back(new Object())
    })
  }
}
```

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
