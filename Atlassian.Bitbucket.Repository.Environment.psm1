using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Gets all environments in the specified repsitory.

    .DESCRIPTION
        Gets all environments in the specified repsitory.

    .EXAMPLE
        C:\PS> Get-BitbucketRepositoryEnvironment -RepoSlug 'Repo'
        Gets all environments in the Repo `Repo`.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.
#>
function Get-BitbucketRepositoryEnvironment {
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
        [string]$RepoSlug
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/environments/"
        return Invoke-BitbucketAPI -Path $endpoint -Paginated
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

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

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
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the environment.')]
        [string]$Environment,
        [Parameter( Mandatory=$true,
                    Position=2,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the environment type.')]
        [ValidateSet('Test', 'Staging','Production')]
        [string]$Type,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Rank of the environment.')]
        [string]$Rank = 0
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/environments/"
        $body = [ordered]@{
            type = 'deployment_environment'
            name = $Environment
            rank = $Rank
            environment_type = @{
                type = 'deployment_environment_type'
                name = $Type
            }
            lock = [ordered]@{
                type = 'deployment_environment_lock_open'
                name = 'OPEN'
            }
            restrictions = [ordered]@{
                type = 'deployment_restrictions_configuration'
                admin_only = $false
            }
            hidden = $true
            environment_lock_enabled = $true
        } | ConvertTo-Json -Depth 3 -Compress

        if ($pscmdlet.ShouldProcess("$Environment in $RepoSlug", 'create')){
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

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Environment
        Name of the environment.
#>
function Remove-BitbucketRepositoryEnvironment {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the environment.')]
        [string]$Environment
    )

    Process {
        $_environments = Get-BitbucketRepositoryEnvironment -Team $Team -RepoSlug $RepoSlug
        $_uuid = ($_environments | Where-Object {$_.name -eq $Environment}).uuid

        if($_uuid){
            $endpoint = "repositories/$Team/$RepoSlug/environments/$_uuid"
            if ($pscmdlet.ShouldProcess("$Environment in $RepoSlug", 'delete')){
                return Invoke-BitbucketAPI -Path $endpoint -Method Delete
            }
        }
    }
}