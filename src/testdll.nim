import winim/lean
import lib/fptr
import minhook


proc IsValidCode(key: int): bool  {.thiscall, fptr.} = 0xcfd0


proc modifiedIsValidCode(key: int): bool = 
    discard MessageBox(0, "Function hooked", "Conraguration!", MB_ICONMASK)

    result = IsValidCode(key)


proc setupMyHook(): bool =

    echo "[*] Hook at " & toHex(faddr IsValidCode)

    var ret = createHook(faddr IsValidCode, modifiedIsValidCode, nil)
    
    if ret == mhErrorAlreadyCreated:
        discard
    elif ret != mhOk:
        echo "[x] Hook create failed " & $ret
        return false


    return true


proc Initialize(): void {.stdcall, exportc, dynlib, cdecl.} =

    if setupMyHook() == false:
        return
        

    #MessageBox(0, "Locked and Loaded.", "DLL Injection Successful!", 0)
    echo "[*] DLL Injection Successful!"


    setupAllHook()
    


when isMainModule:

    #MessageBox(0, "Dll loadded", "Success", 0)
    echo "[*] Dll loadded"

    Initialize()
