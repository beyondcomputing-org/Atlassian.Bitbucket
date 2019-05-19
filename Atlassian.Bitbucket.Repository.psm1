using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns all Repositories in the team.

    .DESCRIPTION
        Returns all the Bitbucket Repositories in the team, or all repositories in the specific project.

    .EXAMPLE
        C:\PS> Get-BitbucketRepository
        Returns all repositories for the currently selected team.

    .EXAMPLE
        C:\PS> Get-BitbucketRepository -ProjectKey 'KEY'
        Returns all repositories for the specified project.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER ProjectKey
        Project key in Bitbucket
#>
function Get-BitbucketRepository {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$false,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Project key in Bitbucket')]
        [string]$ProjectKey
    )

    Process {
        $endpoint = "repositories/$Team"

        # Filter to a specific project
        if($ProjectKey)
        {
            $endpoint += "?q=project.key=%22$ProjectKey%22"
        }

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}