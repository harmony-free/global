import { abilityAccessCtrl, common, PermissionRequestResult, Permissions, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import { PreferencesPermission } from '../system/PreferencesUtils'
import { Display } from './Display'


export class BaseGlobal extends Display{

  /**
   * 获取Context
   */
  context:common.UIAbilityContext = getContext() as common.UIAbilityContext

  /**
   * 主window信息
   */
  main: window.Window = this.context.windowStage.getMainWindowSync()

  /**
   * 窗口属性
   */
  properties: window.WindowProperties  = this.main.getWindowProperties()

  /**
   * 请求权限，如果权限被拒接，弹窗提示前往设置打开权限
   * @param permissions 权限名称
   * @returns Map<Permissions, boolean> 对应权限的开关
   */
  requestPermissions(...permissions: Array<Permissions>): Promise<Map<Permissions, boolean>> {
    return new Promise<Map<Permissions, boolean>>((res, rej) => {
      let map = new Map<Permissions, boolean>()
      let ac = abilityAccessCtrl.createAtManager()
      ac.requestPermissionsFromUser(getContext(this), permissions).then(async (v: PermissionRequestResult) => {
        for (let index = 0; index < v.permissions.length; index++) {
          let permission = v.permissions[index] as Permissions
          let authResult = v.authResults[index]
          let first = v.dialogShownResults == undefined
          let i = permissions.indexOf(permission)
          if (i != -1) {
            if (authResult == 0) {
              map.set(permission, true)
            } else if (authResult == -1) {
              map.set(permission, false)
              if (!first) {
                let req = await new PreferencesPermission().open(permissions.toString())
                if (req) {
                  ac.requestPermissionOnSetting(getContext(this), permissions)
                    .then((status: abilityAccessCtrl.GrantStatus[]) => {
                      status.forEach((s, i) => {
                        map.set(permissions[i], s == 0)
                      })
                      res(map)
                    })
                    .catch((e: Error) => {
                      this.toAppInfo()
                      rej(e)
                    })
                } else {
                  res(map)
                }
                return
              }
            }
          }
        }
        res(map)
      })
    })
  }

  /**
   * 打开应用权限管理
   */
  toAppInfo() {
    let context = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings', //设置应用bundleName
      abilityName: 'com.huawei.hmos.settings.MainAbility', //设置应用abilityName
      uri: "application_info_entry", //应用管理页面
      parameters: {
        pushParams: {
          bundleName: context.abilityInfo.bundleName//拉起方应用包名
        }
      }
    }
    context.startAbility(want)
  }


}