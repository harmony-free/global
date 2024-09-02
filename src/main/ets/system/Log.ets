type LogType<K = object, V = object> = string | object | Map<K, V> | Array<K>

export function log(data: LogType) {
  if (typeof data == 'string') {
    console.log(data)
  } else if (data instanceof Map) {
    console.log(JSON.stringify(data))
  } else {
    console.log(JSON.stringify(data))
  }
}