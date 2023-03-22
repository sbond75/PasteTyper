try:
    import pyjion
    pyjion.enable()
    pyjion.config(level=2) # Highest level of optimization
except:
    import traceback
    traceback.print_exc()
    pass # No pyjion support (fast JIT for python; can install at https://github.com/tonybaloney/Pyjion )

import sys
from differ import diff, Addition, Removal, Unchanged

theseAreFiles = False
if len(sys.argv) > 2:
    current = sys.argv[1]
    new = sys.argv[2]
    theseAreFiles = sys.argv[3] == '1' if len(sys.argv) > 3 else False
    if theseAreFiles:
        current = open(current, 'r')
        new = open(new, 'r')
        
        current_ = current.read()
        current.close()
        current = current_
        new_ = new.read()
        new.close()
        new = new_
else:
    marker = "special ending marker 1111111111112310239120391203901239029132323"

    mode = 0
    current = ''
    new = ''
    for line in sys.stdin: # (includes newline -- https://stackoverflow.com/questions/1450393/how-do-i-read-from-stdin )
        if line.rstrip() == marker:
            mode += 1
            continue
        if mode == 0:
            current += line
        elif mode == 1:
            new += line
        else:
            print("Too many inputs")
            exit(1)

# The editor starts at the top of the file in ComputerCraft.
# currentLine = 0
currentCharOnLine = 0

# Configurable #
debugMode = False # Configurable
verbosityLevelForDebugMode = 2 # 0 is quietest, 1 is higher, 2 is highest
stripTabs = False # Removes tabs
# #

correctForDrift = True # When you drift in the editor like going right and then down sometimes doesn't bring you back to the start of a line

# Get from `current` to `new` with a series of edits.
results = diff(current, new)
commands = [] # AutoHotkey key codes
navigationCommands = [] # Gets flushed into the above `commands` when an edit command is encountered (like insertion or deletion). This allows optimizing out some navigation commands that are unnecessary (i.e. commands that move down a bunch when nothing is left to edit further down in the text).
def left(msg):
    if debugMode and verbosityLevelForDebugMode > 1:
        print('left:', msg, file=sys.stderr)
    addCommand("{Left}", to='navigationCommands')
def down(msg):
    global currentCharOnLine
    if correctForDrift:
        for i in range(currentCharOnLine):
            left('drift compensation #' + str(i))
    currentCharOnLine = 0 # On a new line now, so go back to the start

    if debugMode and verbosityLevelForDebugMode > 1:
        print('down:', msg, file=sys.stderr)
    addCommand("{Down}", to='navigationCommands')
def right(msg):
    global currentCharOnLine
    if debugMode and verbosityLevelForDebugMode > 1:
        print('right:', msg, file=sys.stderr)
    addCommand("{Right}", to='navigationCommands') # TODO: add sleep for going right.. custom sleep commands for ahk? Maybe use something like `Loop, parse, {Right}` and then add sleeps, then send {Right}
    currentCharOnLine += 1
def addEscapedCommand(str_): # Insert plain text
    global currentCharOnLine
    if debugMode and verbosityLevelForDebugMode > 1:
        print('addEscapedCommand:', repr(str_), file=sys.stderr)
    # Escape curly braces '}', '{' using {}} and {{}       ( https://www.autohotkey.com/board/topic/32092-escape-curly-braces-in-hotstring/ )
    assert len(str_) == 1
    # https://www.autohotkey.com/docs/v1/misc/EscapeChar.htm : "When the Send command or Hotstrings are used in their default (non-raw) mode, characters such as {}^!+# have special meaning. Therefore, to use them literally in these cases, enclose them in braces. For example: Send {^}{!}{{}."
    charMap = {
        '}' : '{}}',
        '{' : '{{}',
        '^' : '{^}',
        '!' : '{!}',
        '+' : '{+}',
        '#' : '{#}',
        '\t' : '    ' if not stripTabs else '' # (tabs are replaced with spaces too)
    }
    newStr = ''.join([(charMap[x] if x in charMap else x) for x in str_]) # For each character in the string, replace them if they are special ones that need to be escaped
    flushNavigationCommands()
    commands.append(newStr)
    currentCharOnLine += 1
def addCommand(str_, to='commands'): # Insert plain text or AHK commands in braces
    global currentCharOnLine
    if debugMode and verbosityLevelForDebugMode > 0:
        print('addCommand:', repr(str_), file=sys.stderr)
    commands_ = {'commands' : commands, 'navigationCommands' : navigationCommands}[to]
    if to == 'commands':
        flushNavigationCommands()
    for i in range(str_.lower().count('{backspace}')):
        currentCharOnLine -= 1
    commands_.append(str_)
if debugMode:
    print(results, file=sys.stderr)
i = 0
def flushNavigationCommands():
    global navigationCommands
    for command in navigationCommands:
        commands.append(command)
    navigationCommands = []
while i < len(results):
    result = results[i]
    assert len(result.content) == 1

    if isinstance(result, Addition):
        # Add it
        if result.content != '\n':
            addEscapedCommand(result.content)
            #right(result) # Seek past it after adding it
        else:
            addCommand('{Enter}')
            currentCharOnLine = 0 # On a new line now
    elif isinstance(result, Removal):
        # Remove it
        right(result) # Seek past it before removing it
        addCommand("{Backspace}")
    else:
        assert isinstance(result, Unchanged)

        # See if whole line is unchanged so that we can go down
        canJustGoDown = True # Assume True
        for j in range(i, len(results)):
            if not isinstance(results[j], Unchanged):
                canJustGoDown = False
                break
            if results[j].content == '\n':
                break
        if canJustGoDown:
            down('range: ' + str(i) + ', ' + str(j+1))
            i = j + 1 # Seek past it
            continue

        # Seek past it
        if result.content == '\n':
            down(result)
        else:
            right(result)

    i += 1

res = ''.join(commands)
if debugMode:
    print('\n\n', res, sep='', file=sys.stderr)
print(res)
