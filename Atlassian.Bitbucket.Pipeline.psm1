using module .\Atlassian.Bitbucket.Authentication.psm1

function Start-BitbucketPipeline {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param (
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [string]$RepoSlug,
        [Parameter( Position=1,
                    ValueFromPipelineByPropertyName=$true)]
        [string]$Branch = 'master',
        [Parameter( Position=2,
                    ValueFromPipelineByPropertyName=$true)]
        [string]$CustomPipe,
        [Parameter( Position=3,
                    ValueFromPipelineByPropertyName=$true)]
        [HashTable[]]$Variables
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/pipelines/"

        # Add selector for custom pipes
        if ($CustomPipe) {
            $body = @{
                target = @{
                    ref_type = 'branch'
                    type     = 'pipeline_ref_target'
                    ref_name = $Branch
                    selector = @{
                        type    = 'custom'
                        pattern = $CustomPipe
                    }
                }
            }
        }else {
            $body = @{
                target = @{
                    ref_type = 'branch'
                    type     = 'pipeline_ref_target'
                    ref_name = $Branch
                }
            }
        }

        # Add variables
        if ($Variables) {
            $body | Add-Member -NotePropertyName variables -NotePropertyValue $Variables
        }

        $body = $body | ConvertTo-Json -Depth 5

        if ($pscmdlet.ShouldProcess('pipeline', 'start'))
        {
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Post
        }
    }
}

function Wait-BitbucketPipeline {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Position=0,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [string]$RepoSlug,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository object from Bitbucket.')]
        $repository,
        [Parameter( Position=1,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [Alias('uuid')]
        [string]$PipelineUUID,
        [int]$SleepSeconds = 10,
        [int]$TimeoutSeconds = 7200
    )

    Process {
        if($repository){
            $RepoSlug = $repository.uuid
        }

        if(!$RepoSlug){
            Throw 'A repo must be provided'
        }

        $endpoint = "repositories/$Team/$RepoSlug/pipelines/$PipelineUUID"
        Write-Progress -Id 0 'Watching pipeline for successful completion...'

        $poll = $true

        do {
            $response = Invoke-BitbucketAPI -Path $endpoint

            if($response.state.name -eq 'COMPLETED'){
                $poll = $false
            }else{
                if($TimeoutSeconds -lt $SleepSeconds){
                    Throw "The $TimeoutSeconds second timeout expired before the pipeline completed."
                }else{
                    Write-Verbose "Pipeline has not completed yet.  Waiting for $SleepSeconds more seconds before re-checking.  $TimeoutSeconds left before timing out."
                    $TimeoutSeconds -= $SleepSeconds
                    Start-Sleep -Seconds $SleepSeconds
                }
            }
        } while ($poll)

        return $response
    }
}