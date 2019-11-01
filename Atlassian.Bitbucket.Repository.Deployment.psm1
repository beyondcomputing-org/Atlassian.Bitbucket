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
        [string]$State,
        [string]$EnvironmentUUID,
        [string]$Sort = '-state.started_on',
        [int]$Page = 1,
        [int]$Limit = 20
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/deployments/?sort=$Sort&page=$Page&pagelen=$Limit"

        if($State){
            $endpoint += "&state.name=$State"
        }

        if($EnvironmentUUID){
            $endpoint += "&environment=$EnvironmentUUID"
        }

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}