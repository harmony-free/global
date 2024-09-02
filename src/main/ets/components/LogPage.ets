import { sensor } from '@kit.SensorServiceKit'
import { router } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { NavBar } from './NavBar'

//请求日志
@Entry
@Component
struct LogPage {
  // 返回方法
  backAction = () => {
    LogUtils.isLog = false
    LogUtils.init()
    router.back()
  }

  build() {
    Column() {
      NavBar({ backAction: this.backAction, title: "打印日志:" + LogUtils.logList.length })
      List({ space: 1, initialIndex: 0 }) {
        ForEach(LogUtils.logList, (item: string) => {
          ListItem() {
            Column() {
              Text(item)
                .maxLines(5)
                .width('100%')
                .fontSize(16)
                .padding(10)
                .backgroundColor("#EEEEEE")
                .borderRadius(10)
                .onClick(() => {
                  AlertDialog.show({ message: item })
                })
            }
          }
        })
      }.height('90%')
    }.height('100%')
  }
}


export class LogUtils {
  static isLog = false
  static logList: string[]

  static init() {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.GyroscopeResponse) => {
        if (data.x > 20 || data.y > 20 || data.z > 20) {
          sensor.off(sensor.SensorId.ACCELEROMETER);
          console.log(JSON.stringify(LogUtils.isLog))
          if (!LogUtils.isLog) {
            LogUtils.isLog = true
            router.pushUrl({ url: "pages/home/LogPage" })
          }
        }
      });
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }
}