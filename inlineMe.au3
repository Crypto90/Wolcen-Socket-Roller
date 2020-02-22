Const $blocksize = 512
Dim $fromfile, $fromname, $curpos, $tag, $tofile, $toname, $ext, $name
If $CmdLine[0] = 0 Then
    Exit
Else
    $fromname = $CmdLine[1]
EndIf
If Not FileExists($fromname) Then Exit
$toname = $fromname & ".au3"
$fromfile = StringToBinary(BinaryToString(FileRead($fromname)))
$curpos = 0

$tofile = FileOpen($toname, 2)
If $tofile = -1 Then Exit
If StringInStr($fromname, ".") Then
    $ext = StringUpper(StringRight($fromname, StringLen($fromname) - StringInStr($fromname, ".", 0, -1)))
Else
    $ext = ""
EndIf
$name = StringRight($fromname, StringLen($fromname) - StringInStr($fromname, "\", 0, -1))
FileWriteLine($tofile, '#include-once')
FileWriteLine($tofile, '#include <file.au3>')
FileWriteLine($tofile, '')
FileWriteLine($tofile, 'Func _' & CleanName($name) & '_Startup()')
FileWriteLine($tofile, '    Local $Inline_Filename = _TempFile(@TempDir, "~", ".' & $ext & '")')
FileWriteLine($tofile, '    Local $InlineOutFile = FileOpen($Inline_Filename, 2)')
FileWriteLine($tofile, '    If $InlineOutFile = -1 Then Return SetError(1, 0, "")')
FileWriteLine($tofile, '')
FileWriteLine($tofile, '    FileWrite($InlineOutFile, _' & CleanName($name) & '_Inline())')
FileWriteLine($tofile, '    FileClose($InlineOutFile)')
If $ext = "DLL" Then
    FileWriteLine($tofile, '    If DllOpen($Inline_Filename) = -1 Then')
    FileWriteLine($tofile, '        Return SetError(1, 0, "")')
    FileWriteLine($tofile, '    Else')
    FileWriteLine($tofile, '        Return $Inline_Filename')
    FileWriteLine($tofile, '    EndIf')
Else
    FileWriteLine($tofile, '    Return $Inline_Filename')
EndIf
FileWriteLine($tofile, 'EndFunc   ;==>_' & CleanName($name) & '_Startup')
FileWriteLine($tofile, '')
FileWriteLine($tofile, 'Func _' & CleanName($name) & '_Shutdown($Inline_Filename)')
If $ext = "DLL" Then
    FileWriteLine($tofile, '    DllClose($Inline_Filename)')
EndIf
FileWriteLine($tofile, '    FileDelete($Inline_Filename)')
FileWriteLine($tofile, 'EndFunc   ;==>_' & CleanName($name) & '_Shutdown')
FileWriteLine($tofile, '')
FileWriteLine($tofile, 'Func _' & CleanName($name) & '_Inline()')
FileWriteLine($tofile, '    Local $sData')
FileWriteLine($tofile, "    #region    ;" & $name)
While $curpos < StringLen($fromfile)
    If $curpos = 0 Then
        $curpos = 1
        $tag = '    $sData  = "'
    Else
        $tag = '    $sData &= "'
    EndIf
    FileWriteLine($tofile, $tag & StringMid($fromfile, $curpos, $blocksize) & '"')
    $curpos += $blocksize
WEnd
FileWriteLine($tofile, "    #endregion ;" & StringRight($fromname, StringLen($fromname) - StringInStr($fromname, "\", 0, -1)))
FileWriteLine($tofile, '    Return Binary($sData)')
FileWriteLine($tofile, 'EndFunc   ;==>_' & CleanName($name) & '_Inline')
FileClose($tofile)

Func CleanName($name)
    $name = StringReplace($name, ".", "")
    $name = StringReplace($name, " ", "")
    $name = StringReplace($name, "[", "")
    $name = StringReplace($name, "]", "")
    $name = StringReplace($name, "(", "")
    $name = StringReplace($name, ")", "")
    $name = StringReplace($name, "{", "")
    $name = StringReplace($name, "}", "")
    Return $name
EndFunc   ;==>CleanName