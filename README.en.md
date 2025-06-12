# global

#### Description [中文](README.md)

This is a global function that includes global information, request permissions, log information, exception handling, Navigation routing encapsulation, preference storage encapsulation, screen adaptation, and other app-related information.

1. Top screen adaptation parameters include top, bottom, contextWidth, contextHeight, and other screen-related parameters.

2. Window immersive navigation settings and route jump event listening.

3. Information about the app package, including version, package name, packaging environment, etc.

4. The router based on Navigation for encapsulation has the same usage method as the original router.

5. The Preferences utility class, which can be directly referenced or inherited.

#### Software Architecture


| Main function       | Module      | Usage method                                  | Introduction                                              |
|---------------------|-------------|-----------------------------------------------|-----------------------------------------------------------|
| Global information  | global      | global.setWindow(mainWindow)                  | [Detailed code](src/main/ets/system/Global.ets)           |
| Request permission  | permissions | global.requestPermissions()                   | [Detailed code](src/main/ets/system/Global.ets)           |
| Log information     | Log         | global.openLog()                              | [Detailed code](src/main/ets/system/Log.ets)              |
| Exception handling  | Error       | global.onError()  <br/> global.offError()     | [Detailed code](src/main/ets/system/Global.ets)           |
| Routing information | router      | router.push(name:string)  <br/> router.back() | [Detailed code](src/main/ets/system/Router.ets)           |
| Preferences         | Preferences | PreferencesUtils                              | [Detailed code](src/main/ets/system/PreferencesUtils.ets) |

| Global information       | api               | Introduction                                                                                                                             |
|--------------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| Screen information       | global.dis        | [Detailed document](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-display-V5#displaygetdisplaybyidsync12) |
| Main window information  | global.main       | [Detailed document](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-window-V5)                              |
| Application information  | global.appInfo    | [Detailed document](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-applicationinfo-V5)       |
| build information        | global.bundleInfo | [Detailed document](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-bundleinfo-V5)            |
| Top screen height        | global.top        | It was calculated that                                                                                                                   |
| Bottom screen height     | global.bottom     | It was calculated that                                                                                                                   |
| Content width            | global.width      | It was calculated that                                                                                                                   |
| Content height           | global.height     | It was calculated that                                                                                                                   |
| Application Name         | global.appName    | It was calculated that                                                                                                                   |
| Application package name | global.bundleName | It was calculated that                                                                                                                   |
| Version number           | global.version    | It was calculated that                                                                                                                   |
| Packaging environment    | global.env        | It was calculated that                                                                                                                   |

#### Installation

`ohpm install @free/global`

#### Instructions


##### 一、Usage method of global parameters

1、Include the header file

`import { global } from '@free/global';`


2、Enable error interception function: Add the following code in the onCreate method of the EntryAbility file

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

3、Disable error interception function: Add the following code in the onCreate method of the EntryAbility file

`global.offError()`

```
  onDestroy(): void {
    global.offError()
    ...
  }
```

4、Enable the print log function: Add the following code in the onCreate method of the EntryAbility file

`global.openLog()`

```
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // type:"router"|"navigation" = "navigation" Set routing mode to default "navigation"
    // num:number = 20 Set the shaking amplitude of the mobile phone
    global.openLog()
    ...
  }
  
  onDestroy(): void {
    global.closeLog()
    ...
  }
  
```
Configure the rout
```
/// index.ets file
import { router, routerMap } from '@free/global';

// Configure router.navPathStack and routerMap using the Navigation router from '@free/global' (as shown below)
Navigation(router.navPathStack){}.navDestination(routerMap)

```

##### 二、router Usage method

1、Include the header file

`import { NavBar, router, routerMap } from '@free/global';`

2、`router.navPathStack` Add to `Navigation`
`Navigation(router.navPathStack)`

3、Then, in the `Navigation` section, set `.navDestination(routerMap)`
`Navigation(router.navPathStack){}.navDestination(routerMap)`

4、Perform a route jump using `router.push("name", new Object())`, where the first parameter is the component to be jumped to, and the second parameter is the data to be passed.

5、Receive the data sent back from the next page through `then`.

6、Provided navigation components `NavBar({ title: "home" })`

```
struct RootPage {
  @State message: string = 'Hello World';

  build() {
    Navigation(router.navPathStack) {
      NavBar({ title: "home" })
      Text(this.message).onClick(() => {
        router.push("name",new Object()).then((o:object)=>{
            
        })
      })
    }.navDestination(routerMap)
  }
}
```

7、The component to be redirected is `NamePage`. The parameter `router.back(new Object())` returned is the parameter passed to the previous page.

```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage({o:o}) 
  }.hideTitleBar(true) // Hide default navigation
}

router.requestBuilder("name", wrapBuilder(NameBuilder)) // Register the component to the route container

@Component
export struct NamePage {
  o: object | undefined 
  build() {
    Text("back")
    .onClick(() => {
       router.back(new Object())
    })
  }
}
```
Note: Router navigation requires registration of the component.
```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage() // The component to be redirected
  }.hideTitleBar(true) // Hide default navigation
}

router.requestBuilder("name", wrapBuilder(NameBuilder)) // Register the component to the route container
```


#### Contribution

1. Fork the repository
2. Create Feat_xxx branch
3. Commit your code
4. Create Pull Request

#### Gitee Feature

1. You can use Readme\_XXX.md to support different languages, such as Readme\_en.md, Readme\_zh.md
2. Gitee blog [blog.gitee.com](https://blog.gitee.com)
3. Explore open source project [https://gitee.com/explore](https://gitee.com/explore)
4. The most valuable open source project [GVP](https://gitee.com/gvp)
5. The manual of Gitee [https://gitee.com/help](https://gitee.com/help)
6. The most popular members  [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
