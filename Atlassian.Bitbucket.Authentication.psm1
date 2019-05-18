using module .\Classes\Atlassian.Bitbucket.Auth.psm1
using module .\Classes\Atlassian.Bitbucket.Settings.psm1

<#
    .SYNOPSIS
        A brief description of the function.

    .DESCRIPTION
        A detailed description of the function.

    .EXAMPLE
        C:\PS> Verb-Noun
        Describe the above example

    .PARAMETER Name
        The description of a parameter. Add a ".PARAMETER" keyword for each parameter in the function.
#>
function Add-BitbucketLogin {
    [CmdletBinding()]
    [Alias('Login-Bitbucket')]
    param(
        [PSCredential]$Credential = (Get-Credential)
    )

    $Auth = [BitbucketAuth]::NewInstance($Credential)
    Write-Host "Welcome $($Auth.User.display_name)" -ForegroundColor Green
}

function Get-BitbucketLogin {
    [CmdletBinding()]
    param(
    )

    $Auth = [BitbucketAuth]::GetInstance()

    return $Auth.User
}

function Remove-BitbucketLogin {
    [CmdletBinding()]
    param(
    )

    [BitbucketAuth]::ClearInstance()
}

function Invoke-BitbucketAPI {
    [CmdletBinding()]
    param(
        [String]$Path = '',
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        [Object]$Body
    )
    $Auth = [BitbucketAuth]::GetInstance()
    $URI = [BitbucketSettings]::VERSION_URL + $Path
    
    Invoke-RestMethod -Uri $URI -Method $Method -Body $Body -Headers @{Authorization=("Basic {0}" -f $Auth.GetBasicAuth())}
}

function Get-BitbucketTeam {
    [CmdletBinding()]
    param(
        [ValidateSet('admin', 'contributor', 'member')]
        [String]$Role = 'member'
    )
    $endpoint = "teams?role=$Role"

    return (Invoke-BitbucketAPI -Path $endpoint).values
}

function Set-BitbucketTeam {
    [CmdletBinding()]
    param(
        [String]$Team
    )

    if(!$Team){
        $Teams = Get-BitbucketTeam
        $index = 0

        if($Teams.count -gt 1){

            for ($i = 0; $i -lt $Teams.Count; $i++) {
                Write-Host "$i - $($Teams[$i].username)"
            }
            [int]$index = Read-Host 'Which team would you like to use?'
        }
        $Team = $Teams[$index].username
    }

    $Auth = [BitbucketAuth]::GetInstance()
    $Auth.Team = $Team
}