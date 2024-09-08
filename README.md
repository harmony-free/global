# global

#### 介绍

这是一个全局相关参数,收集了系统相关信息,屏幕相关信息,打包版本信息系统参数,以及打印日志收集和错误日志收集。

1、刘海屏适配参数，top，bottom，contextWidth，contextHeight等屏幕参数。

2、window 沉浸式导航设置以及路由跳转监听。

3、app 包的信息，版本好，包名，打包环境等信息。

4、router 基于 Navigation封装的 router 使用方式和原router一致

5、Preferences 工具类，可直接引用或者继承。

#### 软件架构

软件架构说明

#### 安装教程

`ohpm install @free/loading`

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
