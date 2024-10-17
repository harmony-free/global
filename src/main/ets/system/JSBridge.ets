/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { webview } from '@kit.ArkWeb';

/**
 * Define bridge class connect WebView and ArkTS.
 */

/**
 * define the runJavaScript code.
 */

export const code = `
  const JSBridgeMap = {};
  let callID = 0;

  function JSBridgeCallback (id, params) {
    JSBridgeMap[id](params);
    JSBridgeMap[id] = null;
    delete JSBridgeMap[id];
  }

  window.ohosCallNative = {
    callNative(method, params, callback) {
      const id = callID++;
      const paramsObj = {
          callID: id,
          data: params || null
      }
      JSBridgeMap[id] = callback || (() => {});
      JSBridgeHandle.call(method, JSON.stringify(paramsObj));
    }
  }
`;


/**
 * JavaScriptItem
 */
export interface callType {
  call: (func: string, params: string) => void
}

export interface JavaScriptItem {
  object: callType,
  name: string,
  methodList: Array<string>,
  controller: WebviewController
}


/**
 * ParamsItem.
 */
export interface ParamsItem<T extends ParamsBaseItem = ParamsBaseItem> {
  callID: number,
  data: T
}

export interface ParamsBaseItem {}

/**
 * ParamsDataItem.
 */
export interface ParamsDataItem extends ParamsBaseItem {
  name?: string;
  tel?: string
}


export class JSBridge {
  controller: webview.WebviewController;

  constructor(controller: webview.WebviewController) {
    this.controller = controller;
  }

  /**
   * Injects the JavaScript object into window and invoke the function in window.
   *
   * @returns javaScriptProxy object.
   */
  get javaScriptProxy(): JavaScriptItem {
    let result: JavaScriptItem = {
      object: {
        call: this.call
      },
      name: 'JSBridgeHandle',
      methodList: ['call'],
      controller: this.controller
    }
    return result;
  }

  /**
   * initialize the bridge.
   */
  initJsBridge(call: ((func: string, params: string) => void) | undefined = undefined): void {
    if (call != undefined) {
      this.call = call
    }
    this.controller.runJavaScript(code);
  }

  /**
   * Invoke the chooseContact function.
   */
  call = (func: string, params: string): void => {
    const paramsObject: ParamsItem = JSON.parse(params);
    let result: Promise<string> = new Promise((resolve) => resolve(''));
    switch (func) {
      case 'setWeb':
        result = this.setWeb();
        break;
      case 'getWeb':
        result = this.getWeb(paramsObject.data);
        break;
      default:
        result = this.normal(params);
        break;
    }
    result.then((data: string) => {
      this.callback(paramsObject?.callID, data);
    })
  }
  // 默认监听方法
  normal = (params: string): Promise<string> => {
    return new Promise((resolve) => {
      console.log('JSBridge channel success, params is ' + params)
      resolve('JSBridge channel success, params is ' + params);
    })
  }
  /**
   * 设置web方法
   */
  setWeb = (): Promise<string> => {
    return new Promise((resolve) => {
      resolve('success');
    })
  }
  /**
   * 获取web方法
   */
  getWeb = (params: ParamsBaseItem): Promise<string> => {
    return new Promise((resolve) => {
      console.log(JSON.stringify(params))
      resolve('success');
    })
  }
  /**
   * The ArkTS invoke the WebView by using runJavaScript.
   */
  callback = (id: number, data: string): void => {
    this.controller.runJavaScript(`JSBridgeCallback('${id}', ${JSON.stringify(data)})`);
  }
}
