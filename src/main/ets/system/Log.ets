import { util } from '@kit.ArkTS'
import { sensor } from '@kit.SensorServiceKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { router } from './Router'
import '../components/LogPage'
import { global } from './Global'
import { PreferencesLog } from './PreferencesUtils'

type Type<K = object, V = object> = string | object | Map<K, V> | Array<K>

enum LogType {
  LOG
}

export interface LogModelFace<T> {
  data: T
  createTime: Date
  type: LogType
}

class LogModel<T = object> implements LogModelFace<T> {
  data: T
  createTime: Date = new Date()
  type: LogType

  constructor(data: T, type: LogType = LogType.LOG) {
    this.data = data
    this.type = type
  }
}

interface LogFace {
  logList: Array<LogModelFace<string>>
  logAfter: (instance: console, ret: string, arg: string, ...args: object[]) => void
}

@ObservedV2
export class LogUtils implements LogFace {
  sen: SensorUtils = new SensorUtils()

  constructor() {
    util.Aspect.addAfter(console, 'log', true, this.logAfter)
  }

  @Trace logList: Array<LogModelFace<string>> = new Array<LogModelFace<string>>()
  logAfter: (instance: console, ret: string, arg: string, ...args: object[]) => void =
    (instance: console, ret: string, arg: string, ...args: object[]) => {
      let msg = arg
      if (args != undefined) {
        args.forEach((a) => {
          if (a instanceof Map) {
            msg += JSON.stringify(global.toRecord(a))
          } else {
            msg += JSON.stringify(a)
          }
        })
      }
      this.logList.push(new LogModel(msg))
    }

  log(data: Type) {
    if (typeof data == 'string') {
      console.log(data)
    } else if (data instanceof Map) {
      console.log(JSON.stringify(data))
    } else {
      console.log(JSON.stringify(data))
    }
  }

  save() {
    new PreferencesLog().putFlush(new Date().toString(), this.logList)
    this.logList = []
  }
}

export class SensorUtils {
  isOn: boolean = true

  sensorNum(num: number = 20) {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.GyroscopeResponse) => {
        if ((data.x > num || data.y > num || data.z > num) && (this.isOn)) {
          this.isOn = false
          router.push("log").then(() => {
            this.isOn = true
          })
        }
      });
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }
}