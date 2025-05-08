import { global } from '../system/Global'
import { LogModelFace } from '../system/Log'
import { router } from '../system/Router'
import { NavBar } from './NavBar'


@Builder
export function LogBuilder(o: object) {
  NavDestination() {
    LogPage({o:o})
  }.hideTitleBar(true)
}

router.requestBuilder("log", wrapBuilder(LogBuilder))

//请求日志
@Entry({ routeName: 'log' })
@Component
export struct LogPage {

  o: object | undefined
  // 返回方法
  backAction = () => {
    router.back()
  }

  build() {
    Column() {
      NavBar({
        backAction: this.backAction,
        title: "控制台:" + global.log.logList.length,
        // rightBuilderParam: this.rightView
      })
      List({ space: 1, initialIndex: 0 }) {
        ForEach(global.log.logList, (item: LogModelFace<string>) => {
          ListItem() {
            Row() {
              Text(`${item.createTime.getHours()}:${item.createTime.getMinutes()}:${item.createTime.getSeconds()} `)
              Text(item.data).maxLines(1).width('80%').textOverflow({ overflow: TextOverflow.Ellipsis })
            }.onClick(() => {
              AlertDialog.show({ message: item.data })
            }).padding(5).width('100%')
          }
        })
      }.height(global.contextHeight - 44)
    }.height('100%')
  }
}
