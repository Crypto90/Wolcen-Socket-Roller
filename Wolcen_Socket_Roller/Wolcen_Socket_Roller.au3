	

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


;EMBED IMAGES INTO EXE
;start button image
If Not FileExists(@TempDir & '\Wolcen_Socket_Roller') Then DirCreate(@TempDir & '\Wolcen_Socket_Roller')
FileInstall('Images\button_start.jpg', @TempDir & '\Wolcen_Socket_Roller\button_start.jpg', 1)
GUICtrlSetImage($startButtonHdn2, @TempDir & '\Wolcen_Socket_Roller\button_start.jpg')

;donate button image
If Not FileExists(@TempDir & '\Wolcen_Socket_Roller') Then DirCreate(@TempDir & '\Wolcen_Socket_Roller')
FileInstall('Images\button_donate.jpg', @TempDir & '\Wolcen_Socket_Roller\button_donate.jpg', 1)
GUICtrlSetImage($coffee, @TempDir & '\Wolcen_Socket_Roller\button_donate.jpg')

;background image
FileInstall('Images\background.jpg', @TempDir & '\Wolcen_Socket_Roller\background.jpg', 1)
$MainWindow_BGimage = GUICtrlCreatePic(@TempDir & '\Wolcen_Socket_Roller\background.jpg',0,0,735,356,$WS_CLIPSIBLINGS)




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
		Case $coffee
			$sUrl='https://ko-fi.com/crypto90'
			ShellExecute($sUrl)
		Case $startButtonHdn2
			$finished = False
			GUICtrlSetData($socketLog, '')
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
    $hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
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
	
	winWaitActive("Wolcen")
	$size = WinGetPos("[active]")
	$gameWidth = $size[2]
	$gameHeight = $size[3]
	;MsgBox(0, "Active window stats (x,y,width,height):", $size[0] & " " & $size[1] & " " & $size[2] & " " & $size[3])

	;reroll button cooridnates
	$rerollClickX = Round( (390 / 3440) * $gameWidth )
	$rerollClickY = Round( (1222 / 1440) * $gameHeight )



	
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
	While $finished == False
	   
		$gotSocket1 =  getSocket(1)
		$gotSocket2 =  'unset'
		$gotSocket3 =  'unset'
		
		If WinGetTitle("[ACTIVE]") <> "Wolcen: Lords of Mayhem" Then
			$finished =  True
			GUICtrlSetData($socketLog, "Aborted!" & @CRLF, 1)
		EndIf
		
		;prevent unneeded area checks start
		;if found socket is not in wanted, reroll directly
		If $gotSocket1 <> $wantedSocket1 And $gotSocket1 <> $wantedSocket2 And $gotSocket1 <> $wantedSocket3 Then
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
		    $sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
		    ;append to log edit box
		    GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			
			$previousSocket1 =  $gotSocket1
			$previousSocket2 =  $gotSocket2
			$previousSocket3 =  $gotSocket3
			
			$rollCounter =  $rollCounter +  1
			MouseClick($MOUSE_CLICK_LEFT, $rerollClickX, $rerollClickY, 1)
			Sleep(100)
			ContinueLoop
		EndIf
		
		;prevent unneeded area checks
		If $gotSocket1 <> 'unset' Then 
			$gotSocket2 =  getSocket(2)
			
			;if found socket is not in wanted, reroll directly
			If $gotSocket2 <> $wantedSocket1 And $gotSocket2 <> $wantedSocket2 And $gotSocket2 <> $wantedSocket3 Then
				$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
				$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;append to log edit box
				GUICtrlSetData($socketLog, $sString & @CRLF, 1)
				
				$previousSocket1 =  $gotSocket1
				$previousSocket2 =  $gotSocket2
				$previousSocket3 =  $gotSocket3
				
				$rollCounter =  $rollCounter +  1
				MouseClick($MOUSE_CLICK_LEFT, $rerollClickX, $rerollClickY, 1)
				Sleep(100)
				ContinueLoop
			EndIf
			
		EndIf
		If $gotSocket2 <> 'unset' Then 
			$gotSocket3 =  getSocket(3)
			
			;if found socket is not in wanted, reroll directly
			If $gotSocket3 <> $wantedSocket1 And $gotSocket3 <> $wantedSocket2 And $gotSocket3 <> $wantedSocket3 Then
				$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
				$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
				;append to log edit box
				GUICtrlSetData($socketLog, $sString & @CRLF, 1)
				
				$previousSocket1 =  $gotSocket1
				$previousSocket2 =  $gotSocket2
				$previousSocket3 =  $gotSocket3
				
				$rollCounter =  $rollCounter +  1
				MouseClick($MOUSE_CLICK_LEFT, $rerollClickX, $rerollClickY, 1)
				Sleep(100)
				ContinueLoop
			EndIf
			
		EndIf
		;prevent unneeded area checks finished
		
		
		
	   	If ($gotSocket1 == $wantedSocket1 And $gotSocket2 == $wantedSocket2 And $gotSocket3 == $wantedSocket3) Or ($gotSocket1 == $wantedSocket1 And $gotSocket2 == $wantedSocket3 And $gotSocket3 == $wantedSocket2) Or ($gotSocket1 == $wantedSocket2 And $gotSocket2 == $wantedSocket1 And $gotSocket3 == $wantedSocket3) Or ($gotSocket1 == $wantedSocket2 And $gotSocket2 == $wantedSocket3 And $gotSocket3 == $wantedSocket1) Or ($gotSocket1 == $wantedSocket3 And $gotSocket2 == $wantedSocket1 And $gotSocket3 == $wantedSocket2) Or ($gotSocket1 == $wantedSocket3 And $gotSocket2 == $wantedSocket2 And $gotSocket3 == $wantedSocket1) Then
			;found a searched combination
			$finished = True
			Beep(500, 2000)
			$timestamp = @HOUR & ":" & @MIN & ":" & @SEC
			$sString = $timestamp & " | " & $rollCounter & " | Socket 1: " & $gotSocket1 & " -- Socket 2: " & $gotSocket2 & " -- Socket 3: " & $gotSocket3
			GUICtrlSetData($socketLog, $sString & @CRLF, 1)
			GUICtrlSetData($socketLog, "------------------------------------------------------------------------------------------------------------------" & @CRLF & @CRLF, 1)
			
			GUICtrlSetData($socketLog, "Finished after " & $rollCounter & " rolls!" & @CRLF, 1)
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
			MouseClick($MOUSE_CLICK_LEFT, $rerollClickX, $rerollClickY, 1)
			Sleep(100)
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
			$finished =  True
			GUICtrlSetData($socketLog, "Aborted!" & @CRLF, 1)
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
	 $size = WinGetPos("[active]")
	 $gameWidth = $size[2]
	 $gameHeight = $size[3]


	
	
   $socketTopLeftXSearch = 0
   $socketTopLeftYSearch = 0
   $socketBottomRightXSearch = 0
   $socketBottomRightYSearch = 0

   If $socketNumberToCheck == 1 Then
		;Socket 1 area coordinates
		$socket1TopLeftX = Round( (210 / 3440) * $gameWidth )
		$socket1TopLeftY =  Round( (677 / 1440) * $gameHeight )
		$socket1BottomRightX = Round( (268 / 3440) * $gameWidth )
		$socket1BottomRightY = Round( (723 / 1440) * $gameHeight )
		;draw rect
		_UIA_DrawRect($socket1TopLeftX, $socket1BottomRightX, $socket1TopLeftY, $socket1BottomRightY, 0x0000FF, 2)
	  
	  $socketTopLeftXSearch = $socket1TopLeftX
	  $socketTopLeftYSearch = $socket1TopLeftY
	  $socketBottomRightXSearch = $socket1BottomRightX
	  $socketBottomRightYSearch = $socket1BottomRightY
   ElseIf $socketNumberToCheck == 2 Then
		;Socket 2 area coordinates
		$socket2TopLeftX = Round( (210 / 3440) * $gameWidth )
		$socket2TopLeftY = Round( (742 / 1440) * $gameHeight )
		$socket2BottomRightX = Round( (268 / 3440) * $gameWidth )
		$socket2BottomRightY = Round( (788 / 1440) * $gameHeight )
		;draw rect
		_UIA_DrawRect($socket2TopLeftX, $socket2BottomRightX, $socket2TopLeftY, $socket2BottomRightY, 0x0000FF, 2)

	  
	  $socketTopLeftXSearch = $socket2TopLeftX
	  $socketTopLeftYSearch = $socket2TopLeftY
	  $socketBottomRightXSearch = $socket2BottomRightX
	  $socketBottomRightYSearch = $socket2BottomRightY
   ElseIf $socketNumberToCheck == 3 Then
		;Socket 3 area coordinates
		$socket3TopLeftX = Round( (210 / 3440) * $gameWidth )
		$socket3TopLeftY = Round( (804 / 1440) * $gameHeight )
		$socket3BottomRightX = Round( (268 / 3440) * $gameWidth )
		$socket3BottomRightY = Round( (854 / 1440) * $gameHeight )
		;draw rect
		_UIA_DrawRect($socket3TopLeftX, $socket3BottomRightX, $socket3TopLeftY, $socket3BottomRightY, 0x0000FF, 2)

	  
	  $socketTopLeftXSearch = $socket3TopLeftX
	  $socketTopLeftYSearch = $socket3TopLeftY
	  $socketBottomRightXSearch = $socket3BottomRightX
	  $socketBottomRightYSearch = $socket3BottomRightY
   EndIf

	;reroll button cooridnates
	 $rerollClickX = Round( (410 / 3440) * $gameWidth )		
	 $rerollClickY = Round( (1222 / 1440) * $gameHeight )


   ;offensive socket checks
   $checkSocket1Offensive1 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0xc43b62, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Offensive 1")
	   Return 'offensive1'
   EndIf
   $checkSocket1Offensive2 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0xe35c5c, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Offensive 2")
	   Return 'offensive2'
	EndIf
	$checkSocket1Offensive3 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0xd38871, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Offensive 3")
	   Return 'offensive3'
   EndIf


   ; defensive socket check
   $checkSocket1Defensive1 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0x3fae60, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Defensive 1")
	   Return 'defensive1'
   EndIf
   $checkSocket1Defensive2 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0x7dd389, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Defensive 2")
	   Return 'defensive2'
   EndIf
	$checkSocket1Defensive3 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0x90ac69, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Defensive 3")
	   Return 'defensive3'
   EndIf


   ; support socket check
   $checkSocket1Support1 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0x3d6ada, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 1")
	   Return 'support1'
   EndIf
   $checkSocket1Support2 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0x229abf, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 2")0xF2EEDC0xF2EEDC0xF2EEDC
	   Return 'support2'
   EndIf
	$checkSocket1Support3 = PixelSearch($socketTopLeftXSearch, $socketTopLeftYSearch, $socketBottomRightXSearch, $socketBottomRightYSearch, 0x9cdcf6, 5)
   If Not @error Then
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 3")
	   Return 'support3'
	EndIf

	;if no socket found
	Return 'unset'
EndFunc