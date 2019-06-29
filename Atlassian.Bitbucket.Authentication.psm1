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
function New-BitbucketLogin {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    [Alias('Login-Bitbucket')]
    param(
        [PSCredential]$Credential = (Get-Credential),
        [Switch]$Save
    )
    if ($pscmdlet.ShouldProcess('Bitbucket Login', 'create'))
    {
        $Auth = [BitbucketAuth]::NewInstance($Credential)
        Write-Output "Welcome $($Auth.User.display_name)"

        Select-BitbucketTeam

        if($Save){
            Save-BitbucketLogin
        }
    }
}

function Save-BitbucketLogin {
    [CmdletBinding()]
    param(
    )

    $Auth = [BitbucketAuth]::GetInstance()
    $Auth.save()
}

function Get-BitbucketLogin {
    [CmdletBinding()]
    param(
    )

    $Auth = [BitbucketAuth]::GetInstance()

    return $Auth.User
}

function Remove-BitbucketLogin {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
    )
    if ($pscmdlet.ShouldProcess('Bitbucket Login', 'remove'))
    {
        [BitbucketAuth]::ClearInstance()
    }
}

function Invoke-BitbucketAPI {
    [CmdletBinding()]
    param(
        [String]$Path = '',
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        [Object]$Body,
        [Switch]$Paginated
    )
    $Auth = [BitbucketAuth]::GetInstance()
    $URI = [BitbucketSettings]::VERSION_URL + $Path

    if($Paginated){
        $_endpoint = $URI

        # Process Pagination
        do
        {
            $return = Invoke-RestMethod -Uri $_endpoint -Method $Method -Body $Body -Headers @{Authorization=("Basic {0}" -f $Auth.GetBasicAuth())}  -ContentType 'application/json'
            $_endpoint = $return.next
            $response += $return.values
        }
        while ($return.next)

        return $response
    }else{
        if($Body){
            Write-Debug 'Sending request with a body and content type'
            Write-Debug "Body: $Body"
            return Invoke-RestMethod -Uri $URI -Method $Method -Body $Body -Headers @{Authorization=("Basic {0}" -f $Auth.GetBasicAuth())}  -ContentType 'application/json'
        }else{
            Write-Debug 'Sending request with no body or content type'
            return Invoke-RestMethod -Uri $URI -Method $Method -Headers @{Authorization=("Basic {0}" -f $Auth.GetBasicAuth())}
        }
    }
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

function Get-BitbucketSelectedTeam {
    [CmdletBinding()]
    param(
    )

    $Auth = [BitbucketAuth]::GetInstance()
    return $Auth.Team
}

function Select-BitbucketTeam {
    [CmdletBinding()]
    param(
        [String]$Team
    )

    if(!$Team){
        $Teams = Get-BitbucketTeam
        $index = 0

        if($Teams.count -gt 1){

            for ($i = 0; $i -lt $Teams.Count; $i++) {
                Write-Output "$i - $($Teams[$i].username)"
            }
            [int]$index = Read-Host 'Which team would you like to use?'
        }
        $Team = $Teams[$index].username
    }

    $Auth = [BitbucketAuth]::GetInstance()
    $Auth.Team = $Team
}