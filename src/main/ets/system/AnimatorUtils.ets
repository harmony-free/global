import { Animator, AnimatorOptions, AnimatorResult } from '@kit.ArkUI';


@ObservedV2
export class AnimatorUtils {
  private options: AnimatorOptions = {
    duration: 1000,
    easing: "linear",
    delay: 0,
    fill: "forwards",
    direction: "normal",
    iterations: -1,
    begin: 0.0,
    end: 1.0
  };
  animator: AnimatorResult
  @Trace progress: number = 0.0

  constructor(options: AnimatorOptions | undefined = undefined) {
    if (this.options != undefined) {
      this.options = this.options
    }
    this.animator = Animator.create(this.options)
    this.animator.onFrame = (p: number) => {
      this.progress = p
    }
  }

  run() {
    this.animator.play()
    return this
  }

  stop() {
    this.animator.pause()
    return this
  }
}