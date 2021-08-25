using module .\Atlassian.Bitbucket.Authentication.psm1
using module .\Atlassian.Bitbucket.Repository.Environment.psm1

function Get-BitbucketRepositoryEnvironmentVariable {
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
            $endpoint = "repositories/$Workspace/$RepoSlug/deployments_config/environments/$_uuid/variables"
            return Invoke-BitbucketAPI -Path $endpoint -Paginated
        }
        else {
            Throw "Couldn't find the environment: $Environment"
        }
    }
}

function New-BitbucketRepositoryEnvironmentVariable {
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
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Variable key')]
        [string]$Key,
        [Parameter( Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Variable value')]
        [string]$Value,
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Obscure the variable value')]
        [switch]$Secured

    )
    Process {
        $_environments = Get-BitbucketRepositoryEnvironment -Workspace $Workspace -RepoSlug $RepoSlug
        $_uuid = ($_environments | Where-Object { $_.name -eq $Environment }).uuid

        if ($_uuid) {
            $body = [ordered]@{
                key     = $Key
                secured = $Secured.IsPresent
                value   = $Value
            } | ConvertTo-Json -Depth 1 -Compress

            $endpoint = "repositories/$Workspace/$RepoSlug/deployments_config/environments/$_uuid/variables"
            if ($pscmdlet.ShouldProcess("$Key in the environment $Environment in the repo $RepoSlug", 'create')) {
                return Invoke-BitbucketAPI -Path $endpoint -Method Post -Body $body
            }
        }
        else {
            Throw "Couldn't find the environment: $Environment"
        }
    }
}

function Remove-BitbucketRepositoryEnvironmentVariable {
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
        [string]$Environment,
        [Parameter( Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Variable key')]
        [string]$Key
    )
    Process {
        $_uuidEnv = (Get-BitbucketRepositoryEnvironment -Workspace $Workspace -RepoSlug $RepoSlug | Where-Object { $_.name -eq $Environment }).uuid

        if ($_uuidEnv) {
            $_uuidVar = (Get-BitbucketRepositoryEnvironmentVariable -Workspace $Workspace -RepoSlug $RepoSlug -Environment $Environment | Where-Object { $_.key -eq $Key }).uuid

            if ($_uuidVar) {
                $endpoint = "repositories/$Workspace/$RepoSlug/deployments_config/environments/$_uuidEnv/variables/$_uuidVar"
                if ($pscmdlet.ShouldProcess("$Key in the environment $Environment in the repo $RepoSlug", 'delete')) {
                    return Invoke-BitbucketAPI -Path $endpoint -Method Delete
                }
            }
        }
        else {
            Throw "Couldn't find the environment: $Environment"
        }
    }
}