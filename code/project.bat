@echo off

REM Get the path to the user's Chrome bookmarks file
set "chrome_bookmarks_file=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Bookmarks"
if not exist "%chrome_bookmarks_file%" (
    echo Error: Chrome bookmarks file not found.
    exit /b 1
)

REM Get the output format from the user
set /p "format=Enter output format (html, md, pdf): "

REM Set the output file name and extension based on the chosen format
set "output_file=output"
if "%format%" == "html" set "output_file=%output_file%.html"
if "%format%" == "md" set "output_file=%output_file%.md"
if "%format%" == "pdf" set "output_file=%output_file%.pdf"

REM Extract the bookmarks data using PowerShell
powershell -Command "$json = Get-Content '%chrome_bookmarks_file%' -Raw | ConvertFrom-Json; $bookmarks = $json.roots.bookmark_bar.Children + $json.roots.other.Children; $output = ''; foreach ($bookmark in $bookmarks) { $output += '`n* [' + $bookmark.name + '](' + $bookmark.url + ')'; }; $output | Out-File -Encoding UTF8 -FilePath bookmarks.txt"

REM Convert the bookmarks to the desired format using pandoc
if "%format%" == "html" pandoc -s bookmarks.txt -o "%output_file%"
if "%format%" == "md" move bookmarks.txt "%output_file%"
if "%format%" == "pdf" pandoc -s bookmarks.txt -o "%output_file%"

REM Clean up temporary files
del bookmarks.txt
