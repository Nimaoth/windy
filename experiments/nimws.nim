
import windy, random, tables, times

import std/asyncdispatch, ws

type
  Handle = int

  WebSocketState = ref object
    url: string
    webSocket: WebSocket
    onError: proc(msg: string)
    onOpen: proc()
    onMessage: proc(msg: string, kind: WebSocketMessageKind)
    onClose: proc()

var
  webSockets: Table[Handle, WebSocketState]

proc wsTasklet(state: WebSocketState) {.async.} =
  try:
    state.webSocket = await newWebSocket(state.url)
    while true:
      let (opcode, data) = await state.webSocket.receivePacket()
      case opcode:
        of Text:
          if state.onMessage != nil:
            state.onMessage(data, Utf8Message)
        of Binary:
          if state.onMessage != nil:
            state.onMessage(data, BinaryMessage)
        of Ping:
          await state.webSocket.send(data, Pong)
        of Pong:
          discard
        of Cont:
          discard
        of Close:
          state.webSocket.readyState = Closed
          if state.onClose != nil:
            state.onClose()
          break
  except:
    if state.onError != nil:
      state.onError(getCurrentExceptionMsg())

proc openWebSocket(url: string): Handle {.raises:[].} =
  var state = WebSocketState()
  state.url = url
  result = rand(int.high)
  webSockets[result] = state
  try:
    asyncCheck wsTasklet(state)
  except:
    echo getCurrentExceptionMsg()

proc `onError=`(handle: Handle, callback: proc(msg: string)) =
  if handle in webSockets:
    webSockets[handle].onError = callback

proc `onOpen=`(handle: Handle, callback: proc()) =
  if handle in webSockets:
    webSockets[handle].onOpen = callback

proc `onMessage=`(handle: Handle, callback: proc(msg: string, kind: WebSocketMessageKind)) =
  if handle in webSockets:
    webSockets[handle].onMessage = callback

proc `onClose=`(handle: Handle, callback: proc()) =
  if handle in webSockets:
    webSockets[handle].onClose = callback

proc pollHttp() {.raises:[].} =
  try:
    if hasPendingOperations():
      poll(0)
  except:
    echo getCurrentExceptionMsg()











# WebSockets do not block.

# All callbacks are called on the main thread.

# You can have many WebSockets open at the same time.

# Calling openWebSocket never throws an exception.
# If there is any error, onError will be called during
# the next pollEvents (or later).

let webSocket = openWebSocket("wss://stream.pushbullet.com/websocket/test")

webSocket.onError = proc(msg: string) =
  echo "onError: " & msg

webSocket.onOpen = proc() =
  echo "onOpen"

webSocket.onMessage = proc(msg: string, kind: WebSocketMessageKind) =
  echo "onMessage: ", msg

webSocket.onClose = proc() =
  echo "onClose"

# Closing the window exits the demo
let window = newWindow("Windy Basic", ivec2(1280, 800))
while not window.closeRequested:
  pollEvents()
  pollHttp()
