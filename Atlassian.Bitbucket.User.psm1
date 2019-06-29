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