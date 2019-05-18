# Install Requirements
Install-Module Pester -Force
Install-Module PSScriptAnalyzer -Force

# Run Unit Tests
Invoke-Pester -OutputFile 'TestResults.xml' -OutputFormat NUnitXml