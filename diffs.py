import sys
from differ import diff, Addition, Removal, Unchanged

if len(sys.argv) > 2:
    current = sys.argv[1]
    new = sys.argv[2]
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

debugMode = True # Configurable
correctForDrift = True # When you drift in the editor like going right and then down sometimes doesn't bring you back to the start of a line

# Get from `current` to `new` with a series of edits.
results = diff(current, new)
commands = [] # AutoHotkey key codes
def left(msg):
    if debugMode:
        print('left:', msg, file=sys.stderr)
    addCommand("{Left}")
def down(msg):
    global currentCharOnLine
    if correctForDrift:
        for i in range(currentCharOnLine):
            left('drift compensation #' + str(i))
    currentCharOnLine = 0 # On a new line now, so go back to the start

    if debugMode:
        print('down:', msg, file=sys.stderr)
    addCommand("{Down}")
def right(msg):
    global currentCharOnLine
    if debugMode:
        print('right:', msg, file=sys.stderr)
    addCommand("{Right}")
    currentCharOnLine += 1
def addEscapedCommand(str_): # Insert plain text
    global currentCharOnLine
    if debugMode:
        print('addEscapedCommand:', repr(str_), file=sys.stderr)
    # Escape curly braces '}', '{' using {}} and {{}       ( https://www.autohotkey.com/board/topic/32092-escape-curly-braces-in-hotstring/ )
    assert len(str_) == 1
    commands.append(str_.replace('}', '{}}').replace('{', '{{}')) # TODO: test this
    currentCharOnLine += 1
def addCommand(str_): # Insert plain text or AHK commands in braces
    if debugMode:
        print('addCommand:', repr(str_), file=sys.stderr)
    commands.append(str_)
if debugMode:
    print(results, file=sys.stderr)
i = 0
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
    print(res, file=sys.stderr)
print(res)
