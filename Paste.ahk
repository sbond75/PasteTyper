;; Config ;;

;; Nvm:
;stripTabs := true ; Removes tabs if set to `true`. Use `false` to make it not remove tabs.
;stripLeadingWhitespace := true ; Removes leading whitespace such as spaces for indentation
;; ;;

Thread, interrupt, 50, 2000 ; attempt to do https://www.autohotkey.com/board/topic/48908-how-do-i-stop-a-runaway-script-panic-button/

; https://www.autohotkey.com/docs/v1/lib/SetWorkingDir.htm
SetWorkingDir %A_ScriptDir%

; https://www.autohotkey.com/boards/viewtopic.php?t=791
; ----------------------------------------------------------------------------------------------------------------------
; Function .....: StdoutToVar_CreateProcess
; Description ..: Runs a command line program and returns its output.
; Parameters ...: sCmd      - Commandline to execute.
; ..............: sEncoding - Encoding used by the target process. Look at StrGet() for possible values.
; ..............: sDir      - Working directory.
; ..............: nExitCode - Process exit code, receive it as a byref parameter.
; Return .......: Command output as a string on success, empty string on error.
; AHK Version ..: AHK_L x32/64 Unicode/ANSI
; Author .......: Sean (http://goo.gl/o3VCO8), modified by nfl and by Cyruz
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Feb. 20, 2007 - Sean version.
; ..............: Sep. 21, 2011 - nfl version.
; ..............: Nov. 27, 2013 - Cyruz version (code refactored and exit code).
; ..............: Mar. 09, 2014 - Removed input, doesn't seem reliable. Some code improvements.
; ..............: Mar. 16, 2014 - Added encoding parameter as pointed out by lexikos.
; ..............: Jun. 02, 2014 - Corrected exit code error.
; ..............: Nov. 02, 2016 - Fixed blocking behavior due to ReadFile thanks to PeekNamedPipe.
; ----------------------------------------------------------------------------------------------------------------------
StdoutToVar_CreateProcess(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0) {
    DllCall( "CreatePipe",           PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1                 )

            VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24,  0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz,      si,  0,                          "UInt" )
    NumPut( 0x100,     si,  (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 60 : 88, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 64 : 96, "Ptr"  )

    If ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
                                  , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
        Return ""
      , DllCall( "CloseHandle", Ptr,hStdOutWr )
      , DllCall( "CloseHandle", Ptr,hStdOutRd )

    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before reading the stdout.
    While ( 1 )
    { ; Before reading, we check if the pipe has been written to, so we avoid freezings.
        If ( !DllCall( "PeekNamedPipe", Ptr,hStdOutRd, Ptr,0, UInt,0, Ptr,0, UIntP,nTot, Ptr,0 ) )
            Break
        If ( !nTot )
        { ; If the pipe buffer is empty, sleep and continue checking.
            Sleep, 100
            Continue
        } ; Pipe buffer is not empty, so we can read it.
        VarSetCapacity(sTemp, nTot+1)
        DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,nTot, PtrP,nSize, Ptr,0 )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)
    }
    
    ; * SKAN has managed the exit code through SetLastError.
    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,0)                  )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,A_PtrSize)          )
    DllCall( "CloseHandle",        Ptr,hStdOutRd                     )
    Return sOutput
}


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
RunWaitOne2(command, byref stderrOutput) {
    marker := "special ending marker 1111111111112310239120391203901239029132323"

    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    ;;exec := shell.Exec(ComSpec " /C " command " lastPasteTyped.txt newClipboard.txt 1")
    ;;exec.StdIn.Close()
    ; Read and return the command's output
    ;stderrOutput := exec.StdErr.ReadAll()
    ;;return exec.StdOut.ReadAll()
    return StdoutToVar_CreateProcess(command " lastPasteTyped.txt newClipboard.txt 1", "UTF-8")
}


ProcessText(retval) {
        ; Global stripTabs
	; Global stripLeadingWhitespace

        ; if (stripTabs = true) {
	;   StringCaseSense, On
        ;   retval := StrReplace(retval, A_Tab) ; replace tabs with the empty string
        ; }
	; if (stripLeadingWhitespace = true) {
	; 	; ``am)` are some options from https://www.autohotkey.com/docs/v1/misc/RegEx-QuickRef.htm#Options and https://www.autohotkey.com/board/topic/17237-regex-doesnt-match-at-the-beginning-of-all-new-lines/ where `a means to recognize more types of newlines which is required to match a multiline string like above. m option makes it multiline (can match across multiple lines).
	; 	retval := regexreplace(retval, "`am)^\s+") ;trim beginning whitespace   ; https://www.autohotkey.com/board/topic/57765-trim-leading-and-trailing-white-space-from-the-clipboard/
	; }
	return retval
}

ReadClipboard() {
        retval := Clipboard
	retval := ProcessText(retval)
	return retval
}

; Saves the `clipboard_` variable to a file
SaveClipboard_(clipboard_) {
       ; https://stackoverflow.com/questions/67121794/autohotkey-writing-special-characters-to-a-file , https://www.autohotkey.com/docs/v1/lib/FileOpen.htm
	txtfile := FileOpen("lastPasteTyped.txt", "w", UTF-8)
        txtfile.write(clipboard_)
        txtfile.close()
}
; Loads the `clipboard_` variable from a file
LoadClipboard_() {
        ; https://www.autohotkey.com/docs/v1/lib/FileRead.htm
	FileRead, clipboard_, lastPasteTyped.txt
        ; if not ErrorLevel  ; Successfully loaded.
	; {
        ;   msgbox, Loaded last typed text from lastPasteTyped.txt
        ; }
	clipboard_ := ProcessText(clipboard_)
	return clipboard_
}
clipboard_ := LoadClipboard_()


+!o:: ; Shift-Alt-o : mark original as already pasted
clipboard_ := ReadClipboard()
SaveClipboard_(clipboard_)
return


+!i:: ; Shift-Alt-i : clear last saved clipboard contents
; https://www.autohotkey.com/board/topic/18650-how-to-create-a-yes-no-message-box-with-a-goto-a-label/
  MSGBox, 4, , Clear last saved clipboard contents?
  IfMsgBox, No 
    return
  Else {
    clipboard_ := ""
    SaveClipboard_(clipgoard_)
  }
  return

+!p:: ; Shift-Alt-p : paste deltas
; computercraft fixes ;
;; works in Paste.ahk but not in the generated exe from ahk2exe... : ;;
; Send, {Space up}
; Send, {Ctrl up}
;; ;;

;; `{Blind}`: weird thing, not sure what it does, but it seems to fix it on the ahk2exe version ( https://www.autohotkey.com/docs/v1/lib/Send.htm#Blind )
Send, {Blind}{Space up}
Send, {Blind}{Ctrl up}
; ;

clipboard_new := ReadClipboard()

txtfile2 := FileOpen("newClipboard.txt", "w", UTF-8)
txtfile2.write(clipboard_new)
txtfile2.close()

; Find differences in clipboard using Python
; https://www.autohotkey.com/boards/viewtopic.php?style=19&f=76&t=98016 , https://www.autohotkey.com/docs/v1/lib/Run.htm
;dir    := A_ScriptDir
;script  = %dir%\diffs.py
script  = diffs.py

; Check if A_ScriptName ends with `.ahk` which would indicate this is not running in a compiled exe made with ahk2exe
isInAHK2Exe := true ; Assume true
regex := ".*\.ahk$"
FoundPos := RegExMatch(A_ScriptName, "O)"regex, matchObj)
If (ErrorLevel != 0) {
	MsgBox % "Regex error in regex" regex
} Else If (FoundPos != 0) {
	; Found
	If (matchObj.Pos == 1 and matchObj.Len == StrLen(Title)) {
		; It is an entire match
		isInAHK2Exe := false
	}
}

if (isInAHK2Exe = true) {
	pythonCmd := Concatenate2(".venv\Scripts\activate.bat && python ", script)
} else {
	pythonCmd := "diffs/diffs.exe"
}
; Run, %ComSpec% /k python "%script%" "%clipboard_%" "%clipboard_new%"
;MsgBox % clipboard_
;MsgBox % clipboard_new
stderrOutput := "<None>"
;keys := RunWaitOne(Concatenate2("python ", script), clipboard_, clipboard_new, stderrOutput)
keys := RunWaitOne2(pythonCmd, stderrOutput)
;MsgBox % keys
if (stderrOutput != "") {
	;MsgBox % "Prev clipboard: " clipboard_ "`n" Concatenate2("Errors:`n", stderrOutput)
	MsgBox % Concatenate2("Errors:`n", stderrOutput)
	Sleep 500
}
;SetKeyDelay 100
;SetKeyDelay 15
SetKeyDelay 30
Send %keys%
Send {Backspace}{Backspace} ; Hack to delete extra two newlines added for some weird unknown reason by AHK

  MSGBox, 4, , Was it successful?`n("No" will keep using old diff)
  IfMsgBox, No
    return ; don't save paste contents
  Else {
  }

clipboard_ := clipboard_new
SaveClipboard_(clipboard_)
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