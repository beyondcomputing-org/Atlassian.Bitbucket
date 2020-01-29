using module .\Atlassian.Bitbucket.Authentication.psm1

function Get-BitbucketRepositoryVariable {
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
        [string]$RepoSlug
    )
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/pipelines_config/variables/"
        return (Invoke-BitbucketAPI -Path $endpoint).values
    }
}

function New-BitbucketRepositoryVariable {
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
        [string]$Key,
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Variable value')]
        [string]$Value,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Obscure the variable value')]
        [switch]$Secured

    )
    Process {
        $body = [ordered]@{
            key = $Key
            secured = $Secured.IsPresent
            value = $Value
        } | ConvertTo-Json -Depth 1 -Compress

        $endpoint = "repositories/$Team/$RepoSlug/pipelines_config/variables/"
        if ($pscmdlet.ShouldProcess("$Key in the repo $RepoSlug", 'create')){
            return Invoke-BitbucketAPI -Path $endpoint -Method Post -Body $body
        }
    }
}

function Remove-BitbucketRepositoryVariable {
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
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Variable key')]
        [string]$Key
    )
    Process {
        $_uuidVar = (Get-BitbucketRepositoryVariable -Team $Team -RepoSlug $RepoSlug | Where-Object {$_.key -eq $Key}).uuid
        if($_uuidVar){
            $endpoint = "repositories/$Team/$RepoSlug/pipelines_config/variables/$_uuidVar"
            if ($pscmdlet.ShouldProcess("$Key in the repo $RepoSlug", 'delete')){
                return Invoke-BitbucketAPI -Path $endpoint -Method Delete
            }
        }
    }
}