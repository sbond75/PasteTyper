; https://www.autohotkey.com/boards/viewtopic.php?t=19736
Concatenate2(x, y) {
    Return, x y
}

+!p:: ; Shift-Alt-p

; Set the target window title for Minecraft
;SetTitleMatchMode, 2
;WinActivate, "Tekkit Classic"

; exit existing editor
sleepTime := 200
;sleep 800 ; enough time to release the keys..
Send, {Space up}
sleep 90
;Send, {Space up}
;Send, {Ctrl up}
;Send, {Alt up}
Send, {Ctrl down}
Sleep %sleepTime%
Send, {Ctrl up}
Send, {Right down}
Sleep %sleepTime%
Send, {Right up}
Send, {Enter down}
Sleep, %sleepTime%
Send, {Enter, up}

clipboard_ := Concatenate2("rm mine.lua`nedit mine.lua`n", Clipboard)
Send, {Enter} ; THE FIX for issues is this line
Send, {Ctrl up}

;SetKeyDelay 100
;SetKeyDelay 5

;firstChar := SubStr(clipboard, 1, 1)
;Send {RAW}%firstChar%

Loop, parse, clipboard_, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
{
	;MsgBox, 4, , Line number %A_Index% is %A_LoopField%.`n`nContinue?
	;IfMsgBox, No, break

	Send {RAW}%A_LoopField%
        Send {Enter}
        Sleep 15

        KeyIsDown := GetKeyState(Esc)
        If KeyIsDown
            break
        
}