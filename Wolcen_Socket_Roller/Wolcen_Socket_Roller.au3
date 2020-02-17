

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


GUISetState(@SW_SHOW,  $MainWindow)


_GUICtrlComboBox_SetCurSel($sock1, 0)
_GUICtrlComboBox_SetCurSel($sock2, 0)
_GUICtrlComboBox_SetCurSel($sock3, 0)

$startButtonHdn2 = GUICtrlCreateButton("Start",15,271,231,30,-1,-1)

;https://uploads-ssl.webflow.com/5c14e387dab576fe667689cf/5cbed8a4ae2b88347c06c923_BuyMeACoffee_blue-p-500.png
;$coffee = GUICtrlCreatePic(@scriptdir&"\"&"Images\BuyMeACoffee_blue@2x.jpg",15,312,231,35,-1,-1)
$sFile = _GetURLImage("http://download1.ts3musicbot.net/BuyMeACoffee_blue.jpg", @TempDir)
$coffee = GUICtrlCreatePic($sFile,15,312,231,35,-1,-1)

While 1
	Switch GUIGetMsg()
		
		Case $GUI_EVENT_CLOSE,  $idOK
			ExitLoop 
		Case $coffee
			$sUrl='https://ko-fi.com/crypto90'
			ShellExecute($sUrl)
		Case $startButtonHdn2
			runMain()
	EndSwitch
Wend

; coordinates on 3440 x 1440 resolution

; 1. socket text box. x: 123 y: 677 - x: 268 y: 723
; 2. socket text box x: 123 y: 742 - x: 268 y: 788
; 3. socket text box x: 123 y: 804 - x: 268 y: 854

;Socket 1 area coordinates
Local $socket1TopLeftX = 123
Local $socket1TopLeftY = 677
Local $socket1BottomRightX = 268
Local $socket1BottomRightY = 723

;Socket 2 area coordinates
Local $socket2TopLeftX = 123
Local $socket2TopLeftY = 742
Local $socket2BottomRightX = 268
Local $socket2BottomRightY = 788

;Socket 3 area coordinates
Local $socket3TopLeftX = 123
Local $socket3TopLeftY = 804
Local $socket3BottomRightX = 268
Local $socket3BottomRightY = 854

;reroll button cooridnates
Local $rerollClickX = 390
Local $rerollClickY = 1222



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

	Local $wantedSocket1 = $sock1
	Local $wantedSocket2 = $sock2
	Local $wantedSocket3 = $sock3



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



	




	








	;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: " & getSocket(1))
	;MsgBox($MB_SYSTEMMODAL, "", "Socket 2: " & getSocket(2))
	;MsgBox($MB_SYSTEMMODAL, "", "Socket 3: " & getSocket(3))

	$finished = False
	While $finished == False

	   $sString = "Socket 1: " & getSocket(1) & " -- Socket 2: " & getSocket(2) & " -- Socket 3: " & getSocket(3)
	   ConsoleWrite($sString & @CRLF)

	   IF getSocket(1) <> $wantedSocket1 Or getSocket(2) <> $wantedSocket2 Or getSocket(3) <> $wantedSocket3 Then
		  MouseClick($MOUSE_CLICK_LEFT, $rerollClickX, $rerollClickY, 1)
		  Sleep(300)

		  If WinGetTitle("[ACTIVE]") <> "Wolcen: Lords of Mayhem" Then
			 Exit
		  EndIf

	   Else
		  $finished = True
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
	
	
	;update all coordinates based on current game resolution - does not work currently
	$size = WinGetPos("[active]")
	$gameWidth = $size[2]
	$gameHeight = $size[3]


	;Socket 1 area coordinates
	$socket1TopLeftX = Round( (123 / 3440) * $gameWidth )
	$socket1TopLeftY =  Round( (677 / 1440) * $gameHeight )
	$socket1BottomRightX = Round( (268 / 3440) * $gameWidth )
	$socket1BottomRightY = Round( (723 / 1440) * $gameHeight )

	;Socket 2 area coordinates
	$socket2TopLeftX = Round( (123 / 3440) * $gameWidth )
	$socket2TopLeftY = Round( (742 / 1440) * $gameHeight )
	$socket2BottomRightX = Round( (268 / 3440) * $gameWidth )
	$socket2BottomRightY = Round( (788 / 1440) * $gameHeight )

	;Socket 3 area coordinates
	$socket3TopLeftX = Round( (123 / 3440) * $gameWidth )
	$socket3TopLeftY = Round( (804 / 1440) * $gameHeight )
	$socket3BottomRightX = Round( (268 / 3440) * $gameWidth )
	$socket3BottomRightY = Round( (854 / 1440) * $gameHeight )

	;reroll button cooridnates
	$rerollClickX = Round( (390 / 3440) * $gameWidth )
	$rerollClickY = Round( (1222 / 1440) * $gameHeight )
	
	
	
   $socketTopLeftXSearch = 0
   $socketTopLeftYSearch = 0
   $socketBottomRightXSearch = 0
   $socketBottomRightYSearch = 0

   If $socketNumberToCheck == 1 Then
	  $socketTopLeftXSearch = $socket1TopLeftX
	  $socketTopLeftYSearch = $socket1TopLeftY
	  $socketBottomRightXSearch = $socket1BottomRightX
	  $socketBottomRightYSearch = $socket1BottomRightY
   ElseIf $socketNumberToCheck == 2 Then
	  $socketTopLeftXSearch = $socket2TopLeftX
	  $socketTopLeftYSearch = $socket2TopLeftY
	  $socketBottomRightXSearch = $socket2BottomRightX
	  $socketBottomRightYSearch = $socket2BottomRightY
   ElseIf $socketNumberToCheck == 3 Then
	  $socketTopLeftXSearch = $socket3TopLeftX
	  $socketTopLeftYSearch = $socket3TopLeftY
	  $socketBottomRightXSearch = $socket3BottomRightX
	  $socketBottomRightYSearch = $socket3BottomRightY
   EndIf


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
	   ;MsgBox($MB_SYSTEMMODAL, "", "Socket 1: Support 2")
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