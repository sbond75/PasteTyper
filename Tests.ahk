retval := "
(
    asdkl
asd
 342
         43 54 3        0  a                                                  
)"
; ``am)` are some options from https://www.autohotkey.com/docs/v1/misc/RegEx-QuickRef.htm#Options and https://www.autohotkey.com/board/topic/17237-regex-doesnt-match-at-the-beginning-of-all-new-lines/ where `a means to recognize more types of newlines which is required to match a multiline string like above. m option makes it multiline (can match across multiple lines).
retval := regexreplace(retval, "`am)^\s+")
msgbox % retval