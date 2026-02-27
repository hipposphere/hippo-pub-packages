[CmdletBinding()]
param(
  [string]$BundleDir = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BundleDir)) {
  $packageRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  $BundleDir = Join-Path $packageRoot "third_party/webrtc_apm/windows"
}

$bundleRoot = [System.IO.Path]::GetFullPath($BundleDir)
if (-not (Test-Path -LiteralPath $bundleRoot -PathType Container)) {
  throw "WebRTC APM bundle directory does not exist: $bundleRoot"
}

$headerCandidates = @(
  (Join-Path $bundleRoot "include/modules/audio_processing/include/audio_processing.h"),
  (Join-Path $bundleRoot "include/webrtc-audio-processing-1/modules/audio_processing/include/audio_processing.h")
)
$requiredHeader = $headerCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($requiredHeader)) {
  throw "Missing required WebRTC APM header. Checked: $($headerCandidates -join ', ')"
}

$candidateLibRoots = @(
  (Join-Path $bundleRoot "lib"),
  (Join-Path $bundleRoot "bin")
)
$importLibCandidates = @()
foreach ($root in $candidateLibRoots) {
  if (-not (Test-Path -LiteralPath $root -PathType Container)) {
    continue
  }
  $importLibCandidates += Get-ChildItem -Path $root -Filter "*.lib" -File
}

$matchedLibs = $importLibCandidates | Where-Object {
  $_.Name -match '^(webrtc[-_]audio[-_]processing|audio_processing)(-|\.|$)'
}

if ($matchedLibs.Count -eq 0) {
  throw "Missing WebRTC APM import library (expected webrtc-audio-processing*.lib, webrtc_audio_processing*.lib, or audio_processing*.lib in lib/ or bin/)."
}

Write-Host "WebRTC APM bundle looks valid."
Write-Host "Bundle: $bundleRoot"
Write-Host "Header: $requiredHeader"
Write-Host "Import library: $($matchedLibs[0].FullName)"

$binDir = Join-Path $bundleRoot "bin"
if (Test-Path -LiteralPath $binDir -PathType Container) {
  $runtimeDlls = Get-ChildItem -Path $binDir -Filter "*.dll" -File | Where-Object {
    $_.Name -match '^(webrtc[-_]audio[-_]processing|audio_processing|webrtc[-_]audio[-_]coding)(-|\.|$)'
  }
  if ($runtimeDlls.Count -gt 0) {
    Write-Host "Runtime DLL(s):"
    foreach ($dll in $runtimeDlls) {
      Write-Host " - $($dll.FullName)"
    }
  }
}
