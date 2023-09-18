import winim/lean
import lib/injector

when isMainModule:
  import os
  import strutils
  if paramCount() != 1:
    echo "usage: hook <pid>"
    quit(-1)
  let path = os.getCurrentDir() & "\\testdll.dll"
  injectModule(paramStr(1).parseInt(), path)
  echo path & " injected."
  
  discard MessageBox(0, "Press OK to close the main app.", "Hook is executed", MB_ICONASTERISK)
