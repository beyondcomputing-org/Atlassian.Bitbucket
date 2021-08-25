using module .\Classes\Atlassian.Bitbucket.Auth.psm1
using module .\Classes\Atlassian.Bitbucket.Settings.psm1

<#
    .SYNOPSIS
        Login to Bitbucket

    .DESCRIPTION
        Allows logins to Bitbucket for both Basic authentication or OAuth 2.0.

    .EXAMPLE
        Login-Bitbucket -Credential (Get-Credential)
        # Provide authentication for API calls using Basic Auth

    .EXAMPLE
        Login-Bitbucket -AtlassianCredential (Get-Credential) -OAuthConsumer (Get-Credential)
        # Provide authentication for API calls using OAuth 2.0

    .PARAMETER Credential
        Username and password in Bitbucket for basic authentication.

    .PARAMETER AtlassianCredential
        Email and password for Atlassian Authentication.  Used with OAuthConsumer to generate token.

    .PARAMETER OAuthConsumer
        Key and Secret for OAuth Consumer.  https://confluence.atlassian.com/bitbucket/oauth-on-bitbucket-cloud-238027431.html#OAuthonBitbucketCloud-Createaconsumer
#>
function New-BitbucketLogin {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', DefaultParameterSetName='Basic')]
    [Alias('Login-Bitbucket')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Basic')]
        [PSCredential]$Credential,
        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth2')]
        [PSCredential]$AtlassianCredential,
        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth2')]
        [PSCredential]$OAuthConsumer,
        [Switch]$Save
    )
    if ($pscmdlet.ShouldProcess('Bitbucket Login', 'create'))
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Basic' {
                $Auth = [BitbucketAuth]::NewInstance($Credential)
            }
            'OAuth2' {
                $Auth = [BitbucketAuth]::NewInstance($AtlassianCredential, $OAuthConsumer)
            }
            Default {
                'You must specify either Basic or OAuth Credentials.'
            }
        }

        Write-Output "Welcome $($Auth.User.display_name)"

        Select-BitbucketWorkspace

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
        [String]$Method = 'Get',
        [Object]$Body,
        [Switch]$Paginated,
        [Int32]$MaxPages = 2147483647,
        [Switch]$InternalAPI,
        [String]$API_Version,
        [String]$ContentType = 'application/json'
    )
    $Auth = [BitbucketAuth]::GetInstance()

    if($InternalAPI){
        $URI = [BitbucketSettings]::INTERNAL_URL + $Path
        if($Auth.AuthType -ne 'Bearer'){
            Throw 'You must use OAuth 2.0 for Internal APIs.  Login using: Login-Bitbucket -AtlassianCredential (Get-Credential) -OAuthConsumer (Get-Credential)'
        }
    }else{
        if ($API_Version){
            [BitbucketSettings]$Settings = [BitbucketSettings]::new($API_Version)
        }
        else{
            [BitbucketSettings]$Settings = [BitbucketSettings]::new()
        }
        $URI = $Settings.VERSION_URL + $Path
    }

    if($Paginated){
        $counter = 0

        $baseURL = ($URI.split('?'))[0]
        $_endpoint = $URI

        # Process Pagination
        do
        {
            Write-Debug "URI: $_endpoint"
            $counter++
            Write-Progress -Activity "Fetching page $counter"
            $return = Invoke-RestMethod -Uri $_endpoint -Method $Method -Body $Body -Headers $Auth.GetAuthHeader() -ContentType $ContentType

            # Avoid any sort of redirect to a separate hostname or endpoint and only follow the new query parameters for pagination
            If ($return.next) {
                $queryParts = $return.next.split('?')
                $queryString = $queryParts[1..$($queryParts.count-1)] -join('')
                $_endpoint = "$baseURL`?$queryString"
            }
            $response += $return.values
        }
        while ($return.next -and $counter -lt $MaxPages)

        return $response
    }else{
        if($Body){
            Write-Debug 'Sending request with a body and content type'
            Write-Debug "Body: $Body"
            return Invoke-RestMethod -Uri $URI -Method $Method -Body $Body -Headers $Auth.GetAuthHeader() -ContentType $ContentType
        }else{
            Write-Debug 'Sending request with no body or content type'
            return Invoke-RestMethod -Uri $URI -Method $Method -Headers $Auth.GetAuthHeader()
        }
    }
}

function Get-BitbucketWorkspace {
    [CmdletBinding()]
    [Alias("Get-BitbucketTeam")]
    param(
        [ValidateSet('owner', 'collaborator', 'member')]
        [String]$Role = 'member'
    )
    $endpoint = "workspaces?role=$Role"

    return (Invoke-BitbucketAPI -Path $endpoint).values
}

function Get-BitbucketSelectedWorkspace {
    [CmdletBinding()]
    [Alias("Get-BitbucketSelectedTeam")]
    param(
    )

    $Auth = [BitbucketAuth]::GetInstance()
    return $Auth.Team
}

function Select-BitbucketWorkspace {
    [CmdletBinding()]
    [Alias("Select-BitbucketTeam")]
    param(
        [Alias("Team")]
        [String]$Workspace
    )

    if(!$Workspace){
        $Workspaces = Get-BitbucketWorkspace
        $index = 0

        if($Workspaces.count -gt 1){

            for ($i = 0; $i -lt $Workspaces.Count; $i++) {
                Write-Output "$i - $($Workspaces[$i].name)"
            }
            [int]$index = Read-Host 'Which workspace would you like to use?'
        }
        $Workspace = $Workspaces[$index].slug
    }

    $Auth = [BitbucketAuth]::GetInstance()
    $Auth.Team = $Workspace
}