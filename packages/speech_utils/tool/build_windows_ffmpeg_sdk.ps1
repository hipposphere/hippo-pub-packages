[CmdletBinding()]
param(
  [string]$SourceDir = "",
  [string]$OutputDir = "",
  [string]$BuildDirName = ".build-minimal"
)

$ErrorActionPreference = "Stop"

function Convert-ToMsysPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  $normalized = $Path.Replace("\", "/")
  if ($normalized -match '^([A-Za-z]):/(.*)$') {
    $drive = $Matches[1].ToLowerInvariant()
    $rest = $Matches[2]
    return "/$drive/$rest"
  }

  return $normalized
}

function Assert-FileExists {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Message
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw $Message
  }
}

function Assert-DirectoryExists {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Message
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw $Message
  }
}

function Get-AbsolutePath {
  param([Parameter(Mandatory = $true)][string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw "Path cannot be empty."
  }

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }

  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($SourceDir)) {
  $SourceDir = Join-Path $packageRoot "third_party/ffmpeg/source/ffmpeg"
}
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path $packageRoot "third_party/ffmpeg/windows"
}

$SourceDir = Get-AbsolutePath -Path $SourceDir
$OutputDir = Get-AbsolutePath -Path $OutputDir

Assert-DirectoryExists -Path $SourceDir -Message "FFmpeg source directory does not exist: $SourceDir"
Assert-FileExists `
  -Path (Join-Path $SourceDir "configure") `
  -Message "FFmpeg source directory does not contain configure script: $(Join-Path $SourceDir 'configure')"

$bashPath = "C:\msys64\usr\bin\bash.exe"
if (-not (Test-Path -LiteralPath $bashPath -PathType Leaf)) {
  $bashCommand = Get-Command bash -ErrorAction SilentlyContinue
  if ($null -eq $bashCommand) {
    throw "bash was not found on PATH. Install MSYS2/Git Bash and ensure bash is available."
  }
  $bashPath = $bashCommand.Source
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$buildDir = Join-Path $OutputDir $BuildDirName
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$sourceDirMsys = Convert-ToMsysPath -Path $SourceDir
$outputDirMsys = Convert-ToMsysPath -Path $OutputDir
$buildDirMsys = Convert-ToMsysPath -Path $buildDir
$jobs = [Math]::Max([Environment]::ProcessorCount, 1)
$buildLogPath = Join-Path $buildDir "ffmpeg-build.log"

$script = @"
set -euo pipefail
cd "$buildDirMsys"
echo "Using bash: $(command -v bash || true)"
echo "Using make: $(command -v make || true)"
echo "Using cl.exe: $(command -v cl.exe || true)"
echo "Using link.exe: $(command -v link.exe || true)"
if ! command -v make >/dev/null 2>&1; then
  echo "make not found in PATH inside bash" >&2
  exit 90
fi
if ! command -v cl.exe >/dev/null 2>&1; then
  echo "cl.exe not found in PATH inside bash" >&2
  exit 91
fi
if ! command -v link.exe >/dev/null 2>&1; then
  echo "link.exe not found in PATH inside bash" >&2
  exit 92
fi
rm -rf "$outputDirMsys/include" "$outputDirMsys/lib" "$outputDirMsys/bin"
"$sourceDirMsys/configure" \
  --prefix="$outputDirMsys" \
  --target-os=win64 \
  --arch=x86_64 \
  --toolchain=msvc \
  --disable-everything \
  --disable-programs \
  --disable-doc \
  --disable-network \
  --enable-shared \
  --disable-static \
  --enable-small \
  --enable-avcodec \
  --enable-avformat \
  --enable-avutil \
  --enable-swresample \
  --enable-encoder=aac \
  --enable-decoder=pcm_s16le,aac,mp3 \
  --enable-parser=aac,mpegaudio \
  --enable-demuxer=wav,mov,mp3,aac \
  --enable-muxer=ipod,adts \
  --enable-protocol=file \
  --disable-iconv \
  --disable-zlib
make -j$jobs
make install
"@

$previousArgConv = $env:MSYS2_ARG_CONV_EXCL
$env:MSYS2_ARG_CONV_EXCL = "*"
try {
  & $bashPath -lc $script 2>&1 | Tee-Object -FilePath $buildLogPath
  $bashExitCode = $LASTEXITCODE
  if ($bashExitCode -ne 0) {
    $configLogCandidates = @(
      (Join-Path $buildDir "ffbuild/config.log"),
      (Join-Path $buildDir "config.log")
    )
    foreach ($candidate in $configLogCandidates) {
      if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        Write-Host "---- BEGIN $candidate (tail 200 lines) ----"
        Get-Content -Path $candidate -Tail 200
        Write-Host "---- END $candidate ----"
      }
    }
    throw "FFmpeg build failed with exit code ${bashExitCode}. See log: $buildLogPath"
  }
}
finally {
  if ($null -eq $previousArgConv) {
    Remove-Item Env:MSYS2_ARG_CONV_EXCL -ErrorAction SilentlyContinue
  }
  else {
    $env:MSYS2_ARG_CONV_EXCL = $previousArgConv
  }
}

$requiredHeader = Join-Path $OutputDir "include/libavcodec/avcodec.h"
$requiredLibs = @(
  "lib/avcodec.lib",
  "lib/avformat.lib",
  "lib/avutil.lib",
  "lib/swresample.lib"
)
$requiredDllPrefixes = @("avcodec", "avformat", "avutil", "swresample")

Assert-FileExists -Path $requiredHeader -Message "Missing FFmpeg header after build: $requiredHeader"

foreach ($relativeLib in $requiredLibs) {
  $libPath = Join-Path $OutputDir $relativeLib
  Assert-FileExists -Path $libPath -Message "Missing FFmpeg import library after build: $libPath"
}

$binDir = Join-Path $OutputDir "bin"
Assert-DirectoryExists -Path $binDir -Message "Missing FFmpeg runtime directory after build: $binDir"

$dllNames = Get-ChildItem -Path $binDir -Filter "*.dll" -File | ForEach-Object { $_.Name.ToLowerInvariant() }
if ($dllNames.Count -eq 0) {
  throw "No FFmpeg runtime DLLs found in $binDir after build."
}

foreach ($prefix in $requiredDllPrefixes) {
  if (-not ($dllNames | Where-Object { $_.StartsWith($prefix) })) {
    throw "Missing runtime DLL matching '$prefix*.dll' in $binDir."
  }
}

Write-Host "FFmpeg SDK build complete."
Write-Host "Source: $SourceDir"
Write-Host "Output: $OutputDir"
