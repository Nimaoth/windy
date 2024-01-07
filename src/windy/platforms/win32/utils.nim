import ../../common, strutils, windefs

proc wstr*(str: string): string =
  let wlen = MultiByteToWideChar(
    CP_UTF8,
    0,
    str.cstring,
    str.len.int32,
    nil,
    0
  )
  result.setLen(wlen * 2 + 1)
  discard MultiByteToWideChar(
    CP_UTF8,
    0,
    str.cstring,
    str.len.int32,
    cast[ptr WCHAR](result[0].addr),
    wlen
  )

proc `$`*(p: ptr WCHAR): string =
  let len = WideCharToMultiByte(
    CP_UTF8,
    0,
    p,
    -1,
    nil,
    0,
    nil,
    nil
  )
  if len > 0:
    result.setLen(len)
    discard WideCharToMultiByte(
      CP_UTF8,
      0,
      p,
      -1,
      result[0].addr,
      len,
      nil,
      nil
    )
    # The null terminator is included when -1 is used for the parameter length.
    # Trim this null terminating character.
    result.setLen(len - 1)

proc checkHRESULT*(hresult: HRESULT) =
  if hresult != S_OK:
    raise newException(WindyError, "HRESULT: " & toHex(hresult))

template HIWORD*(param: WPARAM | LPARAM): int16 =
  cast[int16]((param shr 16))

template LOWORD*(param: WPARAM | LPARAM): int16 =
  cast[int16](param and uint16.high.WPARAM)

const scancodeToButton* = block:
  var s = newSeq[Button](512)
  s[0x00b] = Key0
  s[0x002] = Key1
  s[0x003] = Key2
  s[0x004] = Key3
  s[0x005] = Key4
  s[0x006] = Key5
  s[0x007] = Key6
  s[0x008] = Key7
  s[0x009] = Key8
  s[0x00a] = Key9
  s[0x01e] = KeyA
  s[0x030] = KeyB
  s[0x02e] = KeyC
  s[0x020] = KeyD
  s[0x012] = KeyE
  s[0x021] = KeyF
  s[0x022] = KeyG
  s[0x023] = KeyH
  s[0x017] = KeyI
  s[0x024] = KeyJ
  s[0x025] = KeyK
  s[0x026] = KeyL
  s[0x032] = KeyM
  s[0x031] = KeyN
  s[0x018] = KeyO
  s[0x019] = KeyP
  s[0x010] = KeyQ
  s[0x013] = KeyR
  s[0x01f] = KeyS
  s[0x014] = KeyT
  s[0x016] = KeyU
  s[0x02f] = KeyV
  s[0x011] = KeyW
  s[0x02d] = KeyX
  s[0x015] = KeyY
  s[0x02c] = KeyZ
  s[0x029] = KeyBacktick
  s[0x00c] = KeyMinus
  s[0x00d] = KeyEqual
  s[0x00e] = KeyBackspace
  s[0x00f] = KeyTab
  s[0x01a] = KeyLeftBracket
  s[0x01b] = KeyRightBracket
  s[0x02b] = KeyBackslash
  s[0x03a] = KeyCapsLock
  s[0x027] = KeySemicolon
  s[0x028] = KeyApostrophe
  s[0x01c] = KeyEnter
  s[0x02a] = KeyLeftShift
  s[0x033] = KeyComma
  s[0x034] = KeyPeriod
  s[0x035] = KeySlash
  s[0x036] = KeyRightShift
  s[0x01d] = KeyLeftControl
  s[0x15b] = KeyLeftSuper
  s[0x038] = KeyLeftAlt
  s[0x039] = KeySpace
  s[0x138] = KeyRightAlt
  s[0x15c] = KeyRightSuper
  s[0x15d] = KeyMenu
  s[0x11d] = KeyRightControl
  s[0x153] = KeyDelete
  s[0x147] = KeyHome
  s[0x14f] = KeyEnd
  s[0x152] = KeyInsert
  s[0x149] = KeyPageUp
  s[0x151] = KeyPageDown
  s[0x001] = KeyEscape
  s[0x148] = KeyUp
  s[0x150] = KeyDown
  s[0x14b] = KeyLeft
  s[0x14d] = KeyRight
  s[0x137] = KeyPrintScreen
  s[0x046] = KeyScrollLock
  s[0x045] = KeyPause
  s[0x03b] = KeyF1
  s[0x03c] = KeyF2
  s[0x03d] = KeyF3
  s[0x03e] = KeyF4
  s[0x03f] = KeyF5
  s[0x040] = KeyF6
  s[0x041] = KeyF7
  s[0x042] = KeyF8
  s[0x043] = KeyF9
  s[0x044] = KeyF10
  s[0x057] = KeyF11
  s[0x058] = KeyF12
  s[0x145] = KeyNumLock
  s[0x052] = Numpad0
  s[0x04f] = Numpad1
  s[0x050] = Numpad2
  s[0x051] = Numpad3
  s[0x04b] = Numpad4
  s[0x04c] = Numpad5
  s[0x04d] = Numpad6
  s[0x047] = Numpad7
  s[0x048] = Numpad8
  s[0x049] = Numpad9
  s[0x053] = NumpadDecimal
  s[0x11c] = NumpadEnter
  s[0x04e] = NumpadAdd
  s[0x04a] = NumpadSubtract
  s[0x037] = NumpadMultiply
  s[0x135] = NumpadDivide
  s[0x059] = NumpadEqual
  s

const virtualKeyCodeToButton* = block:
  var s = newSeq[Button](256)
  s[0x01] = MouseLeft
  s[0x02] = MouseRight
  s[0x04] = MouseMiddle
  s[0x05] = MouseButton4
  s[0x06] = MouseButton5
  s[0x08] = KeyBackspace
  s[0x09] = KeyTab
  s[0x0C] = NumpadEqual
  s[0x0D] = KeyEnter # also NumpadEnter can be distinguished with scancode (0x01c for enter, 0x11c for numpad enter)
  s[0x10] = KeyLeftShift
  s[0x11] = KeyLeftControl
  s[0x12] = KeyLeftAlt
  s[0x13] = KeyPause
  s[0x14] = KeyCapsLock
  s[0x1B] = KeyEscape
  s[0x20] = KeySpace
  s[0x21] = KeyPageUp
  s[0x22] = KeyPageDown
  s[0x23] = KeyEnd
  s[0x24] = KeyHome
  s[0x25] = KeyLeft
  s[0x26] = KeyUp
  s[0x27] = KeyRight
  s[0x28] = KeyDown
  s[0x2C] = KeyPrintScreen
  s[0x2D] = KeyInsert
  s[0x2E] = KeyDelete
  s[0x30] = Key0
  s[0x31] = Key1
  s[0x32] = Key2
  s[0x33] = Key3
  s[0x34] = Key4
  s[0x35] = Key5
  s[0x36] = Key6
  s[0x37] = Key7
  s[0x38] = Key8
  s[0x39] = Key9
  s[0x41] = KeyA
  s[0x42] = KeyB
  s[0x43] = KeyC
  s[0x44] = KeyD
  s[0x45] = KeyE
  s[0x46] = KeyF
  s[0x47] = KeyG
  s[0x48] = KeyH
  s[0x49] = KeyI
  s[0x4A] = KeyJ
  s[0x4B] = KeyK
  s[0x4C] = KeyL
  s[0x4D] = KeyM
  s[0x4E] = KeyN
  s[0x4F] = KeyO
  s[0x50] = KeyP
  s[0x51] = KeyQ
  s[0x52] = KeyR
  s[0x53] = KeyS
  s[0x54] = KeyT
  s[0x55] = KeyU
  s[0x56] = KeyV
  s[0x57] = KeyW
  s[0x58] = KeyX
  s[0x59] = KeyY
  s[0x5A] = KeyZ
  s[0x5B] = KeyLeftSuper
  s[0x5C] = KeyRightSuper
  s[0x60] = Numpad0
  s[0x61] = Numpad1
  s[0x62] = Numpad2
  s[0x63] = Numpad3
  s[0x64] = Numpad4
  s[0x65] = Numpad5
  s[0x66] = Numpad6
  s[0x67] = Numpad7
  s[0x68] = Numpad8
  s[0x69] = Numpad9
  s[0x6A] = NumpadMultiply
  s[0x6B] = NumpadAdd
  s[0x6D] = NumpadSubtract
  s[0x6E] = NumpadDecimal
  s[0x6F] = NumpadDivide
  s[0x70] = KeyF1
  s[0x71] = KeyF2
  s[0x72] = KeyF3
  s[0x73] = KeyF4
  s[0x74] = KeyF5
  s[0x75] = KeyF6
  s[0x76] = KeyF7
  s[0x77] = KeyF8
  s[0x78] = KeyF9
  s[0x79] = KeyF10
  s[0x7A] = KeyF11
  s[0x90] = KeyNumLock
  s[0x91] = KeyScrollLock
  s[0xA0] = KeyLeftShift
  s[0xA1] = KeyRightShift
  s[0xA2] = KeyLeftControl
  s[0xA3] = KeyRightControl
  s[0xA4] = KeyLeftAlt
  s[0xA5] = KeyRightAlt
  s[0xBA] = KeySemicolon
  s[0xBB] = KeyEqual
  s[0xBC] = KeyComma
  s[0xBD] = KeyMinus
  s[0xBE] = KeyPeriod
  s[0xBF] = KeySlash
  s[0xC0] = KeyBacktick
  s[0xDB] = KeyLeftBracket
  s[0xDC] = KeyBackslash
  s[0xDD] = KeyLeftBracket
  s[0xDE] = KeyApostrophe
  s

proc wmEventName*(wm: int | UINT): string =
  case wm:
  of WM_GETMINMAXINFO:
    "WM_GETMINMAXINFO"
  of WM_NCCREATE:
    "WM_NCCREATE"
  of WM_CREATE:
    "WM_CREATE"
  of WM_NCCALCSIZE:
    "WM_NCCALCSIZE"
  of WM_SHOWWINDOW:
    "WM_SHOWWINDOW"
  of WM_WINDOWPOSCHANGING:
    "WM_WINDOWPOSCHANGING"
  of WM_WINDOWPOSCHANGED:
    "WM_WINDOWPOSCHANGED"
  of WM_ACTIVATEAPP:
    "WM_ACTIVATEAPP"
  of WM_ACTIVATE:
    "WM_ACTIVATE"
  of WM_NCACTIVATE:
    "WM_NCACTIVATE"
  of WM_NCPAINT:
    "WM_NCPAINT"
  of WM_ERASEBKGND:
    "WM_ERASEBKGND"
  of WM_PAINT:
    "WM_PAINT"
  of WM_GETICON:
    "WM_GETICON"
  of WM_SETICON:
    "WM_SETICON"
  of WM_IME_SETCONTEXT:
    "WM_IME_SETCONTEXT"
  of WM_IME_NOTIFY:
    "WM_IME_NOTIFY"
  of WM_DWMCOMPOSITIONCHANGED:
    "WM_DWMCOMPOSITIONCHANGED"
  of WM_DWMNCRENDERINGCHANGED:
    "WM_DWMNCRENDERINGCHANGED"
  of WM_DWMCOLORIZATIONCOLORCHANGED:
    "WM_DWMCOLORIZATIONCOLORCHANGED"
  of WM_DWMWINDOWMAXIMIZEDCHANGE:
    "WM_DWMWINDOWMAXIMIZEDCHANGE"
  of WM_DWMSENDICONICTHUMBNAIL:
    "WM_DWMSENDICONICTHUMBNAIL"
  of WM_DWMSENDICONICLIVEPREVIEWBITMAP:
    "WM_DWMSENDICONICLIVEPREVIEWBITMAP"
  of WM_SIZE:
    "WM_SIZE"
  of WM_MOVE:
    "WM_MOVE"
  of WM_SETFOCUS:
    "WM_SETFOCUS"
  of WM_KILLFOCUS:
    "WM_KILLFOCUS"
  of WM_ENABLE:
    "WM_ENABLE"
  of WM_DESTROY:
    "WM_DESTROY"
  of WM_DPICHANGED:
    "WM_DPICHANGED"
  of WM_NULL:
    "WM_NULL"
  of WM_SETCURSOR:
    "WM_SETCURSOR"
  of WM_MOUSEMOVE:
    "WM_MOUSEMOVE"
  of WM_MOUSEWHEEL:
    "WM_MOUSEWHEEL"
  of WM_MOUSEHWHEEL:
    "WM_MOUSEHWHEEL"
  of WM_MOUSELEAVE:
    "WM_MOUSELEAVE"
  of WM_LBUTTONDOWN:
    "WM_LBUTTONDOWN"
  of WM_LBUTTONUP:
    "WM_LBUTTONUP"
  of WM_LBUTTONDBLCLK:
    "WM_LBUTTONDBLCLK"
  of WM_RBUTTONDOWN:
    "WM_RBUTTONDOWN"
  of WM_RBUTTONUP:
    "WM_RBUTTONUP"
  of WM_RBUTTONDBLCLK:
    "WM_RBUTTONDBLCLK"
  of WM_MBUTTONDOWN:
    "WM_MBUTTONDOWN"
  of WM_MBUTTONUP:
    "WM_MBUTTONUP"
  of WM_MBUTTONDBLCLK:
    "WM_MBUTTONDBLCLK"
  of WM_KEYDOWN:
    "WM_KEYDOWN"
  of WM_KEYUP:
    "WM_KEYUP"
  of WM_CHAR:
    "WM_CHAR"
  of WM_SYSKEYDOWN:
    "WM_SYSKEYDOWN"
  of WM_SYSKEYUP:
    "WM_SYSKEYUP"
  of WM_SYSCHAR:
    "WM_SYSCHAR"
  of WM_UNICHAR:
    "WM_UNICHAR"
  of WM_SYSCOMMAND:
    "WM_SYSCOMMAND"
  of WM_XBUTTONDOWN:
    "WM_XBUTTONDOWN"
  of WM_XBUTTONUP:
    "WM_XBUTTONUP"
  of WM_IME_STARTCOMPOSITION:
    "WM_IME_STARTCOMPOSITION"
  of WM_IME_ENDCOMPOSITION:
    "WM_IME_ENDCOMPOSITION"
  of WM_IME_COMPOSITION:
    "WM_IME_COMPOSITION"
  of WM_USER:
    "WM_USER"
  of WM_APP:
    "WM_APP"
  else:
    "WM " & $wm & " " & $toHex(wm)
