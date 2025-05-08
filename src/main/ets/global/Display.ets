import { display } from '@kit.ArkUI'


export  class Display {
  /**
   * 屏幕信息
   */
  dis: display.Display
  /**
   * 屏幕的宽度
   */
  width: number
  /**
   * 屏幕的高度
   */
  height: number
  /**
   * 像素密度
   */
  density: number
  /**
   * 帧率
   */
  hz: number
  /**
   * 设备id
   */
  id: number

  constructor() {
    this.dis = display.getDefaultDisplaySync()
    this.id = this.dis.id
    this.density = this.dis.densityPixels
    this.hz = this.dis.refreshRate
    this.width = px2vp(this.dis.width)
    this.height = px2vp(this.dis.height)
  }
}