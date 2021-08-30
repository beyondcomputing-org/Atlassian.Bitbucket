using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Gets all environments in the specified repsitory.

    .DESCRIPTION
        Gets all environments in the specified repsitory.

    .EXAMPLE
        C:\PS> Get-BitbucketRepositoryEnvironment -RepoSlug 'Repo'
        Gets all environments in the Repo `Repo`.

    .PARAMETER Workspace
        Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.
#>
function Get-BitbucketRepositoryEnvironment {
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
        [string]$EnvironmentName
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/environments/"
        $response = Invoke-BitbucketAPI -Path $endpoint -Paginated

        if ($EnvironmentName) {
            return $response | Where-Object { $_.Name -eq $EnvironmentName }
        }
        else {
            return $response
        }
    }
}

<#
    .SYNOPSIS
        Creates a new environment in the specified repsitory.

    .DESCRIPTION
        Creates a new environment in the specified repsitory.

    .EXAMPLE
        C:\PS> New-BitbucketRepositoryEnvironment -RepoSlug 'Repo' -Environment 'QA' -Type 'Test'
        Creates a new environment called QA on the repo with a type of Test.

    .PARAMETER Workspace
        Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Environment
        Name of the environment.

    .PARAMETER Type
        Name of the environment type. ['Test', 'Staging','Production']

    .PARAMETER Rank
        Rank of the environment.
#>
function New-BitbucketRepositoryEnvironment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
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
        [Parameter( Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the environment.')]
        [string]$Environment,
        [Parameter( Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the environment type.')]
        [ValidateSet('Test', 'Staging', 'Production')]
        [string]$Type,
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Rank of the environment.')]
        [string]$Rank = 0
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/environments/"
        $body = [ordered]@{
            type                     = 'deployment_environment'
            name                     = $Environment
            rank                     = $Rank
            environment_type         = @{
                type = 'deployment_environment_type'
                name = $Type
            }
            lock                     = [ordered]@{
                type = 'deployment_environment_lock_open'
                name = 'OPEN'
            }
            restrictions             = [ordered]@{
                type       = 'deployment_restrictions_configuration'
                admin_only = $false
            }
            hidden                   = $true
            environment_lock_enabled = $true
        } | ConvertTo-Json -Depth 3 -Compress

        if ($pscmdlet.ShouldProcess("$Environment in $RepoSlug", 'create')) {
            return Invoke-BitbucketAPI -Path $endpoint -Method Post -Body $body
        }
    }
}

<#
    .SYNOPSIS
        Deletes an environment in the specified repsitory.

    .DESCRIPTION
        Deletes an environment in the specified repsitory.

    .EXAMPLE
        C:\PS> Remove-BitbucketRepositoryEnvironment -RepoSlug 'Repo' -Environment 'QA'
        Deletes the environment called QA on the Repo.

    .PARAMETER Workspace
        Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Environment
        Name of the environment.
#>
function Remove-BitbucketRepositoryEnvironment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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
        [Parameter( Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the environment.')]
        [string]$Environment
    )

    Process {
        $_environments = Get-BitbucketRepositoryEnvironment -Workspace $Workspace -RepoSlug $RepoSlug
        $_uuid = ($_environments | Where-Object { $_.name -eq $Environment }).uuid

        if ($_uuid) {
            $endpoint = "repositories/$Workspace/$RepoSlug/environments/$_uuid"
            if ($pscmdlet.ShouldProcess("$Environment in $RepoSlug", 'delete')) {
                return Invoke-BitbucketAPI -Path $endpoint -Method Delete
            }
        }
    }
}