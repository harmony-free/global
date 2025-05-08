import { util } from '@kit.ArkTS'
import { sensor } from '@kit.SensorServiceKit'
import { BusinessError, print } from '@kit.BasicServicesKit'
import { router as nav } from './Router'
import '../components/LogPage'
import { global } from './Global'
import { router } from '@kit.ArkUI'

type Type<K = object, V = object> = string | object | Map<K, V> | Array<K>

enum LogType {
  LOG = 'log',
  INFO = 'info'
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
  max: number = 100
  @Trace logList: Array<LogModelFace<string>> = new Array<LogModelFace<string>>()

  constructor() {
    util.Aspect.addAfter(console, 'log', true, this.logAfter)
    util.Aspect.addAfter(console, 'info', true, this.logAfter)
  }

  logAfter: (instance: console, method: string, arg: string, ...args: object[]) => void =
    (instance: console, method: string, arg: string, ...args: object[]) => {
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
      if (this.logList.length > this.max) {
        this.logList.pop()
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
}

export class SensorUtils {
  isOn: boolean = true
  num: number = 20.0
  type:"router"|"navigation" = "navigation";
  sensors: Array<sensor.Sensor>  = []
  action: (data: sensor.GyroscopeResponse)=>void = this.openLog

  constructor() {
    this.sensors = sensor.getSensorListSync()
  }

  findSensor(id:sensor.SensorId):boolean{
    return this.sensors.find((s)=>s.sensorId == id) !== undefined;
  }

  open() {
    if (this.findSensor(sensor.SensorId.ACCELEROMETER)){
      try {
        sensor.on(sensor.SensorId.ACCELEROMETER, this.action.bind(this));
      } catch (error) {
        let e: BusinessError = error as BusinessError;
        console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
      }
    }else{
      console.error(`not find id with ${sensor.SensorId.ACCELEROMETER}`);
    }
  }

  openLog(data: sensor.GyroscopeResponse){
    if ((data.x > this.num || data.y > this.num || data.z > this.num) && (this.isOn)) {
      this.isOn = false
      if (this.type === "router"){
        router.pushNamedRoute({name:"log"})
      }else {
        nav.push("log").then(() => {
          this.isOn = true
        })
      }
    }
  }

  close(){
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER, this.action.bind(this));
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }
}