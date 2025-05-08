import { BaseGlobal } from "./BaseGlobal";
import { errorManager } from "@kit.AbilityKit";
import { promptAction } from "@kit.ArkUI";

 export class Error extends BaseGlobal {
  /**
   * 错误监听id
   */
  errorId: number = -1
  /**
   * 耗时监听id
   */
  observerId: number = -1
  /**
   * 错误监听方法
   */
  callback: errorManager.ErrorObserver = {
    onUnhandledException: (errMsg: string) => this.onUnhandledException(errMsg),
    onException: (errObject: globalThis.Error) => this.onException(errObject)
  }
  /**
   * 监听主线程消息处理耗时
   */
  observer: errorManager.LoopObserver = {
    onLoopTimeOut(timeout: number) {
      // console.log('Duration timeout: ' + timeout);
    }
  };

  /**
   * 开启监听主线程
   */
  onObserver() {
    errorManager.on("loopObserver", 1, this.observer);
  }

  /**
   * 关闭监听主线程
   */
  offObserver() {
    errorManager.off("loopObserver");
  }

  /**
   * 开启错误监听
   */
  onError() {
    this.observerId = errorManager.on('error', this.callback);
  }

  /**
   * 关闭错误监听
   */
  offError() {
    errorManager.off("error", this.errorId, (result) => {
      console.log('[Demo] result' + result.code + ';' + result.message);
    })
  }

  /**
   * 捕获的异常信息
   * @param errMsg 错误提示
   */
  onUnhandledException(errMsg: string) {
    console.log('产生未捕获异常时的回调，onUnhandledException:', errMsg);
  }

  /**
   * 捕获的JS异常信息
   * @param errObject:globalThis.Error 错误信息
   */
  onException(errObject: globalThis.Error) {
    console.log('产生异常上报JS层时的回调，onException', errObject);
    promptAction.showToast({ message: errObject.message })
    if (typeof (errObject.stack) === 'string') {
      console.log('onException, stack: ', errObject.stack);
    }
  }
}