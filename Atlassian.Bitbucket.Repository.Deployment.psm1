using module .\Atlassian.Bitbucket.Authentication.psm1

function Get-BitbucketRepositoryDeployment {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [ValidateSet('COMPLETED', 'IN_PROGRESS', 'UNDEPLOYED')]
        [string]$State,
        [string]$EnvironmentUUID,
        [string]$Sort = '-state.started_on',
        [string[]]$Fields,
        [int]$Page = 1,
        [int]$Limit = 20
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/deployments/?sort=$Sort&page=$Page&pagelen=$Limit"

        if ($State) {
            $endpoint += "&state.name=$State"
        }

        if ($EnvironmentUUID) {
            $endpoint += "&environment=$EnvironmentUUID"
        }

        if ($Fields) {
            $endpoint += '&fields='
            for ($i = 0; $i -lt $Fields.Count; $i++) {
                if ($i -lt ($Fields.Count - 1)) {
                    $endpoint += "%2B$($Fields[$i])%2C"
                }
                else {
                    $endpoint += "%2B$($Fields[$i])"
                }
            }
        }

        return (Invoke-BitbucketAPI -Path $endpoint).values
    }
}