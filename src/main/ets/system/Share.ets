import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { global } from './Global';

class Share {
  data(data: systemShare.SharedData) {
    data = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      content: 'Hello HarmonyOS'
    });
    data.addRecord({
      utd: utd.UniformDataType.PNG,
      uri: 'file://.../test.png'
    });
    let context = global.getContext()
  }
}