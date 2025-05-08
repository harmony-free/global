import { BaseGlobal } from "./BaseGlobal";
import { AnimatorUtils } from '../system/AnimatorUtils';
import { LogUtils, SensorUtils } from "../system/Log";

export class Utils extends BaseGlobal{
  /**
   * 动画
   */
  animation: AnimatorUtils = new AnimatorUtils().run()

  /**
   * Log 日志
   */
  log: LogUtils = new LogUtils()


  /**
   * 摇晃传感器
   */
  sen: SensorUtils = new SensorUtils()


  /**
   * 设置打印日志
   * @param num:number = 20 设置手机摇晃幅度
   */
  openLog(num: number = 20) {
    this.sen.num = num
    this.sen.open()
  }
  /**
   * 关闭打印日志
   */
  closeLog(){
    this.sen.close();
  }
}