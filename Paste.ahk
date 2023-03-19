Thread, interrupt, 50, 2000 ; attempt to do https://www.autohotkey.com/board/topic/48908-how-do-i-stop-a-runaway-script-panic-button/

; https://www.autohotkey.com/docs/v1/lib/SetWorkingDir.htm
SetWorkingDir %A_ScriptDir%

; https://www.autohotkey.com/boards/viewtopic.php?t=19736
Concatenate2(x, y) {
    Return, x y
}

; https://www.autohotkey.com/docs/v1/lib/Run.htm
RunWaitOne(command, input1, input2, byref stderrOutput) {
    marker := "special ending marker 1111111111112310239120391203901239029132323"

    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(input1)
    exec.StdIn.WriteLine(marker)
    exec.StdIn.WriteLine(input2)
    exec.StdIn.Close()
    ; Read and return the command's output
    stderrOutput := exec.StdErr.ReadAll()
    return exec.StdOut.ReadAll()
}


+!o:: ; Shift-Alt-o : mark original as already pasted
clipboard_ := Clipboard
return


+!p:: ; Shift-Alt-p : paste deltas
clipboard_new := Clipboard

; Find differences in clipboard using Python
; https://www.autohotkey.com/boards/viewtopic.php?style=19&f=76&t=98016 , https://www.autohotkey.com/docs/v1/lib/Run.htm
;dir    := A_ScriptDir
;script  = %dir%\diffs.py
script  = diffs.py
; Run, %ComSpec% /k python "%script%" "%clipboard_%" "%clipboard_new%"
;MsgBox % clipboard_
;MsgBox % clipboard_new
stderrOutput := "<None>"
keys := RunWaitOne(Concatenate2("python ", script), clipboard_, clipboard_new, stderrOutput)
;MsgBox % keys
if (stderrOutput != "") {
	MsgBox % Concatenate2("Errors:`n", stderrOutput)
}
SetKeyDelay 100
Send %keys%

clipboard_ := clipboard_new
return


+!l:: ; Shift-Alt-l : paste basic

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

clipboard_2 := Concatenate2("rm mine.lua`nedit mine.lua`n", Clipboard)
clipboard_ := clipboard_2
Send, {Enter} ; THE FIX for issues is this line
Send, {Ctrl up}

;SetKeyDelay 100
;SetKeyDelay 5

;firstChar := SubStr(clipboard, 1, 1)
;Send {RAW}%firstChar%

Loop, parse, clipboard_2, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
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

return

; Emergency exit: Ctrl-Esc
; TODO: doesn't always work.. if SendKeys is in progress, it doesn't work
^Esc::
ExitApp
Return