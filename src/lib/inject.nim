{.compile: "inject.c".}
{.passC: "-DSUBHOOK_STATIC".}
{.pragma: inject,
  cdecl,
  importc,
  discardable
.}
import winim/lean

proc Inject*(hProcess: HANDLE, dllname: cstring, funcname: cstring): void {.inject.}
proc doInject*(exeString: cstring, workingDir: cstring, dll: cstring, dllInitFunction: cstring): int {.inject.}