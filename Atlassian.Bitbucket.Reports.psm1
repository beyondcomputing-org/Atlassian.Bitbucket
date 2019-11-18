using module .\Atlassian.Bitbucket.Repository.psm1
using module .\Atlassian.Bitbucket.Repository.Deployment.psm1
using module .\Atlassian.Bitbucket.Repository.Environment.psm1

<#
    .SYNOPSIS
        Build a report of deployments for all repos in a project

    .DESCRIPTION
        Build a report of deployments for all repos in a project

    .EXAMPLE
        C:\PS> Get-BitbucketRepository -ProjectKey 'KEY' | Get-BitbucketProjectDeploymentReport
        # Get the JSON report

    .EXAMPLE
        C:\PS> Get-BitbucketRepository -ProjectKey 'ZEUS' | Get-BitbucketProjectDeploymentReport -Format HTML | Out-File C:\Temp\report.html
        # Generate and save the HTML report.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER Repo
        Repos used to build the report.  Pipeline in input from Get-BitbucketRepository.

    .PARAMETER Environments
        The environments used to generate the deployment report.

    .PARAMETER Format
        Return the report in JSON or HTML format.
#>
function Get-BitbucketProjectDeploymentReport {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    ValueFromPipeline=$true,
                    HelpMessage='Repos used to build the report.  Use the Get-BitbucketRepo command.')]
        $Repo,
        [string[]]$Environments = ('Test', 'Staging', 'Production'),
        [ValidateSet('JSON', 'HTML')]
        [string]$Format = 'JSON'
    )
    Begin{
        $content = @()
        $_repos = @()
    }
    Process{
        $_repos += $Repo
    }
    End{
        for ($r = 0; $r -lt $_repos.Count; $r++) {
            $_repo = $_repos[$r]
            Write-Progress -Id 0 -Activity "Getting Deployments for Repo: $($_repo.name)" -PercentComplete ((($r + 1) / $_repos.Count)*100)
            $_env = Get-BitbucketRepositoryEnvironment -RepoSlug $_repo.slug | Where-Object {$_.Name -in $Environments}

            $envList = @()

            for ($e = 0; $e -lt $_env.Count; $e++) {
                Write-Progress -Id 1 -Activity "Environment: $($_env[$e].name)" -PercentComplete ((($e + 1) / $_env.Count)*100)
                $Fields = ('values.deployable.commit.message', 'values.deployable.commit.date', 'values.deployable.commit.author.user')
                $deployment = Get-BitbucketRepositoryDeployment -RepoSlug $_repo.slug -EnvironmentUUID $_env[$e].uuid -Limit 1 -Fields $Fields

                if($deployment){
                    $envList += [PSCustomObject]@{
                        EnvironmentName = $_env[$e].name
                        State = $deployment.state.name
                        Status = $deployment.state.status.name
                        Commit = [PSCustomObject]@{
                            Hash = $deployment.deployable.commit.hash
                            Message = $deployment.deployable.commit.message
                            Date = $deployment.deployable.commit.date
                            Author = [PSCustomObject]@{
                                User = [PSCustomObject]@{
                                    DisplayName = $deployment.deployable.commit.author.user.display_name
                                }
                            }
                        }
                        Pipeline = $deployment.release.name
                        URL = $deployment.release.url
                        Time = $deployment.last_update_time
                    }
                }
            }

            $content += [PSCustomObject]@{
                RepoName = $_repo.name
                Environments = $envList
            }
        }

        switch ($Format) {
            'HTML' {
                return Get-BitbucketProjectDeploymentReportHTML -Environments $Environments -Content $Content
            }
            Default {
                return $content
            }
        }
    }
}

function Get-BitbucketProjectDeploymentReportHTML {
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [string[]]$Environments = ('Dev','Test', 'Staging', 'Production'),
        $Content
    )

    $HTMLReport = Get-Content "$PSScriptRoot\Templates\DeploymentReport.html"
    $HTMLRow = Get-Content "$PSScriptRoot\Templates\DeploymentReportRow.html"
    $HTMLCell = Get-Content "$PSScriptRoot\Templates\DeploymentReportCell.html"

    $rowID = 1
    $rows = @()

    # Build each row
    foreach ($repo in $content) {
        # Build each Cell
        $cells = @()
        $previous = -1

        foreach ($env in $Environments) {
            $deployment = $repo.environments | Where-Object {$_.EnvironmentName -eq $env}

            # Attempt to grab the pipeline run
            [int]$current = 0
            if($deployment){
                [int]::TryParse($deployment.Pipeline.Replace('#',''), [ref]$current) | Out-Null
            }

            if($previous -ne -1){
                if($previous -gt $current){
                    $cells += '<div class="compare gt">&gt;</div>'
                }elseif($previous -eq $current){
                    $cells += '<div class="compare">=</div>'
                }else{
                    $cells += '<div class="compare lt">&lt;</div>'
                }
            }

            $previous = $current

            if($deployment){
                # Calculate Status
                if($deployment.State -eq 'COMPLETED'){
                    $status = $deployment.Status
                }else{
                    $status = $deployment.State
                }

                $cells += $HTMLCell.
                    Replace('##ROW_ID##', $rowID).
                    Replace('##ENVIRONMENT_NAME##', $env).
                    Replace('##STATUS##',$status).
                    Replace('##URL##',$deployment.URL).
                    Replace('##PIPELINE##',$deployment.Pipeline).
                    Replace('##COMMIT_HASH##',$deployment.Commit.Hash.Substring(0,7)).
                    Replace('##COMMIT_MESSAGE##', $deployment.Commit.Message).
                    Replace('##TIME##',$deployment.Time)
            }else{
                $cells += $HTMLCell.
                    Replace('##ROW_ID##', $rowID).
                    Replace('##ENVIRONMENT_NAME##', $env).
                    Replace('##STATUS##', 'BLANK').
                    Replace('##URL##', '').
                    Replace('##PIPELINE##', '').
                    Replace('##COMMIT_HASH##', '').
                    Replace('##COMMIT_MESSAGE##', '').
                    Replace('##TIME##', '')
            }
        }
        $rows += $HTMLRow.
            Replace('##ROW_ID##', $rowID).
            Replace('##REPO##', $repo.RepoName).
            Replace('##CELLS##', $cells)

        $rowID += 1
    }

    return $HTMLReport.
        Replace('##DATE##', (Get-Date).ToString()).
        Replace('##ROWS##', $rows)
}