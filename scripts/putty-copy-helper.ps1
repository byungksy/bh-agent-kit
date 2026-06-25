$sh = New-Object -ComObject WScript.Shell
$target = $sh.CreateShortcut("C:\bin\putty.lnk").TargetPath
if (Test-Path $target) {
    Copy-Item $target -Destination "C:\bin\putty.exe" -Force
    Write-Host "Success! putty.exe has been copied to C:\bin" -ForegroundColor Green
} else {
    Write-Host "Error: The target path ($target) does not exist." -ForegroundColor Red
}
