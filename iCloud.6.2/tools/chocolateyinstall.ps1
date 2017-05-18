$packageName = 'iCloud'
$version = '6.2.1.67'
$url = 'http://download.info.apple.com/Mac_OS_X/031-70272-20170323-C23F530C-0FC4-11E7-9BB6-C22700A0ED6C/iCloudSetup.exe'
$url64bit = 'http://download.info.apple.com/Mac_OS_X/031-70272-20170323-C23F530C-0FC4-11E7-9BB6-C22700A0ED6C/iCloudSetup.exe'
$fileType = 'msi'
$silentArgs = '/qn /norestart'
$validExitCodes = @(0,1603, 3010)
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$downloadTempDir = Join-Path $toolsDir 'download-temp'
$checksum = 'E522EDB649346A05F944055F6BD8B1B6D1330F8389DD54B3649A883659CDA2CF'

[array]$app = Get-UninstallRegistryKey -SoftwareName $packageName 
 
# Check if the same version of icloud is already installed
if ($app -and ([version]$app.DisplayVersion -ge [version]$version)) {
  Write-Output $(
    'iCloud ' + $version + ' or higher is already installed. ' +
    'No need to download and install again.'
  )
} else {
        Install-ChocolateyZipPackage -packageName $packageName -url $url `
        -url64bit $url64bit -unzipLocation $downloadTempDir `
		-checksum $checksum -checksumType 'sha256'
 
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


    
}
