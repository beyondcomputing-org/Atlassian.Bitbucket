using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        A brief description of the function.

    .DESCRIPTION
        A detailed description of the function.

    .EXAMPLE
        C:\PS> Verb-Noun
        Describe the above example

    .PARAMETER Name
        The description of a parameter. Add a ".PARAMETER" keyword for each parameter in the function.
#>
function Get-BitbucketRepository {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Will use selected team if not provided.')]
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