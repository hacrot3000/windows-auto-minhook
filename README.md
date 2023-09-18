# windows-auto-minhook
Improve minhook for Windows app for NIM languages

This is a special improvement for minhook just for Windows app.

It include:
* Two macros faddr and fptr for auto hook and forward the messages
* Get baseAddress and auto map base on each process
* More simple code on define and create hook

See src/lib for all of library source

Example file in src folder:
* hook.nim: Hook a running process
* hookv2.nim: Use Windows API to create a new process then setup hook by the default load DLL
* hookv3.nim: Use inject library to create a new process, inject the DLL then call Initialize (or any other exported function) to setup hook manually.
* testdll.nim: The DLL which use to execute the hook
