	

#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <GuiComboBox.au3>

; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <ComboConstants.au3>
#include "Forms\MainWindow.isf"

#include <EditConstants.au3>



;draw lines
#include <WinAPIGdi.au3>
#include <WinAPIGdiDC.au3>
#include <WinAPIHObj.au3>
#include <WinAPISysWin.au3>
;fix windows coordinate line drawing mess
;#include <WinAPIConv.au3>


;log scanning areas as screenshot
#include <Misc.au3>
#include <ScreenCapture.au3>

;mouse position relative to window and not 
AutoItSetOption("MouseCoordMode",0)


;EMBED IMAGES INTO EXE
;start button image
GUICtrlSetImage($startButtonHdn2, @TempDir & '\Wolcen_Socket_Roller\button_start.jpg')

;donate button image
GUICtrlSetImage($coffee, @TempDir & '\Wolcen_Socket_Roller\button_donate.jpg')

;background image
$MainWindow_BGimage = GUICtrlCreatePic(@TempDir & '\Wolcen_Socket_Roller\background_v3.jpg',0,0,880,430,$WS_CLIPSIBLINGS)


$currentver = StringStripWS(GUICtrlRead($currentVersion), $STR_STRIPLEADING + $STR_STRIPTRAILING)
;check for update
InetGet ("https://raw.githubusercontent.com/Crypto90/Wolcen-Socket-Roller/master/version.txt", @TempDir & "\Wolcen_Socket_Roller\version.txt")
$latestver = FileRead(@TempDir & "\Wolcen_Socket_Roller\version.txt")
$latestver = StringStripWS($latestver, $STR_STRIPLEADING + $STR_STRIPTRAILING)
FileDelete(@TempDir & "\Wolcen_Socket_Roller\version.txt")

If $latestver > $currentver Then
	GUICtrlSetState($update, $GUI_HIDE)
	GUICtrlSetState($update, $GUI_SHOW)
EndIf


;additional functions start

Func _GetURLImage($sURL, $sDirectory = @ScriptDir)
    Local $hDownload, $sFile
    $sFile = StringRegExpReplace($sURL, "^.*/", "")
    If @error Then
        Return SetError(1, 0, $sFile)
    EndIf
    If StringRight($sDirectory, 1) <> "\" Then
        $sDirectory = $sDirectory & "\"
    EndIf
    $sDirectory = $sDirectory & $sFile
    If FileExists($sDirectory) Then
        Return $sDirectory
    EndIf
    $hDownload = InetGet($sURL, $sDirectory, 17, 1)
    While InetGetInfo($hDownload, 2) = 0
        If InetGetInfo($hDownload, 4) <> 0 Then
            InetClose($hDownload)
            Return SetError(1, 0, $sDirectory)
        EndIf
        Sleep(105)
    WEnd
    InetClose($hDownload)
    Return $sDirectory
EndFunc   ;==>_GetURLImage


; _GUICtrlRichEdit_AppendTextEx($RichEdit, $text, $font="Arial", $color="000000", $size=12, $bold=0, $italic=0, $underline=0, $strike=0)
;   This function was created to make it simpler to use RichEdit controls.
;
;   Note: to set the line spacing to a size bigger than the text, 
;   you need to call this function once to write the text, and then call
;   it again and write a space with a larger size, and that will give you
;   spacing between the lines.
;
;Peramiters
;   $RichEdit = handle of RichEdit control
;   $text = the string to write. You need to add @CRLF for a newline
;   $font = the font family to use, default = "Arial"
;   $color = the rrggbb hex color code to use, default = "000000" (black)
;   $size = the font size to use in points, will be rounded to the nearest 0.5 points before use, default = 12
;   $bold = flag to make the text bold, default = 0 (not bold)
;   $italic = flag to make the text italic, default = 0 (not italic)
;   $strike = flag to make the text strikethrough, default = 0
;   $underline = int, what kind of underlining to use. default = 0
;       1 = Underline
;       2 = Double Underline
;       3 = Thick Underline
;       4 = Underline words only
;       5 = Wave Underline
;       6 = Dotted Underline
;       7 = Dash Underline
;       8 = Dot Dash Underline
;   
;Return value
;   On success: Returns the value from _GUICtrlRichEdit_AppendText()
;   On failure: Sets @error to non-0
;       1 = Error with color
;
Func _GUICtrlRichEdit_AppendTextEx($RichEdit, $text, $font="Arial", $color="000000", $size=12, $bold=0, $italic=0, $strike=0, $underline=0)
  Local $command = "{\rtf1\ansi"
  Local $r, $g, $b, $ul[9] = ["8", '\ul', '\uldb', '\ulth', '\ulw', '\ulwave', '\uld', '\uldash', '\uldashd']

  If $font <> "" Then $command &= "{\fonttbl\f0\f"&$font&";}"
  If $color <> "" Then
    If StringLen($color) <> 6 And StringLen($color) = 8 Then Return SetError(1)
    $b = dec(StringRight($color,2))
    if @error Then seterror(1, 1)
    $color = StringTrimRight($color,2)
    $g = dec(StringRight($color,2))
    if @error Then seterror(1, 2)
    $color = StringTrimRight($color,2)
    $r = dec(StringRight($color,2))
    if @error Then seterror(1, 3)
    If $r+$b+$g > 0 Then
      $command &= "{\colortbl;\red"&$r&"\green"&$g&"\blue"&$b&";}\cf1"
    EndIf
  EndIf
 
  If $size Then $command &= "\fs"&round($size*2)&" "
  If $strike Then $command &= "\strike "
  If $italic Then $command &= "\i "
  If $bold Then $command &= "\b "
  If $underline > 0 and $underline < 9 Then $command &= $ul[$underline]&" "
;~   ConsoleWrite($command&$text&"}"&@CRLF) ; Debugging line
  Return _GUICtrlRichEdit_AppendText($RichEdit, $command&StringReplace($text,@CRLF,"\line")&"}" )
EndFunc

Func _GUICtrlRichEdit_InsertBitmap($hWnd, $sFile, $sFormatFunctions = "\", $sBitmapFunctions = "\", $iBgColor = Default) ;coded by UEZ build 2016-02-16
    If Not FileExists($sFile) Then Return SetError(0, 0, 1)
    If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(0, 0, 2)
    _GDIPlus_Startup()
    Local $hImage = _GDIPlus_ImageLoadFromFile($sFile)
    If @error Then
        _GDIPlus_Shutdown()
        Return SetError(0, 0, 3)
    EndIf
    Local Const $aDim = _GDIPlus_ImageGetDimension($hImage)
    Local Const $hBitmap = _GDIPlus_BitmapCreateFromScan0(($aDim[0] / 2), ($aDim[1] / 2)), $hGfx = _GDIPlus_ImageGetGraphicsContext($hBitmap)
    If $iBgColor = Default Then
        $iBgColor = 0xFF000000 + _WinAPI_SwitchColor(_GUICtrlRichEdit_GetBkColor($hWnd))
    EndIf
    _GDIPlus_GraphicsClear($hGfx, $iBgColor)
    ;_GDIPlus_GraphicsDrawImageRect($hGfx, $hImage, 0, 0, $aDim[0], $aDim[1])
    _GDIPlus_GraphicsDrawImageRect($hGfx, $hImage, 0, 0, ($aDim[0] /  2), ($aDim[1] / 2))
    _GDIPlus_GraphicsDispose($hGfx)
    Local $binStream = _GDIPlus_StreamImage2BinaryString($hBitmap, "BMP", 100)
    If @error Then
        _GDIPlus_ImageDispose($hImage)
        _GDIPlus_ImageDispose($hBitmap)
        _GDIPlus_Shutdown()
        Return SetError(0, 0, 4)
    EndIf
    Local $binBmp = StringMid($binStream, 31)
    ;Local Const $binRtf = "{\rtf1\viewkind4" & $sFormatFunctions & " {\pict{\*\picprop}" & $sBitmapFunctions & "dibitmap " & $binBmp & "}\par}" ;check out http://www.biblioscape.com/rtf15_spec.htm \par creates line breaks
    Local Const $binRtf = "{\rtf1\viewkind4" & $sFormatFunctions & " {\pict{\*\picprop}" & $sBitmapFunctions & "dibitmap " & $binBmp & "}}" ;check out http://www.biblioscape.com/rtf15_spec.htm
    _GUICtrlRichEdit_AppendText($hWnd, $binRtf)
    $binStream = 0
    $binBmp = 0
    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_ImageDispose($hBitmap)
    _GDIPlus_Shutdown()
    Return 1
EndFunc   ;==>_GUICtrlRichEdit_InsertBitmap

Func _GDIPlus_StreamImage2BinaryString($hBitmap, $sFormat = "JPG", $iQuality = 80, $bSave = False, $sFileName = @TempDir & "\Wolcen_Socket_Roller\Converted.jpg") ;coded by UEZ 2013 build 2014-01-25 (based on the code by Andreik)
    Local $sImgCLSID, $tGUID, $tParams, $tData
    Switch $sFormat
        Case "JPG"
            $sImgCLSID = _GDIPlus_EncodersGetCLSID($sFormat)
            $tGUID = _WinAPI_GUIDFromString($sImgCLSID)
            $tData = DllStructCreate("int Quality")
            DllStructSetData($tData, "Quality", $iQuality) ;quality 0-100
            Local $pData = DllStructGetPtr($tData)
            $tParams = _GDIPlus_ParamInit(1)
            _GDIPlus_ParamAdd($tParams, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, $pData)
        Case "PNG", "BMP", "GIF", "TIF"
            $sImgCLSID = _GDIPlus_EncodersGetCLSID($sFormat)
            $tGUID = _WinAPI_GUIDFromString($sImgCLSID)
        Case Else
            Return SetError(1, 0, 0)
    EndSwitch
    Local $hStream = _WinAPI_CreateStreamOnHGlobal() ;http://msdn.microsoft.com/en-us/library/ms864401.aspx
    If @error Then Return SetError(2, 0, 0)
    _GDIPlus_ImageSaveToStream($hBitmap, $hStream, DllStructGetPtr($tGUID), DllStructGetPtr($tParams))
    If @error Then Return SetError(3, 0, 0)

    Local $hMemory = _WinAPI_GetHGlobalFromStream($hStream) ;http://msdn.microsoft.com/en-us/library/aa911736.aspx
    If @error Then Return SetError(4, 0, 0)
    Local $iMemSize = _MemGlobalSize($hMemory)
    If Not $iMemSize Then Return SetError(5, 0, 0)
    Local $pMem = _MemGlobalLock($hMemory)
    $tData = DllStructCreate("byte[" & $iMemSize & "]", $pMem)
    Local $bData = DllStructGetData($tData, 1)
    _WinAPI_ReleaseStream($hStream) ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms221473(v=vs.85).aspx
    _MemGlobalFree($hMemory)
    If $bSave Then
        Local $hFile = FileOpen($sFileName, 18)
        If @error Then Return SetError(6, 0, $bData)
        FileWrite($hFile, $bData)
        FileClose($hFile)
    EndIf
    Return $bData
EndFunc   ;==>_GDIPlus_StreamImage2BinaryString


Func _GetMin($n1, $n2, $n3=Default, $n4=Default, $n5=Default, $n6=Default, $n7=Default, $n8=Default, $n9=Default, $n10=Default)
    Local $min = $n1, $val
    For $i = 2 To 10
        $val = Eval('n' & $i)
        If IsKeyword($val) Then ExitLoop
        If $val < $min Then $min = $val
    Next
    Return $min
EndFunc

;additional functions end


$finished = False
$finishSoundToPlay = 1
$customFinishSoundPath =  ''
;sleep interval in milliseconds how long to wait after reroll got clicked
$sleepAfterClickRollValue =  200

;game position to support window mode and relative coordinates based on window position
$gameX =  0
$gameY =  0
$borderSize = 0
$titleHeight = 0

;support for multiple different aspect ratios
$baseResolutionWidth =  0
$baseResolutionHeight =  0
$baseRerollClickX =  0
$baseRerollClickY =  0
$baseSocket1TopLeftX = 0
$baseSocket1TopLeftY =  0
$baseSocket1BottomRightX = 0
$baseSocket1BottomRightY = 0
$baseSocket2TopLeftX = 0
$baseSocket2TopLeftY =  0
$baseSocket2BottomRightX = 0
$baseSocket2BottomRightY = 0
$baseSocket3TopLeftX = 0
$baseSocket3TopLeftY =  0
$baseSocket3BottomRightX = 0
$baseSocket3BottomRightY = 0

;5 worked great for 1080p or higher resolutions. But lower than 1080p, it failed. Tested with off1 off1 off3 and 1366x768 resolution
;10 is too high, which matches support blues together as one
$shadesTolerance =  10

$gameWindowHandl = 0

;new color matching code

;offensive1 color data
$offensive1ColorHex = 0xc43b62
$offensive1ColorR = BitShift(BitAND($offensive1ColorHex,0xFF0000),16)
$offensive1ColorG = BitShift(BitAND($offensive1ColorHex, 0xFF00),8)
$offensive1ColorB = BitAND($offensive1ColorHex, 0xFF)
;offensive2 color data
$offensive2ColorHex = 0xe35c5c
$offensive2ColorR = BitShift(BitAND($offensive2ColorHex,0xFF0000),16)
$offensive2ColorG = BitShift(BitAND($offensive2ColorHex, 0xFF00),8)
$offensive2ColorB = BitAND($offensive2ColorHex, 0xFF)
;offensive3 color data
$offensive3ColorHex = 0xd38871
$offensive3ColorR = BitShift(BitAND($offensive3ColorHex,0xFF0000),16)
$offensive3ColorG = BitShift(BitAND($offensive3ColorHex, 0xFF00),8)
$offensive3ColorB = BitAND($offensive3ColorHex, 0xFF)


;defensive1 color data
$defensive1ColorHex = 0x3fae60
$defensive1ColorR = BitShift(BitAND($defensive1ColorHex,0xFF0000),16)
$defensive1ColorG = BitShift(BitAND($defensive1ColorHex, 0xFF00),8)
$defensive1ColorB = BitAND($defensive1ColorHex, 0xFF)
;defensive2 color data
$defensive2ColorHex = 0x7dd389
$defensive2ColorR = BitShift(BitAND($defensive2ColorHex,0xFF0000),16)
$defensive2ColorG = BitShift(BitAND($defensive2ColorHex, 0xFF00),8)
$defensive2ColorB = BitAND($defensive2ColorHex, 0xFF)
;defensive3 color data
$defensive3ColorHex = 0x90ac69
$defensive3ColorR = BitShift(BitAND($defensive3ColorHex,0xFF0000),16)
$defensive3ColorG = BitShift(BitAND($defensive3ColorHex, 0xFF00),8)
$defensive3ColorB = BitAND($defensive3ColorHex, 0xFF)


;support1 color data
$support1ColorHex = 0x3d6ada
$support1ColorR = BitShift(BitAND($support1ColorHex,0xFF0000),16)
$support1ColorG = BitShift(BitAND($support1ColorHex, 0xFF00),8)
$support1ColorB = BitAND($support1ColorHex, 0xFF)
;support2 color data
$support2ColorHex = 0x229abf
$support2ColorR = BitShift(BitAND($support2ColorHex,0xFF0000),16)
$support2ColorG = BitShift(BitAND($support2ColorHex, 0xFF00),8)
$support2ColorB = BitAND($support2ColorHex, 0xFF)
;support3 color data
$support3ColorHex = 0x9cdcf6
$support3ColorR = BitShift(BitAND($support3ColorHex,0xFF0000),16)
$support3ColorG = BitShift(BitAND($support3ColorHex, 0xFF00),8)
$support3ColorB = BitAND($support3ColorHex, 0xFF)

GUISetState(@SW_SHOW,  $MainWindow)


_GUICtrlComboBox_SetCurSel($sock1, 0)
_GUICtrlComboBox_SetCurSel($sock2, 0)
_GUICtrlComboBox_SetCurSel($sock3, 0)

;auto select first finish sound
$customFinishSoundPathCheckExistMp3 =  FileExists(@ScriptDir & "\Sounds\custom.mp3")
$customFinishSoundPathCheckExistWav =  FileExists(@ScriptDir & "\Sounds\custom.wav")
If $customFinishSoundPathCheckExistMp3 Then
	_GUICtrlComboBox_SetCurSel($finishSound, 9)
	$customFinishSoundPath = @ScriptDir & "\Sounds\custom.mp3"
ElseIf $customFinishSoundPathCheckExistWav Then
	_GUICtrlComboBox_SetCurSel($finishSound, 9)
	$customFinishSoundPath = @ScriptDir & "\Sounds\custom.wav"
Else 
	_GUICtrlComboBox_SetCurSel($finishSound, 1)
EndIf




;$socketLogOld = GUICtrlCreateEdit("",293,42,433,306,BitOR($WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY),-1)
;increase limit of textbox
GUICtrlSendMsg($socketLog2, $EM_LIMITTEXT, -1, 0) ; Removes the limit on the number of characters of the 30000
;fix socketlog flashing on update


;$startButtonHdn2 = GUICtrlCreateButton("Start",15,271,231,30,-1,-1)



;set hotkeys if pressed we stop the loop if running
HotKeySet("{ESC}", "stopLoop")
HotKeySet("{TAB}", "stopLoop")
HotKeySet("{ALT}", "stopLoop")




Func stopLoop()
	If $finished == False Then
		;GUICtrlSetData($socketLog, "Aborted!" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Aborted!" & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
	EndIf
    $finished =  True
EndFunc   ;==>stops the loop if running





;welcome text
_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 12, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "Thanks for using my Wolcen socket roller tool!" & @CRLF, "MS Sans Serif", "F2EEDC", 12, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "If you like my work and want to support me, a small donation would make me happy and helps to support this project." & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
;how to use
_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 12, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 12, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "How to use:" & @CRLF, "MS Sans Serif", "F2EEDC", 12, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "1. Make sure you run your game in borderless window or window mode (fullscreen does not work because the npc window closes on ALT+TAB)." & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "2. Talk with 'ZANAFER STARK' NPC where you can reroll your item sockets and place your item for rolling." & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "3. Run the Wolcen_Socket_Roller.exe and select your wanted sockets." & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "4. Click the Start button, your game will automatically come to foreground and it starts rolling (if your mouse is not moving, run the tool with admin rights)." & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "To stop it while its looping, ALT-TAB out of the game to a different program, this will stop the loop." & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "Please post feature requests and bug reports on github:" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)
_GUICtrlRichEdit_AppendTextEx($socketLog2, "https://github.com/Crypto90/Wolcen-Socket-Roller" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 1, 0, 0, 0)


;$sFile = _GetURLImage("http://download1.ts3musicbot.net/BuyMeACoffee_blue.jpg", @TempDir)
;$coffee = GUICtrlCreatePic($sFile,15,312,231,35,-1,-1)

While 1
	Switch GUIGetMsg()
		
		Case $GUI_EVENT_CLOSE,  $idOK
			ExitLoop
		Case $sleepAfterClickRoll
			$sleepAfterClickRollValue = Int(GUICtrlRead($sleepAfterClickRoll))
		Case $finishSound
			$finishSoundToPlay = _GUICtrlComboBox_GetCurSel ( $finishSound )
			If $finishSoundToPlay == 9 Then 
				$sFileOpenDialog = FileOpenDialog("Select a custom finish sound file. Choose a mp3 or wav file.", @WindowsDir & "\", "Audio (*.mp3;*.wav)", $FD_FILEMUSTEXIST)
				If Not @error Then
					$ext = stringRight($sFileOpenDialog, 4)
					FileCopy($sFileOpenDialog, @ScriptDir & "\Sounds\custom" & $ext, $FC_OVERWRITE)
					$customFinishSoundPath =  @ScriptDir & "\Sounds\custom" & $ext
					SoundPlay($customFinishSoundPath, 0)
				EndIf
				FileChangeDir(@ScriptDir)
			ElseIf $finishSoundToPlay > 0 Then
				;SoundPlay(@TempDir & '\Wolcen_Socket_Roller\finished_' & $finishSoundToPlay & '.mp3', 0)
				SoundPlay(@ScriptDir & '\Sounds\finished_' & $finishSoundToPlay & '.mp3', 0)
				;check if a custom file exist, if yes delete it
				$customFinishSoundPathCheckExistMp3 =  FileExists(@ScriptDir & "\Sounds\custom.mp3")
				$customFinishSoundPathCheckExistWav =  FileExists(@ScriptDir & "\Sounds\custom.wav")
				If $customFinishSoundPathCheckExistMp3 Then
					FileDelete(@ScriptDir & "\Sounds\custom.mp3")
				ElseIf $customFinishSoundPathCheckExistWav Then
					FileDelete(@ScriptDir & "\Sounds\custom.wav")
				EndIf
			EndIf
			;0: No sound
			;1: Zelda small item
			;2: Zelda item
			;3: Zelda secret
			;4: Zelda heart container
			;5: Zelda spirit orb
			;6: Zelda hey listen
			;7: Air horn
			;8: FairyTail wow
			;9: custom mp3/wav
		Case $coffee
			$sUrl='https://ko-fi.com/crypto90'
			ShellExecute($sUrl)
			;SoundPlay(@TempDir & '\Wolcen_Socket_Roller\donate.mp3', 0)
			SoundPlay(@ScriptDir & '\Sounds\donate.mp3', 0)
		Case $startButtonHdn2
			$finished = False
			;GUICtrlSetData($socketLog, '')
			_GUICtrlRichEdit_SetSel($socketLog2, 0, -1, True)    ; select all, but hide
			_GUICtrlRichEdit_ReplaceText($socketLog2, "")     ; replace all
			_GUICtrlRichEdit_SetSel($socketLog2, 0, 0)           ; set cursor to start
			Sleep(1000)
			runMain()
	EndSwitch
Wend

; coordinates on 3440 x 1440 resolution

; 1. socket text box. x: 123 y: 677 - x: 268 y: 723
; 2. socket text box x: 123 y: 742 - x: 268 y: 788
; 3. socket text box x: 123 y: 804 - x: 268 y: 854

;Socket 1 area coordinates
;Local $socket1TopLeftX = 123
;Local $socket1TopLeftY = 677
;Local $socket1BottomRightX = 268
;Local $socket1BottomRightY = 723

;Socket 2 area coordinates
;Local $socket2TopLeftX = 123
;Local $socket2TopLeftY = 742
;Local $socket2BottomRightX = 268
;Local $socket2BottomRightY = 788

;Socket 3 area coordinates
;Local $socket3TopLeftX = 123
;Local $socket3TopLeftY = 804
;Local $socket3BottomRightX = 268
;Local $socket3BottomRightY = 854

;reroll button cooridnates
;Local $rerollClickX = 390
;Local $rerollClickY = 1222










; Draw rectangle on screen.
Func _UIA_DrawRect($tLeft, $tRight, $tTop, $tBottom, $color = 0xFF, $PenWidth = 2)
    Local $hDC, $hPen, $obj_orig, $x1, $x2, $y1, $y2
    $x1 = $tLeft
    $x2 = $tRight
    $y1 = $tTop
    $y2 = $tBottom
	
	if $borderSize > 0 Then 
		$x1 =  $x1 +  $borderSize
		$x2 =  $x2 +  $borderSize
	EndIf
	if $titleHeight > 0 Then 
		$y1 =  $y1 +  $titleHeight
		$y2 =  $y2 +  $titleHeight
	EndIf
	
    ;$hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
	
	$hDC = _WinAPI_GetWindowDC($gameWindowHandl)
    $hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color)
    $obj_orig = _WinAPI_SelectObject($hDC, $hPen)

    _WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1) ; horizontal to right
    _WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2) ; vertical down on right
    _WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2) ; horizontal to left right
    _WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1) ; vertical up on left

    ; clear resources
    _WinAPI_SelectObject($hDC, $obj_orig)
    _WinAPI_DeleteObject($hPen)
    _WinAPI_ReleaseDC(0, $hDC)
EndFunc   ;==>_UIA_DrawRect









Func runMain()

	; START EDIT HERE


	; POSSIBLE OPTIONS:
	; offensive1
	; offensive2
	; offensive3

	; defensive1
	; defensive2
	; defensive3

	; support1
	; support2
	; support3

	; if the socket is not needed set it to "unset"
	;unset

	Local $wantedSocket1 = GUICtrlRead($sock1)
	Local $wantedSocket2 = GUICtrlRead($sock2)
	Local $wantedSocket3 = GUICtrlRead($sock3)



	; STOP EDIT HERE







	;check if the game is running not running
	If WinGetProcess("Wolcen: Lords of Mayhem") == -1 Then 
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Wolcen: Lords of Mayhem is not running... Aborting." & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
		$finished =  True
		Return
	EndIf







	WinActivate ( "Wolcen: Lords of Mayhem" )



	;winWaitActive("Wolcen: Lords of Mayhem")
	
	winWaitActive("Wolcen: Lords of Mayhem")
	
	$size = WinGetPos("Wolcen: Lords of Mayhem")
	$gameInnerSize =  WinGetClientSize("Wolcen: Lords of Mayhem")
	$gameWidth = $size[2]
	$gameHeight = $size[3]
	$gameX =  $size[0]
	$gameY =  $size[1]
	
	;GUICtrlSetData($socketLog, "Game resolution before window check: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, 1)
	;GUICtrlSetData($socketLog, "Inner window width: " & $gameInnerSize[0] & " Inner height: " & $gameInnerSize[1] & @CRLF, 1)
	;GUICtrlSetData($socketLog, "Before window check Game X: " & $gameX & " Game Y: " & $gameY & @CRLF, 1)
	
	;if we run window mode, we have borders we need to take care of
	$borderSize = (($gameWidth - $gameInnerSize[0]) /  2)
	$titleHeight = (($gameHeight - $gameInnerSize[1]) - $borderSize)
	
	If $borderSize > 0 Then 
		$gameWidth = $gameWidth - ($borderSize * 2)
		$gameX =  $gameX + $borderSize
	EndIf
	If $titleHeight > 0 Then 
		$gameHeight = (($gameHeight - $titleHeight) - $borderSize)
		$gameY =  $gameY + $titleHeight
	EndIf
	
	
	;GUICtrlSetData($socketLog, "Border size: " & $borderSize & "px Title height: " & $titleHeight & "px" & @CRLF, 1)
	;GUICtrlSetData($socketLog, "After window check Game X: " & $gameX & " Game Y: " & $gameY & @CRLF, 1)
	
	;support for multiple different aspect ratios
	$gameAspectRatio = $gameWidth /  $gameHeight
	
	;21 : 9 ultrawide
	If $gameAspectRatio ==  (3440 / 1440) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  3440
		$baseResolutionHeight =  1440
		$baseRerollClickX =  390
		$baseRerollClickY =  1222
		;base socket1
		$baseSocket1TopLeftX = 210
		$baseSocket1TopLeftY =  677
		$baseSocket1BottomRightX = 268
		$baseSocket1BottomRightY = 723
		;base socket2
		$baseSocket2TopLeftX = 210
		$baseSocket2TopLeftY =  742
		$baseSocket2BottomRightX = 268
		$baseSocket2BottomRightY = 788
		;base socket3
		$baseSocket3TopLeftX = 210
		$baseSocket3TopLeftY =  804
		$baseSocket3BottomRightX = 268
		$baseSocket3BottomRightY = 854
	EndIf
	
	;21 : 9 ultra ultra wide
	If $gameAspectRatio ==  (5120 / 1440) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  5120
		$baseResolutionHeight =  1440
		$baseRerollClickX =  462
		$baseRerollClickY =  1380
		;base socket1
		$baseSocket1TopLeftX = 140
		$baseSocket1TopLeftY =  684
		$baseSocket1BottomRightX = 186
		$baseSocket1BottomRightY = 730
		;base socket2
		$baseSocket2TopLeftX = 140
		$baseSocket2TopLeftY =  730
		$baseSocket2BottomRightX = 186
		$baseSocket2BottomRightY = 798
		;base socket3
		$baseSocket3TopLeftX = 140
		$baseSocket3TopLeftY =  798
		$baseSocket3BottomRightX = 186
		$baseSocket3BottomRightY = 862
	EndIf
	
	;21 : 9 wide -- done
	If $gameAspectRatio ==  (2560 / 1080) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 wide" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 wide" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  2560
		$baseResolutionHeight =  1080
		$baseRerollClickX =  330
		$baseRerollClickY =  921
		;base socket1
		$baseSocket1TopLeftX = 100
		$baseSocket1TopLeftY =  508
		$baseSocket1BottomRightX = 135
		$baseSocket1BottomRightY = 550
		;base socket2
		$baseSocket2TopLeftX = 100
		$baseSocket2TopLeftY =  550
		$baseSocket2BottomRightX = 135
		$baseSocket2BottomRightY = 595
		;base socket3
		$baseSocket3TopLeftX = 100
		$baseSocket3TopLeftY =  595
		$baseSocket3BottomRightX = 135
		$baseSocket3BottomRightY = 645
	EndIf
	
	
	;16 : 10 / 8 : 5 -- done
	If $gameAspectRatio ==  (16 / 10) Then
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:10 / 8:5" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:10 / 8:5" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  1280
		$baseResolutionHeight =  800
		$baseRerollClickX =  227
		$baseRerollClickY =  613
		;base socket1
		$baseSocket1TopLeftX = 72
		$baseSocket1TopLeftY =  336
		$baseSocket1BottomRightX = 98
		$baseSocket1BottomRightY = 365
		;base socket2
		$baseSocket2TopLeftX = 72
		$baseSocket2TopLeftY =  367
		$baseSocket2BottomRightX = 98
		$baseSocket2BottomRightY = 395
		;base socket3
		$baseSocket3TopLeftX = 72
		$baseSocket3TopLeftY =  400
		$baseSocket3BottomRightX = 98
		$baseSocket3BottomRightY = 427
	EndIf
	
	;16 : 9 -- done
	If $gameAspectRatio ==  (16 / 9) Then
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:9" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:9" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  1280
		$baseResolutionHeight =  720
		$baseRerollClickX =  227
		$baseRerollClickY =  613
		;base socket1
		$baseSocket1TopLeftX = 72
		$baseSocket1TopLeftY =  336
		$baseSocket1BottomRightX = 98
		$baseSocket1BottomRightY = 365
		;base socket2
		$baseSocket2TopLeftX = 72
		$baseSocket2TopLeftY =  367
		$baseSocket2BottomRightX = 98
		$baseSocket2BottomRightY = 395
		;base socket3
		$baseSocket3TopLeftX = 72
		$baseSocket3TopLeftY =  400
		$baseSocket3BottomRightX = 98
		$baseSocket3BottomRightY = 427
	EndIf
	
	;5 : 3
	If $gameAspectRatio ==  (5 / 3) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 5:3" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 5:3" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  1280
		$baseResolutionHeight =  768
		$baseRerollClickX =  227
		$baseRerollClickY =  613
		;base socket1
		$baseSocket1TopLeftX = 72
		$baseSocket1TopLeftY =  336
		$baseSocket1BottomRightX = 98
		$baseSocket1BottomRightY = 365
		;base socket2
		$baseSocket2TopLeftX = 72
		$baseSocket2TopLeftY =  365
		$baseSocket2BottomRightX = 98
		$baseSocket2BottomRightY = 395
		;base socket3
		$baseSocket3TopLeftX = 72
		$baseSocket3TopLeftY =  395
		$baseSocket3BottomRightX = 98
		$baseSocket3BottomRightY = 427
	EndIf
	
	;5 : 4
	If $gameAspectRatio ==  (5 / 4) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 5:4" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 5:4" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  1280
		$baseResolutionHeight =  1024
		$baseRerollClickX =  227
		$baseRerollClickY =  613
		;base socket1
		$baseSocket1TopLeftX = 72
		$baseSocket1TopLeftY =  336
		$baseSocket1BottomRightX = 98
		$baseSocket1BottomRightY = 365
		;base socket2
		$baseSocket2TopLeftX = 72
		$baseSocket2TopLeftY =  365
		$baseSocket2BottomRightX = 98
		$baseSocket2BottomRightY = 395
		;base socket3
		$baseSocket3TopLeftX = 72
		$baseSocket3TopLeftY =  395
		$baseSocket3BottomRightX = 98
		$baseSocket3BottomRightY = 427
	EndIf
	
	;4 : 3
	If $gameAspectRatio ==  (4 / 3) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 4:3" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 4:3" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  800
		$baseResolutionHeight =  600
		$baseRerollClickX =  140
		$baseRerollClickY =  383
		;base socket1
		$baseSocket1TopLeftX = 41
		$baseSocket1TopLeftY =  209
		$baseSocket1BottomRightX = 58
		$baseSocket1BottomRightY = 228
		;base socket2
		$baseSocket2TopLeftX = 41
		$baseSocket2TopLeftY =  228
		$baseSocket2BottomRightX = 58
		$baseSocket2BottomRightY = 248
		;base socket3
		$baseSocket3TopLeftX = 41
		$baseSocket3TopLeftY =  248
		$baseSocket3BottomRightX = 58
		$baseSocket3BottomRightY = 270
	EndIf
	
	;1366x768 - resolution was buggy with native 16:9 so it gets an explicit entry -- done
	If $gameAspectRatio ==  (1366 / 768) Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:9" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:9" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  1366
		$baseResolutionHeight =  768
		$baseRerollClickX =  239
		$baseRerollClickY =  657
		;base socket1
		$baseSocket1TopLeftX = 68
		$baseSocket1TopLeftY =  360
		$baseSocket1BottomRightX = 96
		$baseSocket1BottomRightY = 391
		;base socket2
		$baseSocket2TopLeftX = 68
		$baseSocket2TopLeftY =  391
		$baseSocket2BottomRightX = 96
		$baseSocket2BottomRightY = 425
		;base socket3
		$baseSocket3TopLeftX = 68
		$baseSocket3TopLeftY =  425
		$baseSocket3BottomRightX = 96
		$baseSocket3BottomRightY = 460
	EndIf
	
	
	;1 : 1 -- unsupported
	;24 : 9 -- currently unsupported
	;3 : 2 -- currently unsupported
	;17 : 9 -- currently unsupported
	
	
	;if we have no match on above checks, we mostly run with a minimal different 16:9 ratio with some special resolution, we run default 16:9 logic here
	If $baseResolutionWidth == 0 Then 
		;GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio could not get autodetected, fallback to default: 16:9" & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio could not get autodetected, fallback to default: 16:9" & @CRLF, "MS Sans Serif", "FFFF00", 8, 0, 0, 0, 0)
		$baseResolutionWidth =  1280
		$baseResolutionHeight =  720
		$baseRerollClickX =  227
		$baseRerollClickY =  613
		;base socket1
		$baseSocket1TopLeftX = 72
		$baseSocket1TopLeftY =  336
		$baseSocket1BottomRightX = 98
		$baseSocket1BottomRightY = 365
		;base socket2
		$baseSocket2TopLeftX = 72
		$baseSocket2TopLeftY =  367
		$baseSocket2BottomRightX = 98
		$baseSocket2BottomRightY = 395
		;base socket3
		$baseSocket3TopLeftX = 72
		$baseSocket3TopLeftY =  400
		$baseSocket3BottomRightX = 98
		$baseSocket3BottomRightY = 427
	EndIf
	
	
	
	
	
	
	
	
	

	;reroll button cooridnates
	$rerollClickX = Round( ($baseRerollClickX / $baseResolutionWidth) * $gameWidth )
	$rerollClickY = Round( ($baseRerollClickY / $baseResolutionHeight) * $gameHeight )
	
	;window mode check
	if $borderSize > 0 Then 
		$rerollClickX =  $rerollClickX +  $borderSize
	EndIf
	if $titleHeight > 0 Then 
		$rerollClickY =  $rerollClickY +  $titleHeight
	EndIf
	
	
	$checkActiveWindowTitle = WinGetTitle("[ACTIVE]")
	If $checkActiveWindowTitle <> "Wolcen: Lords of Mayhem" Then
		;GUICtrlSetData($socketLog, "Wolcen: Lords of Mayhem is not running... Aborting." & @CRLF, 1)
		_GUICtrlRichEdit_AppendTextEx($socketLog2, "Wolcen: Lords of Mayhem is not running... Aborting." & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
		$finished =  True
		Return
	EndIf


	








	;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: " & getSocket(1))
	;MsgBox($MB_SYSTEMMODAL, "", "Socket 2: " & getSocket(2))
	;MsgBox($MB_SYSTEMMODAL, "", "Socket 3: " & getSocket(3))
	;GUICtrlSetData($socketLog, "-----------------------------------------------------------------------------------------------" & @CRLF, 1)
	_GUICtrlRichEdit_AppendTextEx($socketLog2, "-----------------------------------------------------------------------------------------------" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
	;GUICtrlSetData($socketLog, "Started..." & @CRLF, 1)
	_GUICtrlRichEdit_AppendTextEx($socketLog2, "Started..." & @CRLF, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
	$sString = "Searching for:  " & $wantedSocket1 & "  --  " & $wantedSocket2 & "  --  " & $wantedSocket3
	;append to log edit box
	;GUICtrlSetData($socketLog, $sString & @CRLF, 1)
	_GUICtrlRichEdit_AppendTextEx($socketLog2, $sString & @CRLF, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
	;GUICtrlSetData($socketLog, "-----------------------------------------------------------------------------------------------" & @CRLF & @CRLF, 1)
	_GUICtrlRichEdit_AppendTextEx($socketLog2, "-----------------------------------------------------------------------------------------------" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
	
	
	$previousSocket1 =  ''
	$previousSocket2 =  ''
	$previousSocket3 =  ''
	
	$unchangedSocketsCounter =  0
	$rollCounter =  0
	$maxRollsValue =  Int(GUICtrlRead($maxRolls))
	
	$gameWindowHandl =  WinGetHandle ( "Wolcen: Lords of Mayhem" )
	
	
	While $finished == False
		
		If WinGetTitle("[ACTIVE]") <> "Wolcen: Lords of Mayhem" Then
			stopLoop()
			ExitLoop
		EndIf
		
		
	    If  $maxRollsValue > 0 And $rollCounter >= $maxRollsValue Then 
			$finished =  True
			;GUICtrlSetData($socketLog, "Max rolls of " & $maxRollsValue & " reached. Aborting." & @CRLF, 1)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Max rolls of " & $maxRollsValue & " reached. Aborting." & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
			ExitLoop
		EndIf
		
		
		$gotSocket1 =  getSocket(1)
		$gotSocket2 =  'unset'
		$gotSocket3 =  'unset'
		
		
		
		;prevent unneeded area checks start
		;if found socket is not in wanted, reroll directly
		If $gotSocket1 <> $wantedSocket1 And $gotSocket1 <> $wantedSocket2 And $gotSocket1 <> $wantedSocket3 And $wantedSocket2 <> "any" And $wantedSocket3 <> "any" Then
			$gotSocket2 =  'ignored'
			$gotSocket3 =  'ignored'
			
			
			
			
			
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $rollCounter , "MS Sans Serif", "FF8C00", 8, 0, 0, 0, 0) ;rollcounter
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $timestamp, "MS Sans Serif", "777777", 8, 0, 0, 0, 0) ;timestamp
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			
			;adding screenshots...
			;socket1
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 1: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket1.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket1, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			;socket2
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 2: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			If $gotSocket2 <> 'ignored' Then
				_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket2.jpg')
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			EndIf
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket2, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			;socket3
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 3: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			If $gotSocket3 <> 'ignored' Then
				_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket3.jpg')
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			EndIf
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket3, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;end line
			
			
			;$sString = "Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;append to log edit box
		    ;GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			;_GUICtrlRichEdit_AppendTextEx($socketLog2, $sString & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			
			$previousSocket1 =  $gotSocket1
			$previousSocket2 =  $gotSocket2
			$previousSocket3 =  $gotSocket3
			
			$rollCounter =  $rollCounter +  1
			
			;sleep a random value between 1 and 50 milliseconds to produce some human behavior just for future cases if click ratio get measured.
			Sleep(Random(1, 50, 1))
			MouseClick($MOUSE_CLICK_LEFT, ($rerollClickX +  Random(1, 10, 1)), $rerollClickY, 1)
			Sleep($sleepAfterClickRollValue)
			ContinueLoop
		EndIf
		
		;prevent unneeded area checks
		If $gotSocket1 <> 'unset' Then 
			$gotSocket2 =  getSocket(2)
			
			;if found socket is not in wanted, reroll directly
			If $gotSocket2 <> $wantedSocket1 And $gotSocket2 <> $wantedSocket2 And $gotSocket2 <> $wantedSocket3 And $wantedSocket2 <> "any" And $wantedSocket3 <> "any" Then
				$gotSocket3 =  'ignored'
				$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $rollCounter , "MS Sans Serif", "FF8C00", 8, 0, 0, 0, 0) ;rollcounter
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $timestamp, "MS Sans Serif", "777777", 8, 0, 0, 0, 0) ;timestamp
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				
				;adding screenshots...
				;socket1
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 1: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket1.jpg')
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket1, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				;socket2
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 2: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				If $gotSocket2 <> 'ignored' Then
					_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket2.jpg')
					_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
				EndIf
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket2, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				;socket3
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 3: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				If $gotSocket3 <> 'ignored' Then
					_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket3.jpg')
					_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
				EndIf
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket3, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;end line
				
				;$sString = "Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;append to log edit box
				;GUICtrlSetData($socketLog, $sString & @CRLF, 1)
				;_GUICtrlRichEdit_AppendTextEx($socketLog2, $sString & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				
				$previousSocket1 =  $gotSocket1
				$previousSocket2 =  $gotSocket2
				$previousSocket3 =  $gotSocket3
				
				$rollCounter =  $rollCounter +  1
				;sleep a random value between 1 and 50 milliseconds to produce some human behavior just for future cases if click ratio get measured.
				Sleep(Random(1, 50, 1))
				MouseClick($MOUSE_CLICK_LEFT, ($rerollClickX +  Random(1, 10, 1)), $rerollClickY, 1)
				Sleep($sleepAfterClickRollValue)
				ContinueLoop
			EndIf
			
		EndIf
		If $gotSocket2 <> 'unset' Then 
			$gotSocket3 =  getSocket(3)
			
			;if found socket is not in wanted, reroll directly
			If $gotSocket3 <> $wantedSocket1 And $gotSocket3 <> $wantedSocket2 And $gotSocket3 <> $wantedSocket3 And $wantedSocket2 <> "any" And $wantedSocket3 <> "any"  Then
				$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $rollCounter , "MS Sans Serif", "FF8C00", 8, 0, 0, 0, 0) ;rollcounter
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $timestamp, "MS Sans Serif", "777777", 8, 0, 0, 0, 0) ;timestamp
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				
				;adding screenshots...
				;socket1
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 1: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket1.jpg')
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket1, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				;socket2
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 2: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket2.jpg')
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket2, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
				;socket3
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 3: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket3.jpg')
				_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
				_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket3, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;end line
				
				;$sString = "Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;append to log edit box
				;GUICtrlSetData($socketLog, $sString & @CRLF, 1)
				;_GUICtrlRichEdit_AppendTextEx($socketLog2, $sString & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
				
				$previousSocket1 =  $gotSocket1
				$previousSocket2 =  $gotSocket2
				$previousSocket3 =  $gotSocket3
				
				$rollCounter =  $rollCounter +  1
				;sleep a random value between 1 and 50 milliseconds to produce some human behavior just for future cases if click ratio get measured.
				Sleep(Random(1, 50, 1))
				MouseClick($MOUSE_CLICK_LEFT, ($rerollClickX +  Random(1, 10, 1)), $rerollClickY, 1)
				Sleep($sleepAfterClickRollValue)
				ContinueLoop
			EndIf
			
		EndIf
		;prevent unneeded area checks finished
		
		
		
	   	If ($gotSocket1 == $wantedSocket1 And ($gotSocket2 == $wantedSocket2 Or $wantedSocket2 ==  "any") And ($gotSocket3 == $wantedSocket3 Or $wantedSocket3 ==  "any")) Or ($gotSocket1 == $wantedSocket1 And ($gotSocket2 == $wantedSocket3 Or $wantedSocket3 ==  "any") And ($gotSocket3 == $wantedSocket2 Or $wantedSocket2 ==  "any"))  Or (($gotSocket1 == $wantedSocket2 Or $wantedSocket2 ==  "any") And $gotSocket2 == $wantedSocket1 And ($gotSocket3 == $wantedSocket3 Or $wantedSocket3 ==  "any"))  Or (($gotSocket1 == $wantedSocket2 Or $wantedSocket2 ==  "any") And ($gotSocket2 == $wantedSocket3 Or $wantedSocket3 ==  "any") And $gotSocket3 == $wantedSocket1)  Or (($gotSocket1 == $wantedSocket3 Or $wantedSocket3 ==  "any") And $gotSocket2 == $wantedSocket1 And ($gotSocket3 == $wantedSocket2 Or $wantedSocket2 ==  "any"))  Or (($gotSocket1 == $wantedSocket3 Or $wantedSocket3 ==  "any") And ($gotSocket2 == $wantedSocket2 Or $wantedSocket2 ==  "any") And $gotSocket3 == $wantedSocket1) Then
			;found a searched combination
			$finished = True
			
			If $finishSoundToPlay == 9 Then
				SoundPlay($customFinishSoundPath, 0)
			ElseIf $finishSoundToPlay > 0 Then
				;SoundPlay(@TempDir & '\Wolcen_Socket_Roller\finished_' & $finishSoundToPlay & '.mp3', 0)
				SoundPlay(@ScriptDir & '\Sounds\finished_' & $finishSoundToPlay & '.mp3', 0)
			EndIf
			
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $rollCounter , "MS Sans Serif", "FF8C00", 8, 0, 0, 0, 0) ;rollcounter
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $timestamp, "MS Sans Serif", "777777", 8, 0, 0, 0, 0) ;timestamp
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			
			;adding screenshots...
			;socket1
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 1: ", "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket1.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket1, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0) ;line
			;socket2
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 2: ", "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket2.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket2, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0) ;line
			;socket3
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 3: ", "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket3.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket3, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0) ;end line
			
			
			;$sString = "Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
			;GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			;_GUICtrlRichEdit_AppendTextEx($socketLog2, $sString & @CRLF, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			;GUICtrlSetData($socketLog, "-----------------------------------------------------------------------------------------------" & @CRLF & @CRLF, 1)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "-----------------------------------------------------------------------------------------------" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			;GUICtrlSetData($socketLog, "Finished after " & $rollCounter & " rolls!" & @CRLF, 1)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Finished after " & $rollCounter & " rolls!" & @CRLF, "MS Sans Serif", "00FF00", 8, 0, 0, 0, 0)
			ExitLoop
		Else 
			;no wanted combination found, reroll
			;speed up checks, do no sleep if one of the sockets changed from previous roll
		  If (($previousSocket1 <> $gotSocket1) Or ($previousSocket2 <> $gotSocket2 Or $wantedSocket2 == "any") Or ($previousSocket3 <> $gotSocket3 Or $wantedSocket3 == "any")) Then
			;sockets changed for sure, so we can reroll instantly, update previous socket variables
			
			
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $rollCounter , "MS Sans Serif", "FF8C00", 8, 0, 0, 0, 0) ;rollcounter
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $timestamp, "MS Sans Serif", "777777", 8, 0, 0, 0, 0) ;timestamp
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | " , "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			
			;adding screenshots...
			;socket1
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 1: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket1.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket1, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			;socket2
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 2: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket2.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket2, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " | ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;line
			;socket3
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "Socket 3: ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_InsertBitmap($socketLog2, @TempDir & '\Wolcen_Socket_Roller\socket3.jpg')
			_GUICtrlRichEdit_AppendTextEx($socketLog2, " ", "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0);space
			_GUICtrlRichEdit_AppendTextEx($socketLog2, $gotSocket3, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			_GUICtrlRichEdit_AppendTextEx($socketLog2, "" & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0) ;end line
			
			;$sString = "Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;append to log edit box
		    ;GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			;_GUICtrlRichEdit_AppendTextEx($socketLog2, $sString & @CRLF, "MS Sans Serif", "F2EEDC", 8, 0, 0, 0, 0)
			
			$previousSocket1 =  $gotSocket1
			$previousSocket2 =  $gotSocket2
			$previousSocket3 =  $gotSocket3
			
			$rollCounter =  $rollCounter +  1
			
			;sleep a random value between 1 and 50 milliseconds to produce some human behavior just for future cases if click ratio get measured.
			Sleep(Random(1, 50, 1))
			MouseClick($MOUSE_CLICK_LEFT, ($rerollClickX +  Random(1, 10, 1)), $rerollClickY, 1)
			Sleep($sleepAfterClickRollValue)
			ContinueLoop 
		  Else
			;sockets unchanged, in this case the server/game was slower to redisplay the new sockets or we get two times in a row the same roll results
			Sleep(100)
			$unchangedSocketsCounter =  $unchangedSocketsCounter +  1
			; 3 times unchanged, which means in 300ms nothing changed, we force reroll
			If $unchangedSocketsCounter >= 3 Then 
				$previousSocket1 =  ''
				$previousSocket2 =  ''
				$previousSocket3 =  ''
				$unchangedSocketsCounter =  0
			EndIf
			
		  EndIf
		  
		  
		  

		  If WinGetTitle("[ACTIVE]") <> "Wolcen: Lords of Mayhem" Then
			If $finished == False Then
				;GUICtrlSetData($socketLog, "Aborted!" & @CRLF, 1)
				_GUICtrlRichEdit_AppendTextEx($socketLog2, "Aborted!" & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
			EndIf
			$finished =  True
			ExitLoop
		  EndIf
		EndIf
		
		
	WEnd

EndFunc




; offensive 1 color: c43b62
; offensive 2 color: e35c5c
; offensive 3 color: d38871

; defensive 1 color: 3fae60
; defensive 2 color: 7dd389
; defensive 3 color: 90ac69

; support 1 color: 3d6ada
; support 2 color: 229abf
; support 3 color: 9cdcf6

Func getSocket($socketNumberToCheck)
	
	;debug
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Scanning area for socket: " & $socketNumberToCheck & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
	
	
   ;recalculate coordinates based on current resolution
	$size = WinGetPos("Wolcen: Lords of Mayhem")
	$gameInnerSize =  WinGetClientSize("Wolcen: Lords of Mayhem")
	$gameWidth = $size[2]
	$gameHeight = $size[3]
	$gameX =  $size[0]
	$gameY =  $size[1]
	
	;if we run window mode, we have borders we need to take care of
	$borderSize = (($gameWidth - $gameInnerSize[0]) /  2)
	$titleHeight = (($gameHeight - $gameInnerSize[1]) - $borderSize)
	
	If $borderSize > 0 Then 
		$gameWidth = $gameWidth - ($borderSize * 2)
		$gameX =  $gameX + $borderSize
	EndIf
	If $titleHeight > 0 Then 
		$gameHeight = (($gameHeight - $titleHeight) - $borderSize)
		$gameY =  $gameY + $titleHeight
	EndIf
	
	
	
	
	
   Local $socketTopLeftXSearch = 0
   Local $socketTopLeftYSearch = 0
   Local $socketBottomRightXSearch = 0
   Local $socketBottomRightYSearch = 0
   
   

   If $socketNumberToCheck == 1 Then
		;Socket 1 area coordinates
		$socket1TopLeftX = Round( ($baseSocket1TopLeftX / $baseResolutionWidth) * $gameWidth )
		$socket1TopLeftY =  Round( ($baseSocket1TopLeftY / $baseResolutionHeight) * $gameHeight )
		$socket1BottomRightX = Round( ($baseSocket1BottomRightX / $baseResolutionWidth) * $gameWidth )
		$socket1BottomRightY = Round( ($baseSocket1BottomRightY / $baseResolutionHeight) * $gameHeight )
		
		;capture area for logging screenshot
		_ScreenCapture_CaptureWnd(@TempDir & '\Wolcen_Socket_Roller\socket1.jpg', $gameWindowHandl, $socket1TopLeftX + $borderSize, $socket1TopLeftY + $titleHeight, $socket1BottomRightX + $borderSize, $socket1BottomRightY + $titleHeight)
		
		;draw rect
		_UIA_DrawRect($socket1TopLeftX, $socket1BottomRightX, $socket1TopLeftY, $socket1BottomRightY, 0x0000FF, 2)
	  
	  $socketTopLeftXSearch = $socket1TopLeftX
	  $socketTopLeftYSearch = $socket1TopLeftY
	  $socketBottomRightXSearch = $socket1BottomRightX
	  $socketBottomRightYSearch = $socket1BottomRightY
   ElseIf $socketNumberToCheck == 2 Then
		;Socket 2 area coordinates
		$socket2TopLeftX = Round( ($baseSocket2TopLeftX / $baseResolutionWidth) * $gameWidth )
		$socket2TopLeftY = Round( ($baseSocket2TopLeftY / $baseResolutionHeight) * $gameHeight )
		$socket2BottomRightX = Round( ($baseSocket2BottomRightX / $baseResolutionWidth) * $gameWidth )
		$socket2BottomRightY = Round( ($baseSocket2BottomRightY / $baseResolutionHeight) * $gameHeight )
		
		;capture area for logging screenshot
		_ScreenCapture_CaptureWnd(@TempDir & '\Wolcen_Socket_Roller\socket2.jpg', $gameWindowHandl, $socket2TopLeftX + $borderSize, $socket2TopLeftY + $titleHeight, $socket2BottomRightX + $borderSize, $socket2BottomRightY + $titleHeight)
		;draw rect
		_UIA_DrawRect($socket2TopLeftX, $socket2BottomRightX, $socket2TopLeftY, $socket2BottomRightY, 0x0000FF, 2)

	  
	  $socketTopLeftXSearch = $socket2TopLeftX
	  $socketTopLeftYSearch = $socket2TopLeftY
	  $socketBottomRightXSearch = $socket2BottomRightX
	  $socketBottomRightYSearch = $socket2BottomRightY
   ElseIf $socketNumberToCheck == 3 Then
		;Socket 3 area coordinates
		$socket3TopLeftX = Round( ($baseSocket3TopLeftX / $baseResolutionWidth) * $gameWidth )
		$socket3TopLeftY = Round( ($baseSocket3TopLeftY / $baseResolutionHeight) * $gameHeight )
		$socket3BottomRightX = Round( ($baseSocket3BottomRightX / $baseResolutionWidth) * $gameWidth )
		$socket3BottomRightY = Round( ($baseSocket3BottomRightY / $baseResolutionHeight) * $gameHeight )
		
		;capture area for logging screenshot
		_ScreenCapture_CaptureWnd(@TempDir & '\Wolcen_Socket_Roller\socket3.jpg', $gameWindowHandl, $socket3TopLeftX + $borderSize, $socket3TopLeftY + $titleHeight, $socket3BottomRightX + $borderSize, $socket3BottomRightY + $titleHeight)
		;draw rect
		_UIA_DrawRect($socket3TopLeftX, $socket3BottomRightX, $socket3TopLeftY, $socket3BottomRightY, 0x0000FF, 2)

	  
	  $socketTopLeftXSearch = $socket3TopLeftX
	  $socketTopLeftYSearch = $socket3TopLeftY
	  $socketBottomRightXSearch = $socket3BottomRightX
	  $socketBottomRightYSearch = $socket3BottomRightY
   EndIf

	;reroll button cooridnates
	$rerollClickX = Round( ($baseRerollClickX / $baseResolutionWidth) * $gameWidth )		
	$rerollClickY = Round( ($baseRerollClickY / $baseResolutionHeight) * $gameHeight )
	
	;window mode check
	if $borderSize > 0 Then 
		$rerollClickX =  $rerollClickX +  $borderSize
	EndIf
	if $titleHeight > 0 Then 
		$rerollClickY =  $rerollClickY +  $titleHeight
	EndIf
	
	
	
	
	;debug
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Scanning area for socket: " & $socketNumberToCheck & " x1: " & $socketTopLeftXSearch + $borderSize & " y1: " & $socketTopLeftYSearch + $titleHeight & " x2: " & $socketBottomRightXSearch + $borderSize & " y2: " & $socketBottomRightYSearch + $titleHeight & @CRLF, "MS Sans Serif", "FF0000", 8, 0, 0, 0, 0)
	
	;MouseMove($socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, 0)
	
   ;offensive socket checks
    ;$checkSocketOffensive1 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $offensive1ColorHex, $shadesTolerance, 1, $gameWindowHandl)
    $checkSocketOffensive1 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $offensive1ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'offensive1'
		Return getSocketTypeForPixel($checkSocketOffensive1[0], $checkSocketOffensive1[1])
	EndIf
    ;$checkSocketOffensive2 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $offensive2ColorHex, $shadesTolerance, 1, $gameWindowHandl)
    $checkSocketOffensive2 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $offensive2ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'offensive2'
		Return getSocketTypeForPixel($checkSocketOffensive2[0], $checkSocketOffensive2[1])
	EndIf
	;$checkSocketOffensive3 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $offensive3ColorHex, $shadesTolerance, 1, $gameWindowHandl)
	$checkSocketOffensive3 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $offensive3ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'offensive3'
		Return getSocketTypeForPixel($checkSocketOffensive3[0], $checkSocketOffensive3[1])
	EndIf
	
	
   ; defensive socket check
    ;$checkSocketDefensive1 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $defensive1ColorHex, $shadesTolerance, 1, $gameWindowHandl)
    $checkSocketDefensive1 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $defensive1ColorHex, $shadesTolerance)
    If Not @error Then
		;Return 'defensive1'
		Return getSocketTypeForPixel($checkSocketDefensive1[0], $checkSocketDefensive1[1])
	EndIf
	;$checkSocketDefensive2 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $defensive2ColorHex, $shadesTolerance, 1, $gameWindowHandl)
	$checkSocketDefensive2 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $defensive2ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'defensive2'
		Return getSocketTypeForPixel($checkSocketDefensive2[0], $checkSocketDefensive2[1])
	EndIf
	;$checkSocketDefensive3 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $defensive3ColorHex, $shadesTolerance, 1, $gameWindowHandl)
	$checkSocketDefensive3 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $defensive3ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'defensive3'
		Return getSocketTypeForPixel($checkSocketDefensive3[0], $checkSocketDefensive3[1])
	EndIf
	
	
	
   ; support socket check
	;$checkSocketSupport1 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $support1ColorHex, $shadesTolerance, 1, $gameWindowHandl)
	$checkSocketSupport1 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $support1ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'support1'
		Return getSocketTypeForPixel($checkSocketSupport1[0], $checkSocketSupport1[1])
	EndIf
    ;$checkSocketSupport2 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $support2ColorHex, $shadesTolerance, 1, $gameWindowHandl)
    $checkSocketSupport2 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $support2ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'support2'
		Return getSocketTypeForPixel($checkSocketSupport2[0], $checkSocketSupport2[1])
	EndIf
	;$checkSocketSupport3 = PixelSearch($socketTopLeftXSearch + $borderSize, $socketTopLeftYSearch + $titleHeight, $socketBottomRightXSearch + $borderSize, $socketBottomRightYSearch + $titleHeight, $support3ColorHex, $shadesTolerance, 1, $gameWindowHandl)
	$checkSocketSupport3 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, $support3ColorHex, $shadesTolerance)
	If Not @error Then
		;Return 'support3'
		Return getSocketTypeForPixel($checkSocketSupport3[0], $checkSocketSupport3[1])
	EndIf
    
    
	;if no socket found
	Return 'unset'
EndFunc

Func getSocketTypeForPixel($iX2, $iY2)
	
	$iX =  $iX2
	$iY =  $iY2
	
	$socketDetected = 'unset'
	
	;new method using euclidean distance between colors _euclideanDist($x1, $y1, $x2, $y2)
	
	
	;$gameWindowHandl =  WinGetHandle ( "Wolcen: Lords of Mayhem" );we define it before this function call
	;1. we need to scan the desired area pixel by pixel 
	
	;debug output
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Scanning pixels from x1: " & ($socketTopLeftXSearch + $borderSize) & " to x2: " & ($socketBottomRightXSearch + $borderSize) & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Scanning pixels from y1: " & ($socketTopLeftYSearch + $titleHeight) & " to y2: " & ($socketBottomRightYSearch + $titleHeight) & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Total amount of pixels for scanning 1 socket: " & (($socketTopLeftYSearch + $titleHeight) * ($socketBottomRightYSearch + $titleHeight)) & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	
	$currentLowestColorDifference =  -1
	$iColor = PixelGetColor ( $iX, $iY, $gameWindowHandl )
	
	
	$Hex = Execute("0x" & Hex($iColor, 6))

	
	
	$scannedR = BitShift(BitAND($Hex,0xFF0000),16)
	$scannedG = BitShift(BitAND($Hex, 0xFF00),8)
	$scannedB = BitAND($Hex, 0xFF)
	
	;DEBUG
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Color found for X: " & $iX & " and Y: " & $iY & " is: " & $iColor & " | Hex: " & $Hex & " | R:" & $scannedR & " G: " & $scannedG & " B: " & $scannedB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)

	
	
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Offensive1 R:" & $offensive1ColorR & " G: " & $offensive1ColorG & " B: " & $offensive1ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Offensive2 R:" & $offensive2ColorR & " G: " & $offensive2ColorG & " B: " & $offensive2ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Offensive3 R:" & $offensive3ColorR & " G: " & $offensive3ColorG & " B: " & $offensive3ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Defensive1 R:" & $defensive1ColorR & " G: " & $defensive1ColorG & " B: " & $defensive1ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Defensive2 R:" & $defensive2ColorR & " G: " & $defensive2ColorG & " B: " & $defensive2ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Defensive3 R:" & $defensive3ColorR & " G: " & $defensive3ColorG & " B: " & $defensive3ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Support1 R:" & $support1ColorR & " G: " & $support1ColorG & " B: " & $support1ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Support2 R:" & $support2ColorR & " G: " & $support2ColorG & " B: " & $support2ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "Support3 R:" & $support3ColorR & " G: " & $support3ColorG & " B: " & $support3ColorB & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	
	
	;2. calculate color distance for each socket and unset color
	;$offensive1
	$ColorDistOffensive1 = Sqrt(($scannedR - $offensive1ColorR) ^ 2 + ($scannedG - $offensive1ColorG) ^ 2 + ($scannedB - $offensive1ColorB) ^ 2)
	If $currentLowestColorDifference == -1 Or $ColorDistOffensive1 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistOffensive1
	EndIf
	;$offensive2
	$ColorDistOffensive2 = Sqrt(($scannedR - $offensive2ColorR) ^ 2 + ($scannedG - $offensive2ColorG) ^ 2 + ($scannedB - $offensive2ColorB) ^ 2)
	If $ColorDistOffensive2 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistOffensive2
	EndIf
	;$offensive3
	$ColorDistOffensive3 = Sqrt(($scannedR - $offensive3ColorR) ^ 2 + ($scannedG - $offensive3ColorG) ^ 2 + ($scannedB - $offensive3ColorB) ^ 2)
	If $ColorDistOffensive3 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistOffensive3
	EndIf
	
	;defensive1
	$ColorDistDefensive1 = Sqrt(($scannedR - $defensive1ColorR) ^ 2 + ($scannedG - $defensive1ColorG) ^ 2 + ($scannedB - $defensive1ColorB) ^ 2)
	If $ColorDistDefensive1 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistDefensive1
	EndIf
	;defensive2
	$ColorDistDefensive2 = Sqrt(($scannedR - $defensive2ColorR) ^ 2 + ($scannedG - $defensive2ColorG) ^ 2 + ($scannedB - $defensive2ColorB) ^ 2)
	If $ColorDistDefensive2 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistDefensive2
	EndIf
	;defensive3
	$ColorDistDefensive3 = Sqrt(($scannedR - $defensive3ColorR) ^ 2 + ($scannedG - $defensive3ColorG) ^ 2 + ($scannedB - $defensive3ColorB) ^ 2)
	If $ColorDistDefensive3 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistDefensive3
	EndIf
	
	;support1
	$ColorDistSupport1 = Sqrt(($scannedR - $support1ColorR) ^ 2 + ($scannedG - $support1ColorG) ^ 2 + ($scannedB - $support1ColorB) ^ 2)
	If $ColorDistSupport1 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistSupport1
	EndIf
	;support2
	$ColorDistSupport2 = Sqrt(($scannedR - $support2ColorR) ^ 2 + ($scannedG - $support2ColorG) ^ 2 + ($scannedB - $support2ColorB) ^ 2)
	If $ColorDistSupport2 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistSupport2
	EndIf
	;support3
	$ColorDistSupport3 = Sqrt(($scannedR - $support3ColorR) ^ 2 + ($scannedG - $support3ColorG) ^ 2 + ($scannedB - $support3ColorB) ^ 2)
	If $ColorDistSupport3 < $currentLowestColorDifference Then
		$currentLowestColorDifference = $ColorDistSupport3
	EndIf
	
	;DEBUG
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistOffensive1: " & $ColorDistOffensive1 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistOffensive2: " & $ColorDistOffensive2 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistOffensive3: " & $ColorDistOffensive3 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)

	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistDefensive1: " & $ColorDistDefensive1 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistDefensive2: " & $ColorDistDefensive2 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistDefensive3: " & $ColorDistDefensive3 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistSupport1: " & $ColorDistSupport1 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistSupport2: " & $ColorDistSupport2 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "$ColorDistSupport3: " & $ColorDistSupport3 & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)




	
	
	; 3. now we have the smallest color difference, now lets check which one it is
	If $ColorDistOffensive1 == $currentLowestColorDifference Then 
		$socketDetected = 'offensive1'
	ElseIf $ColorDistOffensive2 == $currentLowestColorDifference Then
		$socketDetected = 'offensive2'
	ElseIf $ColorDistOffensive3 == $currentLowestColorDifference Then
		$socketDetected = 'offensive3'
	ElseIf $ColorDistDefensive1 == $currentLowestColorDifference Then
		$socketDetected = 'defensive1'
	ElseIf $ColorDistDefensive2 == $currentLowestColorDifference Then
		$socketDetected = 'defensive2'
	ElseIf $ColorDistDefensive3 == $currentLowestColorDifference Then
		$socketDetected = 'defensive3'
	ElseIf $ColorDistSupport1 == $currentLowestColorDifference Then
		$socketDetected = 'support1'
	ElseIf $ColorDistSupport2 == $currentLowestColorDifference Then
		$socketDetected = 'support2'
	ElseIf $ColorDistSupport3 == $currentLowestColorDifference Then
		$socketDetected = 'support3'
	EndIf
	
	
	;debug output
	;_GUICtrlRichEdit_AppendTextEx($socketLog2, "SocketNumberToCheck: " & $socketNumberToCheck & " | SocketDetected: " & $socketDetected & " | smallestColorDifferenceValueFound: " & $smallestColorDifferenceValueFound & @CRLF, "MS Sans Serif", "FFFFFF", 8, 0, 0, 0, 0)
	
	Return $socketDetected
	
EndFunc