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

    Begin {
        $endpoint = "repositories/$Team"
    }

    Process {
        $_endpoint = $endpoint

        # Filter to a specific project
        if($ProjectKey)
        {
            $_endpoint += "?q=project.key=%22$ProjectKey%22"
        }
        
        # Get all repos
        do
        {
            $return = Invoke-BitbucketAPI -Path $_endpoint
            $_endpoint = $return.next
            $repos += $return.values
        }
        while ($return.next)

        return $repos
    }
}