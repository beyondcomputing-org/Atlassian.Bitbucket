using module .\Atlassian.Bitbucket.Authentication.psm1

function Get-BitbucketRepositoryReviewer {
    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug
    )
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/default-reviewers"
        return Invoke-BitbucketAPI -Path $endpoint -Method Get -Paginated
    }
}

function Add-BitbucketRepositoryReviewer {
    [CmdletBinding( SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium')]
    Param (
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
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
            HelpMessage = 'Name of the user to add as a default reviewer.')]
        [string]$Nickname
    )
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/default-reviewers/$Nickname"

        if ($pscmdlet.ShouldProcess($RepoSlug, "Add $Nickname to default reviewers")) {
            $response = Invoke-BitbucketAPI -Path $endpoint -Method Put

            if($response){
                return [pscustomobject]@{
                    Nickname = $Nickname
                    Team     = $Team
                    RepoSlug = $RepoSlug
                    Action   = 'Added'
                }
            }else{
                throw 'Bad Request'
            }
        }
    }
}


function Remove-BitbucketRepositoryReviewer {
    [CmdletBinding( SupportsShouldProcess = $true,
        ConfirmImpact = 'High')]
    Param (
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
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
            HelpMessage = 'Name of the user to be removed as a default reviewer.')]
        [string]$Nickname
    )
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/default-reviewers/$Nickname"

        if ($pscmdlet.ShouldProcess($RepoSlug, "Remove $Nickname from default reviewers")) {
            Invoke-BitbucketAPI -Path $endpoint -Method Delete

            [pscustomobject]@{
                Nickname = $Nickname
                Team     = $Team
                RepoSlug = $RepoSlug
                Action   = 'Deleted'
            }
        }
    }
}

function Set-BitbucketRepositoryReviewer {
    [CmdletBinding( SupportsShouldProcess = $true,
        ConfirmImpact = 'High')]
    Param (
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
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
            HelpMessage = 'Array of users to set as the default reviewers.')]
        [string[]]$Nicknames
    )
    Process {
        $existingUsers = (Get-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug).nickname

        if ($existingUsers.Count -eq 0) {
            foreach ($nickname in $Nicknames) {
                Add-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug -Nickname $nickname
            }
        }
        else {
            # Calculate the delta between existing and expected users
            $delta = Compare-Object -ReferenceObject $existingUsers -DifferenceObject $Nicknames

            # Add missing users
            $missingUsers = ($delta | Where-Object { $_.SideIndicator -eq '=>' }).InputObject

            if ($missingUsers) {
                $missingUsers | Add-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug
            }

            # Remove extra users
            $extraUsers = ($delta | Where-Object { $_.SideIndicator -eq '<=' }).InputObject

            if ($extraUsers) {
                $extraUsers | Remove-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug
            }
        }
    }
}