# Gunakan folder temporary pendek agar socket Java Windows dapat dibuat.
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
$previousOptions = $env:JAVA_TOOL_OPTIONS
try {
    $temporaryDirectory = Join-Path $PSScriptRoot 'build\java-tmp'
    New-Item -ItemType Directory -Force -Path $temporaryDirectory | Out-Null
    $env:JAVA_TOOL_OPTIONS = "$previousOptions `"-Djava.io.tmpdir=$temporaryDirectory`" `"-Djdk.net.unixdomain.tmpdir=$temporaryDirectory`""
    flutter build apk --debug
    if ($LASTEXITCODE -ne 0) { throw 'Build APK gagal. Periksa keluaran Gradle di atas.' }
}
finally {
    $env:JAVA_TOOL_OPTIONS = $previousOptions
    Pop-Location
}
