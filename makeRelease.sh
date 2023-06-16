currentCommitHash="$(git rev-parse HEAD)"
version="$currentCommitHash"
if [ ! -e releases ]; then
    mkdir releases
fi

export version="$version"
# This separate file is required since command-line arguments don't seem to be passed to certain programs from outside Git bash for some reason:
./makeExe.bat

tar -czf "releases/PasteTyper-$version.tar.gz" ".venv" "PasteTyper-$version.exe"
