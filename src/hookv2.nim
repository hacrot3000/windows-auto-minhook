import winim/lean
import minhook
import lib/injector
import osproc



when isMainModule:
  import os
  import strutils

  proc createRemoteThread(): (Process, HANDLE) =
              
      let tProcess = startProcess("main.exe")
      tProcess.suspend() # That's handy!
      #defer: tProcess.close()

      echo "[*] Target Process: ", tProcess.processID

      let pHandle = OpenProcess(
          PROCESS_ALL_ACCESS, 
          false, 
          cast[DWORD](tProcess.processID)
      )
      #defer: CloseHandle(pHandle)

      echo "[*] pHandle: ", pHandle

      return (tProcess, pHandle)


  
  proc execute(): void =
    let path = os.getCurrentDir() & "\\testdll.dll"
    var 
      tProcess: Process
      pHandle: HANDLE

    defer:
      tProcess.close()
      CloseHandle(pHandle)

    (tProcess, pHandle) = createRemoteThread()

    injectModule(tProcess.processID, path)
    echo path & " injected."
    
    tProcess.resume()


    #MessageBox(0, "Close this dialog to stop the process", "Hello", 0)

  execute()
