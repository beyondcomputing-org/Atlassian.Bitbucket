using module .\Atlassian.Bitbucket.Repository.psm1
using module .\Atlassian.Bitbucket.Repository.Deployment.psm1
using module .\Atlassian.Bitbucket.Repository.Environment.psm1

<#
    .SYNOPSIS
        Build a report of deployments for all repos in a project

    .DESCRIPTION
        Build a report of deployments for all repos in a project

    .EXAMPLE
        C:\PS> Get-BitbucketProjectDeploymentReport -ProjectKey 'Key'
        # Get the JSON report

    .EXAMPLE
        C:\PS> Get-BitbucketProjectDeploymentReport -ProjectKey 'Key' -Format HTML | Out-File C:\Temp\report.html
        # Generate and save the HTML report.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER ProjectKey
        Project key in Bitbucket

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
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Project key in Bitbucket')]
        [string]$ProjectKey,
        [string[]]$Environments = ('Test', 'Staging', 'Production'),
        [ValidateSet('JSON', 'HTML')]
        [string]$Format = 'JSON'
    )

    Write-Progress -Id 0 -Activity "Getting repos in project $ProjectKey"
    $repos = Get-BitbucketRepository -ProjectKey $ProjectKey

    $content = @()

    for ($r = 0; $r -lt $repos.Count; $r++) {
        $repo = $repos[$r]
        Write-Progress -Id 0 -Activity "Getting Deployments for Repo: $($repo.name)" -PercentComplete ((($r + 1) / $repos.Count)*100)
        $_env = Get-BitbucketRepositoryEnvironment -RepoSlug $repo.slug | Where-Object {$_.Name -in $Environments}

        $envList = @()

        for ($e = 0; $e -lt $_env.Count; $e++) {
            Write-Progress -Id 1 -Activity "Environment: $($_env[$e].name)" -PercentComplete ((($e + 1) / $_env.Count)*100)
            $deployment = Get-BitbucketRepositoryDeployment -RepoSlug $repo.slug -EnvironmentUUID $_env[$e].uuid -Limit 1

            if($deployment){
                $envList += [PSCustomObject]@{
                    EnvironmentName = $_env[$e].name
                    State = $deployment.State.Name
                    Commit = $deployment.release.commit.hash
                    Pipeline = $deployment.release.name
                    URL = $deployment.release.url
                    Time = $deployment.last_update_time
                }
            }
        }

        $content += [PSCustomObject]@{
            RepoName = $repo.name
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

function Get-BitbucketProjectDeploymentReportHTML {
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [string[]]$Environments = ('Dev','Test', 'Staging', 'Production'),
        $Content
    )

$HTML = @'
<!DOCTYPE html>
<html>
<head>
<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

td {
    background-color: red;
}

td.HEADER {
    background-color: #dddddd;
}

td.COMPLETED {
    background-color: rgb(54, 179, 126);
}

td.IN_PROGRESS {
    background-color: yellow;
}

td.UNDEPLOYED {
    background-color: gray;
}

td.BLANK {
    background-color: White;
}

</style>
</head>
<body>
<h2>Deployment Report</h2>
<table>
    <tr>
        <th>Repo</th> ##HEADER##
    </tr>
    ##TABLEROWS##
</table>
</body>
</html>
'@

    $header = @()
    foreach ($Environment in $Environments) {
        $header += "<th>$Environment</th>"
    }

    $tableRows = @()
    foreach ($repo in $content) {
        $row = "<tr><td Class='HEADER'>$($repo.RepoName)</td>"

        foreach ($env in $Environments) {
            $deployment = $repo.environments | Where-Object {$_.EnvironmentName -eq $env}
            if($deployment){
                $row += "<td Class='$($deployment.State)'><a href='$($deployment.URL)'>$($deployment.Pipeline)</a><br/>$($deployment.Commit.Substring(0,7))...<br/>$($deployment.Time)</td>"
            }else{
                $row += '<td Class="BLANK"></td>'
            }
        }
        $row += '</tr>'

        $tableRows += $row
    }

    $HTML = $HTML.Replace('##HEADER##', $header)
    $HTML = $HTML.Replace('##TABLEROWS##', $tableRows)

    return $HTML
}