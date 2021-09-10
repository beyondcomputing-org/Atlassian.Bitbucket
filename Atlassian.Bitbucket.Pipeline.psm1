using module .\Atlassian.Bitbucket.Authentication.psm1

function Enable-BitbucketPipelineConfig {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
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
        [string]$RepoSlug
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/pipelines_config"

        $body = @{
            enabled = $true
        } | ConvertTo-Json -Depth 1 -Compress

        if ($pscmdlet.ShouldProcess("pipelines on repo $RepoSlug", 'enable')) {
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Put
        }
    }
}

function Get-BitbucketPipelineConfig {
    param (
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
        [string]$RepoSlug
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/pipelines_config"

        return Invoke-BitbucketAPI -Path $endpoint -Method Get
    }
}

function Start-BitbucketPipeline {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
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
        [Parameter( Position = 1,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Branch = 'master',
        [Parameter( Position = 2,
            ValueFromPipelineByPropertyName = $true)]
        [string]$CustomPipe,
        [Parameter( Position = 3,
            ValueFromPipelineByPropertyName = $true)]
        [HashTable[]]$Variables
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/pipelines/"

        # Add selector for custom pipes
        if ($CustomPipe) {
            $body = [ordered]@{
                target = [ordered]@{
                    type     = 'pipeline_ref_target'
                    ref_type = 'branch'
                    ref_name = $Branch
                    selector = [ordered]@{
                        type    = 'custom'
                        pattern = $CustomPipe
                    }
                }
            }
        }
        else {
            $body = [ordered]@{
                target = [ordered]@{
                    type     = 'pipeline_ref_target'
                    ref_type = 'branch'
                    ref_name = $Branch
                }
            }
        }

        # Add variables
        if ($Variables) {
            $body | Add-Member -NotePropertyName variables -NotePropertyValue $Variables
        }

        $body = $body | ConvertTo-Json -Depth 5 -Compress

        if ($pscmdlet.ShouldProcess('pipeline', 'start')) {
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Post
        }
    }
}

function Wait-BitbucketPipeline {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Position = 0,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository object from Bitbucket.')]
        $repository,
        [Parameter( Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('uuid')]
        [string]$PipelineUUID,
        [int]$SleepSeconds = 10,
        [int]$TimeoutSeconds = 7200
    )

    Process {
        if ($repository) {
            $RepoSlug = $repository.uuid
        }

        if (!$RepoSlug) {
            Throw 'A repo must be provided'
        }

        $endpoint = "repositories/$Workspace/$RepoSlug/pipelines/$PipelineUUID"
        Write-Progress -Id 0 'Watching pipeline for successful completion...'

        $poll = $true

        do {
            $response = Invoke-BitbucketAPI -Path $endpoint

            if ($response.state.name -eq 'COMPLETED') {
                $poll = $false
            }
            elseif($response.state.name -in ('PENDING', 'IN_PROGRESS') -and $response.state.stage.name -in ('PAUSED', 'HALTED')){
                Throw "The triggered pipeline was $($response.state.stage.name).  Failing Build!!"
            }
            else {
                if ($TimeoutSeconds -lt $SleepSeconds) {
                    Throw "The $TimeoutSeconds second timeout expired before the pipeline completed."
                }
                else {
                    Write-Verbose "Pipeline has not completed yet.  Waiting for $SleepSeconds more seconds before re-checking.  $TimeoutSeconds left before timing out."
                    $TimeoutSeconds -= $SleepSeconds
                    Start-Sleep -Seconds $SleepSeconds
                }
            }
        } while ($poll)

        return $response
    }
}

<#
    .SYNOPSIS
        Get pipeline details

    .DESCRIPTION
        Returns details for all returned pipelines.  A specific pipeline can be specified by UUID or build number.

    .EXAMPLE
        C:\PS> Get-BitbucketPipeline -Workspace 'MyWorkspace' -RepoSlug 'my.repo'
        # Returns details for the last 20 pipeline run in 'my.repo'

    .EXAMPLE
        C:\PS> Get-BitbucketPipeline -Workspace 'MyWorkspace' -RepoSlug 'my.repo' -UUID '{d9448101-f9f3-4024-bda8-c412cb17654a}'
        # Returns details for the pipeline with the provided UUID - Note that the UUID will take the pipeline build number as well

    .PARAMETER Workspace
        Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.

    .PARAMETER Repo
        The repo slug.

    .PARAMETER UUID
        Either the unique ID of a pipeline or a pipeline build number. If provided only returns results for the pipeline specified.

    .PARAMETER State
        The state of the pipeline.  If provided, filters results to pipelines with the specified state.

    .PARAMETER Sort
        The property to sort pipelines on prior to returning results.  Deafults to created_on.

    .PARAMETER Page
        The page number of results to return.  Defaults to 1.

    .PARAMETER Limit
        The number of results to return per page.  Defaults to 20.  Maximum is 100.
#>

function Get-BitbucketPipeline {
    param (
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [Alias('Id')]
        [string]$UUID,
        [string]$State,
        [string]$Sort = '-created_on',
        [int]$Page = 1,
        [int]$Limit = 20
    )

    Process {
        $endpoint = "repositories/$Workspace/$RepoSlug/pipelines/"
        if ($UUID) {
            $endpoint += "$UUID"
            return @(Invoke-BitbucketAPI -Path $endpoint -Method Get)
        }
        else {
            $endpoint += "?&sort=$Sort&page=$Page&pagelen=$Limit"
            if ($State) {
                $endpoint += "&status=$($State.ToUpper())"
            }
            return (Invoke-BitbucketAPI -Path $endpoint -Method Get).values
        }

    }
}

<#
    .SYNOPSIS
        Get pipeline step details

    .DESCRIPTION
        Returns details for all returned pipeline steps.  A specific pipeline step can be specified by UUID.

    .EXAMPLE
        C:\PS> Get-BitbucketPipelineStep -Workspace 'MyWorkspace' -RepoSlug 'my.repo' -PipelineUUID '{d9448101-f9f3-4024-bda8-c412cb17654a}'
        # Returns details for the steps in the pipeline specified

    .EXAMPLE
        C:\PS> Get-BitbucketPipelineStep -Workspace 'MyWorkspace' -RepoSlug 'my.repo' -PipelineUUID '{d9448101-f9f3-4024-bda8-c412cb17654a}' -UUID 'ea664fec-5cc2-4eb6-b864-aa604a2e3918
'
        # Returns details for the pipeline step with the provided UUID

    .PARAMETER Workspace
        Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.

    .PARAMETER Repo
        The repo slug.

    .PARAMETER PipelineUUID
        Either the unique ID of a pipeline or a pipeline build number. If provided only returns results for the pipeline specified.

    .PARAMETER UUID
        The unique ID of a pipeline step. If provided only returns results for the pipeline step specified.
#>
function Get-BitbucketPipelineStep {
  param (
      [Parameter( ValueFromPipelineByPropertyName = $true,
          HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
      [string]$Workspace = (Get-BitbucketSelectedWorkspace),
      [Parameter( Mandatory = $true,
          Position = 0,
          ValueFromPipeline = $true,
          ValueFromPipelineByPropertyName = $true,
          HelpMessage = 'The repository slug.')]
      [Alias('Slug')]
      [string]$RepoSlug,
      [Parameter( Mandatory = $true,
          ValueFromPipelineByPropertyName = $true,
          Position = 1)]
      [string]$PipelineUUID,
      [Parameter( ValueFromPipeline = $true,
          ValueFromPipelineByPropertyName = $true,
          Position = 2)]
      [Alias('Id')]
      [string]$UUID
  )

  Process {
      $endpoint = "repositories/$Workspace/$RepoSlug/pipelines/$PipelineUUID/steps/$UUID`?pagelen=100"
      return (Invoke-BitbucketAPI -Path $endpoint -Method Get).values
  }
}