using module .\Atlassian.Bitbucket.Authentication.psm1
using module .\Atlassian.Bitbucket.Repository.Environment.psm1

function Get-BitbucketRepositoryEnvironmentVariable {
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
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the environment.')]
        [string]$Environment
    )
    Begin {
        Write-Warning 'This functionality uses an internal Bitbucket API.  The functionality required is not present in the Public API.'
        Write-Warning 'Because this is using an internal API it may break in the future and require an update.'
    }

    Process {
        $_environments = Get-BitbucketRepositoryEnvironment -Team $Team -RepoSlug $RepoSlug
        $_uuid = ($_environments | Where-Object {$_.name -eq $Environment}).uuid

        if($_uuid){
            $endpoint = "repositories/$Team/$RepoSlug/deployments_config/environments/$_uuid/variables/"
            return Invoke-BitbucketAPI -Path $endpoint -Paginated -InternalAPI
        }else{
            Throw "Couldn't find the environment: $Environment"
        }
    }
}

function New-BitbucketRepositoryEnvironmentVariable {
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
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the environment.')]
        [string]$Environment,
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Variable key')]
        [string]$Key,
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Variable value')]
        [string]$Value,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Obscure the variable value')]
        [switch]$Secured

    )
    Begin {
        Write-Warning 'This functionality uses an internal Bitbucket API.  The functionality required is not present in the Public API.'
        Write-Warning 'Because this is using an internal API it may break in the future and require an update.'
    }

    Process {
        $_environments = Get-BitbucketRepositoryEnvironment -Team $Team -RepoSlug $RepoSlug
        $_uuid = ($_environments | Where-Object {$_.name -eq $Environment}).uuid

        if($_uuid){
            $body = [ordered]@{
                key = $Key
                secured = $Secured.IsPresent
                value = $Value
            } | ConvertTo-Json -Depth 1 -Compress

            $endpoint = "repositories/$Team/$RepoSlug/deployments_config/environments/$_uuid/variables/"
            if ($pscmdlet.ShouldProcess("$Key in the environment $Environment in the repo $RepoSlug", 'create')){
                return Invoke-BitbucketAPI -Path $endpoint -Method Post -Body $body -InternalAPI
            }
        }else{
            Throw "Couldn't find the environment: $Environment"
        }
    }
}

function Remove-BitbucketRepositoryEnvironmentVariable {
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
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the environment.')]
        [string]$Environment,
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Variable key')]
        [string]$Key
    )
    Begin {
        Write-Warning 'This functionality uses an internal Bitbucket API.  The functionality required is not present in the Public API.'
        Write-Warning 'Because this is using an internal API it may break in the future and require an update.'
    }

    Process {
        $_uuidEnv = (Get-BitbucketRepositoryEnvironment -Team $Team -RepoSlug $RepoSlug | Where-Object {$_.name -eq $Environment}).uuid

        if($_uuidEnv){
            $_uuidVar = (Get-BitbucketRepositoryEnvironmentVariable -Team $Team -RepoSlug $RepoSlug -Environment $Environment | Where-Object {$_.key -eq $Key}).uuid

            if($_uuidVar){
                $endpoint = "repositories/$Team/$RepoSlug/deployments_config/environments/$_uuidEnv/variables/$_uuidVar"
                if ($pscmdlet.ShouldProcess("$Key in the environment $Environment in the repo $RepoSlug", 'delete')){
                    return Invoke-BitbucketAPI -Path $endpoint -Method Delete -InternalAPI
                }
            }
        }else{
            Throw "Couldn't find the environment: $Environment"
        }
    }
}