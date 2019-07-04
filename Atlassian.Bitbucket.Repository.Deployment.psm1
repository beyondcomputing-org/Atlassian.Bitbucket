using module .\Atlassian.Bitbucket.Authentication.psm1

function Get-BitbucketRepositoryDeployment {
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
        [Alias('Slug')]
        [string]$RepoSlug,
        [ValidateSet('COMPLETED', 'IN_PROGRESS', 'UNDEPLOYED')]
        [string]$State
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/deployments/"

        if($State){
            $endpoint += "?state.name=$State"
        }

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}