import { BaseGlobal } from './BaseGlobal';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';


export  class Tools extends BaseGlobal{

  /**
   * 复制到粘贴板
   * @param text: string 复制内容
   */
  copy(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        promptAction.showToast({ message: '复制成功' });
      } else {
        promptAction.showToast({ message: '复制失败' });
      }
    })
  }

  /**
   * 黏贴
   */
  paste(): pasteboard.PasteData {
    const systemPasteboard = pasteboard.getSystemPasteboard();
    let data = systemPasteboard.getDataSync()
    return data
  }

  /**
   * 生成随机UUID
   * @returns
   */
  generateUUID(): string {
    return 'xxxxyxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  /**
   * 滑动动效
   * @param edge 滑出方式
   * @returns 返回动效
   */
  moveEffect(edge: TransitionEdge | undefined, duration: number = 200): TransitionEffect {
    return TransitionEffect.asymmetric(
      TransitionEffect.move(edge).animation({ duration: duration })
      ,
      TransitionEffect.move(edge).animation({ duration: duration })
    )
  }

  /**
   * map 转化为Record类型
   * @param map
   * @returns
   */
  toRecord(map: Map<string, object>): Record<string, object> {
    let r: Record<string, object> = {}
    map.forEach((value, key) => {
      if (key !== undefined && value !== undefined) {
        r[key] = value;
      }
    })
    return r
  }

  /**
   * object 转化为map类型
   * @param obj
   * @returns
   */
  toMap<T = object>(obj: object): Map<string, T> {
    return new Map<string, T>(Object.entries(obj))
  }

  /**
   * 根据参数取数组
   * @param list
   * @param k
   * @returns
   */
  listParams<T>(list: object[], k: string): Array<T> {
    let l: Array<T> = []
    list.forEach((v) => {
      l.push(v[k] as T)
    })
    return l
  }

  /**
   * 计算当前组件的中心位置
   * @param e
   * @returns
   */
  toCenter(e: ClickEvent): Offset {
    let x = parseFloat(e.target.area.globalPosition.x!.toString())
    let y = parseFloat(e.target.area.globalPosition.y!.toString())
    let w = parseFloat(e.target.area.width.toString())
    let h = parseFloat(e.target.area.height.toString())
    let cenX = x + w / 2
    let cenY = y + h / 2
    return { dx: cenX, dy: cenY }
  }
}