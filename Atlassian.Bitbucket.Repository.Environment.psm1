using module .\Atlassian.Bitbucket.Authentication.psm1

function Get-BitbucketRepositoryEnvironment {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [string]$RepoSlug
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/environments/"
        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}