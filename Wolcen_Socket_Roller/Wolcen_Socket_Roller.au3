	

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

;mouse position relative to window and not 
AutoItSetOption("MouseCoordMode",0)


;EMBED IMAGES INTO EXE
;start button image
GUICtrlSetImage($startButtonHdn2, @TempDir & '\Wolcen_Socket_Roller\button_start.jpg')

;donate button image
GUICtrlSetImage($coffee, @TempDir & '\Wolcen_Socket_Roller\button_donate.jpg')

;background image
$MainWindow_BGimage = GUICtrlCreatePic(@TempDir & '\Wolcen_Socket_Roller\background_v2.jpg',0,0,735,430,$WS_CLIPSIBLINGS)




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


$finished = False

;sleep interval in milliseconds how long to wait after reroll got clicked
$sleepAfterClickRollValue =  200

;game position to support window mode and relative coordinates based on window position
$gameX =  0
$gameY =  0

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
$shadesTolerance =  6

GUISetState(@SW_SHOW,  $MainWindow)


_GUICtrlComboBox_SetCurSel($sock1, 0)
_GUICtrlComboBox_SetCurSel($sock2, 0)
_GUICtrlComboBox_SetCurSel($sock3, 0)

;$socketLogOld = GUICtrlCreateEdit("",293,42,433,306,BitOR($WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY),-1)
;increase limit of textbox


;$startButtonHdn2 = GUICtrlCreateButton("Start",15,271,231,30,-1,-1)



;set hotkeys if pressed we stop the loop if running
HotKeySet("{ESC}", "stopLoop")
HotKeySet("{TAB}", "stopLoop")
HotKeySet("{ALT}", "stopLoop")




Func stopLoop()
    $finished =  True
	GUICtrlSetData($socketLog, "Aborted!" & @CRLF, 1)
EndFunc   ;==>stops the loop if running


;$sFile = _GetURLImage("http://download1.ts3musicbot.net/BuyMeACoffee_blue.jpg", @TempDir)
;$coffee = GUICtrlCreatePic($sFile,15,312,231,35,-1,-1)

While 1
	Switch GUIGetMsg()
		
		Case $GUI_EVENT_CLOSE,  $idOK
			ExitLoop
		Case $sleepAfterClickRoll
			$sleepAfterClickRollValue = Int(GUICtrlRead($sleepAfterClickRoll0xF2EEDC))
		Case $coffee
			$sUrl='https://ko-fi.com/crypto90'
			ShellExecute($sUrl)
		Case $startButtonHdn2
			$finished = False
			GUICtrlSetData($socketLog, '')
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
	
	
    ;$hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
	
	$hDC = _WinAPI_GetWindowDC(WinGetHandle ( "Wolcen: Lords of Mayhem" ))
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















	WinActivate ( "Wolcen: Lords of Mayhem" )



	;winWaitActive("Wolcen: Lords of Mayhem")
	
	winWaitActive("Wolcen: Lords of Mayhem")
	$size = WinGetPos("Wolcen: Lords of Mayhem")
	$gameWidth = $size[2]
	$gameHeight = $size[3]
	;MsgBox(0, "Active window stats (x,y,width,height):", $size[0] & " " & $size[1] & " " & $size[2] & " " & $size[3])
	$gameAspectRatio = $gameWidth /  $gameHeight
	$gameX =  $size[0]
	$gameY =  $size[1]
	
	
	;support for multiple different aspect ratios
	
	
	
	
	;21 : 9 ultrawide
	If $gameAspectRatio ==  (3440 / 1440) Then 
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 ultrawide" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 21:9 wide" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:10 / 8:5" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:9" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 5:3" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 5:4" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 4:3" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio: 16:9" & @CRLF, 1)
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
		GUICtrlSetData($socketLog, "Game resolution: " & $gameWidth & "x" & $gameHeight & " Aspect ratio could not get autodetected, fallback to default: 16:9" & @CRLF, 1)
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
	
	
	$checkActiveWindowTitle = WinGetTitle("[ACTIVE]")
	If $checkActiveWindowTitle <> "Wolcen: Lords of Mayhem" Then
		GUICtrlSetData($socketLog, "Wolcen: Lords of Mayhem is not running... Aborting." & @CRLF, 1)
		stopLoop()
		Return
	EndIf


	








	;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: " & getSocket(1))
	;MsgBox($MB_SYSTEMMODAL, "", "Socket 2: " & getSocket(2))
	;MsgBox($MB_SYSTEMMODAL, "", "Socket 3: " & getSocket(3))
	GUICtrlSetData($socketLog, "------------------------------------------------------------------------------------------------------------------" & @CRLF, 1)
	GUICtrlSetData($socketLog, "Started..." & @CRLF, 1)
	$sString = "Searching for:  " & $wantedSocket1 & "  --  " & $wantedSocket2 & "  --  " & $wantedSocket3
	;append to log edit box
	GUICtrlSetData($socketLog, $sString & @CRLF, 1)
	GUICtrlSetData($socketLog, "------------------------------------------------------------------------------------------------------------------" & @CRLF & @CRLF, 1)
	
	
	
	$previousSocket1 =  ''
	$previousSocket2 =  ''
	$previousSocket3 =  ''
	
	$unchangedSocketsCounter =  0
	$rollCounter =  0
	$maxRollsValue =  Int(GUICtrlRead($maxRolls))
	While $finished == False
		
		If WinGetTitle("[ACTIVE]") <> "Wolcen: Lords of Mayhem" Then
			stopLoop()
			ExitLoop
		EndIf
		
		
	    If  $maxRollsValue > 0 And $rollCounter >= $maxRollsValue Then 
			$finished =  True
			GUICtrlSetData($socketLog, "Max rolls of " & $maxRollsValue & " reached. Aborting." & @CRLF, 1)
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
		    $sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;append to log edit box
		    GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			
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
				$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;append to log edit box
				GUICtrlSetData($socketLog, $sString & @CRLF, 1)
				
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
				$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;append to log edit box
				GUICtrlSetData($socketLog, $sString & @CRLF, 1)
				
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
			Beep(500, 2000)
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
			$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
			GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			GUICtrlSetData($socketLog, "------------------------------------------------------------------------------------------------------------------" & @CRLF & @CRLF, 1)
			GUICtrlSetData($socketLog, "Finished after " & $rollCounter & " rolls!" & @CRLF, 1)
			ExitLoop
		Else 
			;no wanted combination found, reroll
			;speed up checks, do no sleep if one of the sockets changed from previous roll
		  If $previousSocket1 <> $gotSocket1 Or $previousSocket2 <> $gotSocket2 Or $previousSocket3 <> $gotSocket3 Then
			;sockets changed for sure, so we can reroll instantly, update previous socket variables
			
			
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
		    $sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;append to log edit box
		    GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			
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
			GUICtrlSetData($socketLog, "Socket check unchanged..." & @CRLF, 1)
			$unchangedSocketsCounter =  $unchangedSocketsCounter +  1
			; 3 times unchanged, which means in 500ms nothing changed, we force reroll
			If $unchangedSocketsCounter >= 5 Then 
				$previousSocket1 =  ''
				$previousSocket2 =  ''
				$previousSocket3 =  ''
				$unchangedSocketsCounter =  0
			EndIf
			
		  EndIf
		  
		  
		  

		  If WinGetTitle("[ACTIVE]") <> "Wolcen: Lords of Mayhem" Then
			$finished =  True
			GUICtrlSetData($socketLog, "Aborted!" & @CRLF, 1)
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
	
   ;recalculate coordinates based on current resolution
	$size = WinGetPos("Wolcen: Lords of Mayhem")
	$gameWidth = $size[2]
	$gameHeight = $size[3]
	$gameX =  $size[0]
	$gameY =  $size[1]

	
   $socketTopLeftXSearch = 0
   $socketTopLeftYSearch = 0
   $socketBottomRightXSearch = 0
   $socketBottomRightYSearch = 0

   If $socketNumberToCheck == 1 Then
		;Socket 1 area coordinates
		$socket1TopLeftX = Round( ($baseSocket1TopLeftX / $baseResolutionWidth) * $gameWidth )
		$socket1TopLeftY =  Round( ($baseSocket1TopLeftY / $baseResolutionHeight) * $gameHeight )
		$socket1BottomRightX = Round( ($baseSocket1BottomRightX / $baseResolutionWidth) * $gameWidth )
		$socket1BottomRightY = Round( ($baseSocket1BottomRightY / $baseResolutionHeight) * $gameHeight )
		
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


   ;offensive socket checks
   $checkSocket1Offensive1 = PixelSearch($gameX +  $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0xc43b62, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Offensive 1")
	   Return 'offensive1'
   EndIf
   $checkSocket1Offensive2 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0xe35c5c, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Offensive 2")
	   Return 'offensive2'
	EndIf
	$checkSocket1Offensive3 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0xd38871, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Offensive 3")
	   Return 'offensive3'
   EndIf


   ; defensive socket check
   $checkSocket1Defensive1 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0x3fae60, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Defensive 1")
	   Return 'defensive1'
   EndIf
   $checkSocket1Defensive2 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0x7dd389, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Defensive 2")
	   Return 'defensive2'
   EndIf
	$checkSocket1Defensive3 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0x90ac69, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Defensive 3")
	   Return 'defensive3'
   EndIf


   ; support socket check
   $checkSocket1Support1 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0x3d6ada, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 1")
	   Return 'support1'
   EndIf
   $checkSocket1Support2 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0x229abf, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 2")0xF2EEDC0xF2EEDC0xF2EEDC
	   Return 'support2'
   EndIf
	$checkSocket1Support3 = PixelSearch($gameX + $socketTopLeftXSearch, $gameY + $socketTopLeftYSearch, $gameX + $socketBottomRightXSearch, $gameY + $socketBottomRightYSearch, 0x9cdcf6, $shadesTolerance)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 3")
	   Return 'support3'
	EndIf

	;if no socket found
	Return 'unset'
EndFunc