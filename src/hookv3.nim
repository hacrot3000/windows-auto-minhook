import winim/lean
import lib/inject

when isMainModule:
  import os


  proc execute(): void =
    
    let 
      exeString: cstring = "main.exe"
      workingDir: cstring = os.getCurrentDir()
      dllPath: cstring = "testdll.dll"
      dllInitFunction: cstring = "Initialize"
   
    echo "[*] Injecting " & $dllPath & " into " & $exeString

    if doInject(exeString, workingDir, dllPath, dllInitFunction) == 0:

      echo "[*] Module injected"
    else:
      echo "[x] Module inject failed"

  execute()
