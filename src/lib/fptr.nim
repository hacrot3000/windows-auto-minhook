import macros, random, tables, strutils
import winim/lean
import std/strutils

converter toPointer*(x: int): pointer = cast[pointer](x)

proc fnv32a[T: string|openArray[char]|openArray[uint8]|openArray[int8]](data: T): int32 =
  result = -18652613'i32
  for b in items(data):
    result = result xor ord(b).int32
    result = result *% 16777619

var
  # nameToVal {.compileTime.} = initTable[string, string]()
  nameToAddress {.compileTime.} = initTable[string, BiggestInt]()
  seed {.compileTime.} = fnv32a(CompileTime & CompileDate) and 0x7FFFFFFF
  r {.compileTime.} = initRand(seed)

macro faddr*(body: untyped): untyped =

  let input = ($body.toStrLit).split(".")
  if input.len > 1:
    let desc = input[1]
    echo desc
  result = newCall(ident("getBaseAddress"))
  result.add(newIntLitNode(nameToAddress[input[0]]))
  

  echo "FADDR:\n" & $result.toStrLit


# macro caddr*(body: untyped): untyped =

#   let input = ($body.toStrLit).split(".")
#   if input.len > 1:
#     let desc = input[1]
#     echo desc
#   result = newCall(ident("getBaseAddress"))
#   result.add(newIntLitNode(nameToAddress[input[0]]))
  

  echo "FADDR:\n" & $result.toStrLit


macro fptr*(body: untyped) : untyped =
  ## this marco will create a proc type based on input
  ## and then create a proc pointer to an address if specified
  if body.kind != nnkProcDef:
    return

  var
    name, ptrName, procName: string
    isExported = false
  if body[0].kind == nnkIdent:
    name = $body[0]
  else:
    #[
      #echo treeRepr body[0]
    if body[0].kind == nnkAccQuoted:
      name = $body[0][0]
    else:
      name = $body[0][1]
    ]#
    name = $body[0][1]
    isExported = true
  var suffix = "_" & $r.next()
  procName = "proc_" & name & suffix
  ptrName = "var_" & name & suffix
  #nameToProc[name] = procName
  if (nameToAddress.hasKey(name)):
    raise newException(CatchableError, name & " is already defined, this may causes hooking to wrong address")
  
  # nameToVal[name] = ptrName

  var
    typeSection = newNimNode(nnkTypeSection)
    typeDef = newNimNode(nnkTypeDef)
    varSection = newNimNode(nnkVarSection)
    identDef = newNimNode(nnkIdentDefs)
    aliasProc = newProc(ident(name))
    pragma = newNimNode(nnkPragma)

  typeSection.add(typeDef)
  varSection.add(identDef)

  # pragma
  if body[4].kind == nnkPragma:
    pragma = body[4]


  let 
    bodyTypeStr = $body[3].toStrLit
    procTypeVoid = bodyTypeStr.endsWith("void") or bodyTypeStr.endsWith(")")

  if isExported:
    typeDef.add(postfix(ident(procName), "*"))
  else:
    typeDef.add(ident(procName))
  typeDef.add(newEmptyNode())
  typeDef.add(newNimNode(nnkProcTy)
    .add(body[3]) # FormalParams
    .add(pragma) # pragmas
  )
  result = newStmtList(typeSection)

  if body[6].kind == nnkStmtList and body[6][0].kind == nnkIntLit:
    if isExported:
      identDef.add(postfix(ident(ptrName), "*"))
      let procName = ident(name)
      procName.copyLineInfo(body)
      aliasProc.name = postfix(procName, "*")
    else:
      let ptrName = ident(ptrName)
      ptrName.copyLineInfo(body)
      identDef.add(ptrName)

    var address = body[6][0]
    nameToAddress[name] = address.intVal

    # address.intVal=123
    # address.intVal

    var getAddress = newCall(ident("getBaseAddress"))
    getAddress.add(address)

    identDef.add(newEmptyNode())
    identDef.add(newNimNode(nnkCast)
      .add(ident(procName))
      .add(getAddress)
    )

    var aliasProcBody = newCall(ident(ptrName))
    for param in body[3]:
      if param.kind == nnkIdentDefs:
        aliasProcBody.add(param[0])

    
    let call1 = newCall(ident("disableHook"))
    call1.add(getAddress)
    let call2 = newCall(ident("enableHook"))
    call2.add(getAddress)
    
    # let identVar = newNimNode(nnkVarSection)
    # let identAssign = newNimNode(nnkIdentDefs)

    let ret = newNimNode(nnkReturnStmt)
    ret.add(ident("ret"))

    aliasProc.params = body[3]
    aliasProc.addPragma(ident("inline"))
    aliasProc.body.add(call1)

    if procTypeVoid:
      aliasProc.body.add(aliasProcBody)
    else:
      let 
        identProcForward = newNimNode(nnkVarSection)
        identAssign = newNimNode(nnkIdentDefs)

      identAssign.add(ident("ret"))
      identAssign.add(newEmptyNode())
      identAssign.add(aliasProcBody)
      identProcForward.add(identAssign)

      aliasProc.body.add(identProcForward)

    aliasProc.body.add(call2)

    if not procTypeVoid:
      aliasProc.body.add(ret)
    

    result.add(varSection)
    result.add(aliasProc)
    
    echo "FUNC:\n" & $result.toStrLit

macro setupAllHook*(): untyped =

  var typeSection = newNimNode(nnkTypeSection)
      
  result = newStmtList(typeSection)

  for name, address in nameToAddress:
    let 
      newCall = newCall("enableHook").add(newCall("getBaseAddress").add(newIntLitNode(address)))

    result.add(newCall)

  echo "SETUP:\n" & $result.toStrLit

var 
  baseAddress: int = 0
  isNotInitBaseAddress: bool = true


proc initBaseAddress() =
  baseAddress = cast[int](GetModuleHandleA(nil))
  isNotInitBaseAddress = false

proc getBaseAddress*(add:int = 0): int {.inline.} = 
  if isNotInitBaseAddress:
    initBaseAddress()
  result = add + baseAddress


