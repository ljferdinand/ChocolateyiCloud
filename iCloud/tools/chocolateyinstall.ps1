$packageName = 'iCloud'
$version = '6.1.0.30'
$url = 'http://download.info.apple.com/Mac_OS_X/031-81759-20161202-09D1C032-B72E-11E6-908C-C01AE47229E1/iCloudSetup.exe'
$url64bit = 'http://download.info.apple.com/Mac_OS_X/031-81759-20161202-09D1C032-B72E-11E6-908C-C01AE47229E1/iCloudSetup.exe'
$fileType = 'msi'
$silentArgs = '/qn /norestart'
$validExitCodes = @(0,1603, 3010)
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$downloadTempDir = Join-Path $toolsDir 'download-temp'
$checksum = '2F9522FB147CA06EFF565D78EB5DC75FC1DE761D27501F72384A98A2C85A6856'

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
