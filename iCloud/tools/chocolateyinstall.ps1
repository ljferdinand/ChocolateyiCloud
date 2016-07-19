$packageName = 'iCloud'
$version = '5.2.1'
$url = 'http://download.info.apple.com/Mac_OS_X/031-64889-20160718-E85BB333-494F-11E6-A444-EFCFCF9F5A9B/iCloudSetup.exe'
$url64bit = 'http://download.info.apple.com/Mac_OS_X/031-64889-20160718-E85BB333-494F-11E6-A444-EFCFCF9F5A9B/iCloudSetup.exe'
$fileType = 'msi'
$silentArgs = '/qn /norestart'
$validExitCodes = @(0,1603, 3010)
$rebootrequired 
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$downloadTempDir = Join-Path $toolsDir 'download-temp'

[array]$app = Get-UninstallRegistryKey -SoftwareName $packageName
 
# Check if the same version of icloud is already installed
if ($app -and ([version]$app.Version -ge [version]$version)) {
  Write-Output $(
    'iCloud ' + $version + ' or higher is already installed. ' +
    'No need to download and install again.'
  )
} else {
        Install-ChocolateyZipPackage -packageName $packageName -url $url `
        -url64bit $url64bit -unzipLocation $downloadTempDir
 
        if (Get-ProcessorBits 64) {
            $msiFilesList = (Get-ChildItem -Path $downloadTempDir -Filter '*.msi' | Where-Object {
                $_.Name -notmatch 'AppleSoftwareUpdate*.msi'
            }).Name
        }
        else {
            erase $downloadTempDir\*64.msi -force
            $msiFilesList = (Get-ChildItem -Path $downloadTempDir -Filter '*.msi' | Where-Object {
                $_.Name -notmatch 'AppleSoftwareUpdate*.msi'
                }).Name
        }

        # Loop over each file and install it. icloud requires all of them to be installed
        foreach ($msiFileName in $msiFilesList) {
        Install-ChocolateyInstallPackage -packageName $msiFileName -fileType $fileType `
        -silentArgs $silentArgs -file (Join-Path $downloadTempDir $msiFileName) `
        -validExitCodes $validExitCodes
        }

    if (Test-Path $downloadTempDir) {Remove-Item $downloadTempDir -Recurse}

    if ($rebootrequired) {
        exit 3010
    }
    
}
