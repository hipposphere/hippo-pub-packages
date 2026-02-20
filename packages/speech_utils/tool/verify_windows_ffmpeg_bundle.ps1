[CmdletBinding()]
param(
  [string]$FfmpegWindowsDir = ""
)

$ErrorActionPreference = "Stop"

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

function Test-BinaryContainsToken {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Token
  )

  $bytes = [System.IO.File]::ReadAllBytes($Path)
  $text = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($bytes).ToLowerInvariant()
  return $text.Contains($Token.ToLowerInvariant())
}

function Get-LatestDllByPrefix {
  param(
    [Parameter(Mandatory = $true)][string]$DirectoryPath,
    [Parameter(Mandatory = $true)][string]$Prefix
  )

  $matches = Get-ChildItem -Path $DirectoryPath -File -Filter "$Prefix-*.dll" -ErrorAction SilentlyContinue |
    Sort-Object Name
  if ($matches.Count -eq 0) {
    return $null
  }
  return $matches[-1]
}

$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($FfmpegWindowsDir)) {
  $FfmpegWindowsDir = Join-Path $packageRoot "third_party/ffmpeg/windows"
}
$FfmpegWindowsDir = Get-AbsolutePath -Path $FfmpegWindowsDir

$includeDir = Join-Path $FfmpegWindowsDir "include"
$libDir = Join-Path $FfmpegWindowsDir "lib"
$binDir = Join-Path $FfmpegWindowsDir "bin"

Assert-DirectoryExists -Path $includeDir -Message "Missing include directory: $includeDir"
Assert-DirectoryExists -Path $libDir -Message "Missing lib directory: $libDir"
Assert-DirectoryExists -Path $binDir -Message "Missing bin directory: $binDir"

$requiredHeaders = @(
  "libavcodec/avcodec.h",
  "libavformat/avformat.h",
  "libavutil/avutil.h",
  "libswresample/swresample.h"
)
foreach ($relHeader in $requiredHeaders) {
  $headerPath = Join-Path $includeDir $relHeader
  Assert-FileExists -Path $headerPath -Message "Missing header: $headerPath"
}

$requiredImportLibPrefixes = @("avcodec", "avformat", "avutil", "swresample")
foreach ($prefix in $requiredImportLibPrefixes) {
  $exactLib = Join-Path $libDir "$prefix.lib"
  if (Test-Path -LiteralPath $exactLib -PathType Leaf) {
    continue
  }

  $versionedLibInLibDir = Get-ChildItem -Path $libDir -File -Filter "$prefix-*.lib" -ErrorAction SilentlyContinue |
    Select-Object -First 1
  if ($null -ne $versionedLibInLibDir) {
    continue
  }

  $exactLibInBin = Join-Path $binDir "$prefix.lib"
  if (Test-Path -LiteralPath $exactLibInBin -PathType Leaf) {
    continue
  }

  $versionedLibInBinDir = Get-ChildItem -Path $binDir -File -Filter "$prefix-*.lib" -ErrorAction SilentlyContinue |
    Select-Object -First 1
  if ($null -ne $versionedLibInBinDir) {
    continue
  }

  throw "Missing import library for '$prefix' in $libDir and $binDir"
}

$avcodecDll = Get-LatestDllByPrefix -DirectoryPath $binDir -Prefix "avcodec"
$avformatDll = Get-LatestDllByPrefix -DirectoryPath $binDir -Prefix "avformat"
$avutilDll = Get-LatestDllByPrefix -DirectoryPath $binDir -Prefix "avutil"
$swresampleDll = Get-LatestDllByPrefix -DirectoryPath $binDir -Prefix "swresample"

if ($null -eq $avcodecDll -or $null -eq $avformatDll -or $null -eq $avutilDll -or $null -eq $swresampleDll) {
  throw "Missing required runtime DLL(s) in $binDir"
}

$issues = New-Object System.Collections.Generic.List[string]

if (Test-BinaryContainsToken -Path $avcodecDll.FullName -Token "libiconv-2.dll") {
  $iconvPath = Join-Path $binDir "libiconv-2.dll"
  if (-not (Test-Path -LiteralPath $iconvPath -PathType Leaf)) {
    $issues.Add("Missing libiconv-2.dll required by $($avcodecDll.Name)")
  }
  else {
    if (-not (Test-BinaryContainsToken -Path $iconvPath -Token "libiconv_open")) {
      $issues.Add("libiconv-2.dll missing symbol libiconv_open")
    }
    if (-not (Test-BinaryContainsToken -Path $iconvPath -Token "libiconv_close")) {
      $issues.Add("libiconv-2.dll missing symbol libiconv_close")
    }
  }
}

if (Test-BinaryContainsToken -Path $avformatDll.FullName -Token "zlib1.dll") {
  $zlibPath = Join-Path $binDir "zlib1.dll"
  if (-not (Test-Path -LiteralPath $zlibPath -PathType Leaf)) {
    $issues.Add("Missing zlib1.dll required by $($avformatDll.Name)")
  }
  elseif (-not (Test-BinaryContainsToken -Path $zlibPath -Token "uncompress")) {
    $issues.Add("zlib1.dll missing symbol uncompress")
  }
}

if (Test-BinaryContainsToken -Path $avutilDll.FullName -Token "libwinpthread-1.dll") {
  $winpthreadPath = Join-Path $binDir "libwinpthread-1.dll"
  if (-not (Test-Path -LiteralPath $winpthreadPath -PathType Leaf)) {
    $issues.Add("Missing libwinpthread-1.dll required by $($avutilDll.Name)")
  }
  else {
    if (-not (Test-BinaryContainsToken -Path $winpthreadPath -Token "clock_gettime64")) {
      $issues.Add("libwinpthread-1.dll missing symbol clock_gettime64")
    }
    if (-not (Test-BinaryContainsToken -Path $winpthreadPath -Token "nanosleep64")) {
      $issues.Add("libwinpthread-1.dll missing symbol nanosleep64")
    }
  }
}

if ($issues.Count -gt 0) {
  Write-Host "FFmpeg bundle validation failed for: $FfmpegWindowsDir" -ForegroundColor Red
  foreach ($issue in $issues) {
    Write-Host " - $issue" -ForegroundColor Red
  }
  throw "Incompatible FFmpeg bundle."
}

Write-Host "FFmpeg bundle validation passed." -ForegroundColor Green
Write-Host "include: $includeDir"
Write-Host "lib:     $libDir"
Write-Host "bin:     $binDir"
