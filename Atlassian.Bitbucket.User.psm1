using module .\Atlassian.Bitbucket.Authentication.psm1

function Get-BitbucketUser {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam)
    )

    Process {
        $endpoint = "users/$Team/members"

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}

function Get-BitbucketUsersByGroup {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter (HelpMessage='The group slug')]
        [string]$GroupSlug
    )

    Process {
        $endpoint = "groups/$Team/$GroupSlug/members"
        return Invoke-BitbucketAPI -Path $endpoint -API_Version '1.0'
    }
}