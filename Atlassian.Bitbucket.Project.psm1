using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns all Projects in the team.

    .DESCRIPTION
        Returns all the Bitbucket Projects in the team, or the specific project if specified.

    .EXAMPLE
        C:\PS> Get-BitbucketProject
        Returns all projects for the currently selected team.

    .EXAMPLE
        C:\PS> Get-BitbucketProject -ProjectKey 'KEY'
        Returns the project specified by the key if found.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER ProjectKey
        Project key in Bitbucket
#>
function Get-BitbucketProject {
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
        $endpoint = "teams/$Team/projects/"
    }

    Process {
        if($ProjectKey)
        {
            # Fetch a specific project
            $_endpoint = "$endpoint$ProjectKey"
            return Invoke-BitbucketAPI -Path $_endpoint
        }
        else
        {
            $_endpoint = $endpoint
            # Get all projects
            do
            {
                $return = Invoke-BitbucketAPI -Path $_endpoint
                $_endpoint = $return.next
                $projects += $return.values
            }
            while ($return.next)

            return $projects
        }
    }
}