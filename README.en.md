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

#### Plugin Details

Hello, dear students! Good morning! Today, we are going to talk about the commonly used "global" attributes in HarmonyOS. During the development process, it is often necessary to obtain information related to the screen size (width and height), orientation (portrait or landscape), application-related information, packaging-related information, etc., which is all about app development.

一、Screen Information Display [Detailed Documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-display-V5#displaygetdisplaybyidsync12)

1、The width and height of the screen
```arkts
// Screen-related information
let dis = display.getDefaultDisplaySync()
// Screen width 
this.width = px2vp(dis.width)
//  Screen height
this.height = px2vp(dis.height)

```

2、The height occupied by the liuhai screen and the notch screen from top to bottom

```arkts
// The height occupied by the top of the screen
let top = this.main.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
// The height occupied at the bottom of the screen
let bottom = this.main.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
// px Conversion vp
top = px2vp(top)
bottom = px2vp(bottom)
```

3、The width and height of the screen content as well as the height of the selection bar in the navigation bar

```arkts
// Screen width
let contextWidth = width
// Screen height
let contextHeight = height - bottom - top
// Navigation bar height
let navBarHeight = top + 44;
// Height of the selection bar
let tabBarHeight = bottom + 49 + 10;
// Content Height
let contentHeight = height - navBarHeight - tabBarHeight
// Content height plus navigation bar height
let contentNavBar = height - tabBarHeight
// Content height plus navigation bar height
let contentTabBar = height - navBarHeight
```

二、Application-related information [Detailed document](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-applicationinfo-V5)


```arkts
// Application-related Information
let appInfo = bundleManager.getBundleInfoForSelfSync(flags).appInfo
// Application package name
appInfo.name
// Application Name
appInfo.label
// Application Environment
appInfo.appProvisionType
// Packaging environment
appInfo.releaseType
// tokenId
appInfo.accessTokenId

```

三、Package the relevant information [Detailed Document](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-bundlemanager-bundleinfo-V5)

```arkts
// Packaging information
bundleInfo = bundleManager.getBundleInfoForSelfSync(flags)
// Version number
bundleInfo.versionName
// Signature information
bundleInfo.signatureInfo
// 安装时间
bundleInfo.installTime
// Author
bundleInfo.vendor
```

Note: The complete code has been submitted to [HarmonyOS Third-Party Library](https://ohpm.openharmony.cn/#/cn/home),Use the following command to install.


```
ohpm install @free/global
```


Calling method

```arkts
// Screen-related information, etc....
global.top
global.bottom
global.width
global.height
global.getNavBarHeight()
global.getTabBarHeight()
global.getContentHeight()
global.getContentNavBar()
global.getContentTabBar()
// Apply relevant information, etc....
global.appInfo
global.appName
global.bundleName
global.env
global.releaseType
global.release
global.debug
global.tokenId
// Package the relevant information...
global.bundleInfo
global.bundleInfo.signatureInfo
global.bundleInfo.installTime
global.bundleInfo.vendor
global.bundleInfo.name
```

If you like this content, please give a little heart!



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
