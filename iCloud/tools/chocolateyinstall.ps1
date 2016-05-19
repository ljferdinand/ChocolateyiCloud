$packageName = 'iCloud'
$version = '5.2'
$url = 'http://download.info.apple.com/Mac_OS_X/031-31851-20160428-5490DFC6-0CC6-11E6-ADDA-3715400DF7EB/iCloudSetup.exe'
#$url64bit = ''
$fileType = 'msi'
$silentArgs = '/qn /norestart'
$validExitCodes = @(0,1603, 3010)
 
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$downloadTempDir = Join-Path $toolsDir 'download-temp'
 
$app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match 'iCloud'}
 
# Check if the same version of iTunes is already installed
if ($app -and ([version]$app.Version -ge [version]$version)) {
  Write-Output $(
    'iCloud ' + $version + ' or higher is already installed. ' +
    'No need to download and install again.'
  )
} else {
 
  Install-ChocolateyZipPackage -packageName $packageName -url $url `
    -url64bit $url64bit -unzipLocation $downloadTempDir
 
  $msiFilesList = (Get-ChildItem -Path $downloadTempDir -Filter '*.msi' | Where-Object {
    $_.Name -notmatch 'AppleSoftwareUpdate*.msi'
  }).Name
 
  # Loop over each file and install it. iTunes requires all of them to be installed
  foreach ($msiFileName in $msiFilesList) {
    Install-ChocolateyInstallPackage -packageName $msiFileName -fileType $fileType `
      -silentArgs $silentArgs -file (Join-Path $downloadTempDir $msiFileName) `
      -validExitCodes $validExitCodes
  }
 
  Remove-Item $downloadTempDir -Recurse
}