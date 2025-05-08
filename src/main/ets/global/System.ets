import { BaseGlobal } from './BaseGlobal';
import { bundleManager, Want } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { productViewManager, updateManager } from '@kit.StoreKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { componentSnapshot, promptAction } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { filePreview } from '@kit.PreviewKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { interactiveLiveness } from '@kit.VisionKit';


interface ContextDir {
  cacheDir: string
  cloudFileDir: string
  tempDir: string
  filesDir: string
  preferencesDir: string
  bundleCodeDir: string
  resourceDir: string
}

export class System extends BaseGlobal{

  /**
   * 文件夹
   * @returns: ContextDir 文件夹路径
   */
  contextDir(): ContextDir {
    return {
      cacheDir: this.context.cacheDir,
      cloudFileDir: this.context.cloudFileDir,
      tempDir: this.context.tempDir,
      filesDir: this.context.filesDir,
      preferencesDir: this.context.preferencesDir,
      bundleCodeDir: this.context.bundleCodeDir,
      resourceDir: this.context.resourceDir,
    }

  }

  /**
   * 保存图片到相册
   * @param data: ArrayBuffer | image.PixelMap 图片数据
   * @returns: boolean 是否保存成功
   */
  async savePhoto(data: ArrayBuffer | image.PixelMap): Promise<boolean> {
    return new Promise<boolean>(async (res, rej) => {
      try {
        await this.requestPermissions("ohos.permission.WRITE_IMAGEVIDEO")
        let helper = photoAccessHelper.getPhotoAccessHelper(this.context);
        let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
        let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        if (!(data instanceof ArrayBuffer)) {
          let packer = image.createImagePacker()
          data = await packer.packing(data, { format: "image/png", quality: 100 })
        }
        await fileIo.write(file.fd, data);
        await fileIo.close(file.fd);
        promptAction.showToast({ message: '保存到相册' })
        res(true)
      } catch (error) {
        rej(false)
      }
    })
  }
  /**
   * 分享弹窗
   * @param record: systemShare.SharedRecord 弹窗数据
   * @returns
   */
  share(record: systemShare.SharedRecord): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      let data: systemShare.SharedData = new systemShare.SharedData(record);
      let controller: systemShare.ShareController = new systemShare.ShareController(data);
      if (record.thumbnail != undefined && record.thumbnail.byteLength > 32 * 1024) {
        console.log("thumbnail size is not 32Kb")
        rej("thumbnail size is not 32Kb")
      } else {
        let callback = () => {
          res(true)
          controller.off('dismiss', callback);
        };
        controller.on('dismiss', callback);
        controller.show(this.context, {
          previewMode: systemShare.SharePreviewMode.DETAIL,
          selectionMode: systemShare.SelectionMode.SINGLE
        });
      }
    })
  }

  /**
   * 打开要应用信息页面
   * @param bundleName: 引用包名
   * @returns: 是否打开
   */
  appProduct(bundleName: string): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      const wantParam: Want = {
        parameters: {
          // 此处填入要加载的应用包名，例如： bundleName: 'com.huawei.hmsapp.books'
          bundleName: bundleName
        }
      }
      const callback: productViewManager.ProductViewCallback = {
        onError: (error: BusinessError) => {
          if (error.code == 0) {
            res(true)
          } else {
            let want: Want = {
              action: 'ohos.want.action.appdetail', //隐式指定action为ohos.want.action.appdetail
              uri: 'store://appgallery.huawei.com/app/detail?id=' + bundleName, //  bundleName为需要打开应用详情的应用包名
            };
            this.context.startAbility(want).then(() => {
              res(true)
            }).catch((error: BusinessError) => {
              res(false)
              rej(error)
            });
          }
        }
      }
      productViewManager.loadProduct(this.context, wantParam, callback);
    })
  }

  /**
   * 截屏组件 和 系统截屏
   * @param key: string 被截屏的组件
   * @param options
   * @returns
   */
  snapshot(key?: string,
    options: componentSnapshot.SnapshotOptions = {
      scale: this.density,
      waitUntilRenderFinished: true
    }): Promise<image.PixelMap> {
    return new Promise<image.PixelMap>((res, rej) => {
      if (key == undefined) {
        this.main.snapshot((err, data) => {
          if (data) {
            res(data)
          } else {
            console.log(err.message)
            rej(err)
          }
        })
      } else {
        componentSnapshot.get(key, (err, data) => {
          if (data) {
            res(data)
          } else {
            console.log(err.message)
            rej(err)
          }
        }, options)
      }

    })
  }

  /**
   * 打开应用
   * @param url: 应用地址
   * @returns: 是否打开
   */
  openLink(url: string): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      try {
        // 判断是否安装应用
        // module.json5 中设置 检查安装名称 "querySchemes": [],
        if (bundleManager.canOpenLink(url)) {
          this.context.startAbility({
            uri: url
          }, (err: BusinessError) => {
            res(err.code == 0)
            console.log(err.message)
          })
        } else {
          rej("没有找到该应用")
        }
      } catch (e) {
        console.log(JSON.stringify(e))
        rej(e)
      }
    })

  }

  /**
   * 文件预览
   * @param info: filePreview.PreviewInfo 预览信息
   */
  preview(info: filePreview.PreviewInfo) {
    let displayInfo: filePreview.DisplayInfo = {
      x: 100,
      y: 100,
      width: 800,
      height: 800
    };
    filePreview.openPreview(this.context, info, displayInfo).then(() => {
      console.info('Succeeded in opening preview');
    }).catch((err: BusinessError) => {
      console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
    });
  }

  /**
   * app检查更新
   * @returns: boolean 是否更新成功
   */
  appUpdate(): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      try {
        updateManager.checkAppUpdate(this.context).then((data: updateManager.CheckUpdateResult) => {
          if (data.updateAvailable == updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
            updateManager.showUpdateDialog(this.context).then((code: updateManager.ShowUpdateResultCode) => {
              res(code == updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS)
            }).catch((error: BusinessError) => {
              rej(error)
            })
          } else {
            rej({
              code: 10010,
              name: "updateManager",
              message: "version not update"
            })
          }
        }).catch((error: BusinessError) => {
          rej(error)
        })
      } catch (error) {
        rej(error)
      }
    })
  }

  /**
   * 人脸识别
   * @param options: interactiveLiveness.InteractiveLivenessConfig 人脸识别配置信息
   * @returns: interactiveLiveness.InteractiveLivenessResult 人脸识别后图片
   */
  async face(options: interactiveLiveness.InteractiveLivenessConfig = {
    actionsNum: 1 as interactiveLiveness.ActionsNumber,
    isSilentMode: "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode,
    routeMode: "back" as interactiveLiveness.RouteRedirectionMode
  }): Promise<interactiveLiveness.InteractiveLivenessResult> {
    return new Promise(async (res, rej) => {
      let map = await this.requestPermissions("ohos.permission.CAMERA", "ohos.permission.PRIVACY_WINDOW")
      if (map.get("ohos.permission.CAMERA") == false) {
        rej("需要打开ohos.permission.CAMERA权限")
      } else if (options.isPrivacyMode == false &&
        map.get("ohos.permission.PRIVACY_WINDOW") == false) {
        rej("需要打开ohos.permission.PRIVACY_WINDOW权限")
      } else {
        interactiveLiveness.startLivenessDetection(options,
          (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
            if (result != undefined && err.code == 0) {
              res(result)
            } else {
              rej(err ?? "result is undefined")
              return;
            }
          })
      }
    })
  }
}