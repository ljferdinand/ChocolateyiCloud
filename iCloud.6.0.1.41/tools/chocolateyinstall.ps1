$packageName = 'iCloud'
$version = '6.0.1.41'
$url = 'http://download.info.apple.com/Mac_OS_X/031-45723-20160920-9D35D6D4-7AB5-11E6-893D-D61934D2D062/iCloudSetup.exe'
$url64bit = 'http://download.info.apple.com/Mac_OS_X/031-45723-20160920-9D35D6D4-7AB5-11E6-893D-D61934D2D062/iCloudSetup.exe'
$fileType = 'msi'
$silentArgs = '/qn /norestart'
$validExitCodes = @(0,1603, 3010)
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$downloadTempDir = Join-Path $toolsDir 'download-temp'
$checksum = '369255F470099210A0ACDE279F7A02CE1E002D55B5F83873887F81700E46DB17'

[array]$app = Get-UninstallRegistryKey -SoftwareName $packageName
 
# Check if the same version of icloud is already installed
if ($app -and ([version]$app.Version -ge [version]$version)) {
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
