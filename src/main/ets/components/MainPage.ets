import { router } from '../system/Router';

@Entry
@Component
export struct MainPage {
  params: object | undefined

  aboutToAppear() {
  }

  build() {
    NavDestination() {
      Text() {
        SymbolSpan($r('sys.symbol.checkmark_calendar'))
      }

      Button("main back").onClick(() => {
        router.pop(new Object({ "main": "这是main返回的数据" }))
      })
      Button("main push").onClick(() => {
        router.replace('hello', new Object({ "main": "这是main传来的数据" })).then((data) => {
        })
      })
    }
  }
}
