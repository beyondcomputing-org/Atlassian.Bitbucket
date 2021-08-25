using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns all Projects in the workspace.

    .DESCRIPTION
        Returns all the Bitbucket Projects in the workspace, or the specific project if specified.

    .EXAMPLE
        C:\PS> Get-BitbucketProject
        Returns all projects for the currently selected workspace.

    .EXAMPLE
        C:\PS> Get-BitbucketProject -ProjectKey 'KEY'
        Returns the project specified by the key if found.

    .PARAMETER Workspace
        Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.

    .PARAMETER ProjectKey
        Project key in Bitbucket
#>
function Get-BitbucketProject {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Project key in Bitbucket')]
        [string]$ProjectKey
    )

    Process {
        $endpoint = "workspaces/$Workspace/projects/"
        if ($ProjectKey) {
            # Fetch a specific project
            $endpoint += $ProjectKey
            return Invoke-BitbucketAPI -Path $endpoint
        }
        else {
            return Invoke-BitbucketAPI -Path $endpoint -Paginated
        }
    }
}