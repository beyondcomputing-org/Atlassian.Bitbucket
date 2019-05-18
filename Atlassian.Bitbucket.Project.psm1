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
function Get-BitbucketProject {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage="Name of the team in Bitbucket.")]
        [string]$Team,
        [Parameter( Mandatory=$false,
                    Position=1,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage="Project key in Bitbucket")]
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