currentTag="$(git describe --tags --abbrev=0 --exact-match)" # https://stackoverflow.com/questions/3404936/show-which-git-tag-you-are-on
exitCode="$?"
if [ "$exitCode" != "0" ]; then
    # Not on a tag currently; try using the current commit hash
    currentCommitHash="$(git rev-parse HEAD)"
    version="$currentCommitHash"
else
    version="$currentTag"
fi

if [ ! -e releases ]; then
    mkdir releases
fi

export version="$version"
# This separate file is required since command-line arguments don't seem to be passed to certain programs from outside Git bash for some reason:
./makeExe.bat

tar -czf "releases/PasteTyper-$version.tar.gz" ".venv" "PasteTyper-$version.exe" differ.py diffs.py
