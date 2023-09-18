import winim/lean
import std/os

proc is_valid_code(code: int): int =
  discard MessageBox(0, "Checking the code " & $code, "Info", MB_ICONERROR)

  case code:
    of 1234:
      return 1
    of 4321:
      return 1
    of 8888:
      return 1
    else:
      discard
    
  let arr = [12345, 43210, 88889]

  for i in 0..arr.len - 1:
    if arr[i] == code:
      return code

  return 0


when isMainModule:

  # var ntdlldll = LoadLibraryA("testdll.dll")
  # if (ntdlldll == 0):
  #     echo "[X] Failed to load testdll.dll"
  let functionAddress = 0xcfd0

  var 
    key: int
    baseAddress = cast[int](GetModuleHandleA(nil))
    funActualAddress = baseAddress + functionAddress
    processId = getCurrentProcessId()

  while true:
    var ret = MessageBox(0, "Select Yes for 1111, No for 1234, Cancel for 5678.", "What is the key for " & toHex(funActualAddress) & " Pid:" & $processId, MB_YESNOCANCEL + MB_ICONINFORMATION + MB_SYSTEMMODAL + MB_TOPMOST)

    case ret:
      of IDYES:
        key = 1111
      of IDNO:
        key = 1234
      else:
        key = 5678
    
    if is_valid_code(key) > 0:
      discard MessageBox(0, "The key is correct", "Conraguration!", MB_ICONASTERISK)
      break
    else:
      discard MessageBox(0, "The key is incorrect", "Wrong!", MB_ICONERROR)

