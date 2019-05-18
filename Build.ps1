# Install Requirements
Install-Module Pester -Force
Install-Module PSScriptAnalyzer -Force

# Run Unit Tests
Invoke-Pester -EnableExit -OutputFile 'TestResults.xml' -OutputFormat NUnitXml

# Create Build Folder
$BuildFolder = 'Build/Atlassian.Bitbucket'
if(!(Test-Path $BuildFolder)){
    New-Item -ItemType Directory -Path $BuildFolder
}

# Copy in Items for Release
Copy-Item -Path 'Atlassian.Bitbucket.psd1' -Destination $BuildFolder -Force
Copy-Item -Path 'README.md' -Destination $BuildFolder -Force
Copy-Item -Path 'CHANGELOG.md' -Destination $BuildFolder -Force

# Module Files
Copy-Item -Path '*' -Destination $BuildFolder -Recurse -Include '*.psm1' -Force

# Copy in non-excluded subdirectories
$Directories = Get-ChildItem -Directory -Exclude 'Build','Tests'
foreach ($Directory in $Directories) {
    $Directory | Copy-Item -Destination $BuildFolder -Recurse -Force
}