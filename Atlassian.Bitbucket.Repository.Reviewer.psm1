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
            HelpMessage = 'The uuid of the user to add as a default reviewer.')]
        [string]$UUID
    )
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/default-reviewers/$UUID"

        if ($pscmdlet.ShouldProcess($RepoSlug, "Add $UUID to default reviewers")) {
            $response = Invoke-BitbucketAPI -Path $endpoint -Method Put

            if ($response) {
                return [pscustomobject]@{
                    UUID     = $UUID
                    Team     = $Team
                    RepoSlug = $RepoSlug
                    Action   = 'Added'
                }
            }
            else {
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
            HelpMessage = 'The uuid of the user to be removed as a default reviewer.')]
        [string]$UUID
    )
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/default-reviewers/$UUID"

        if ($pscmdlet.ShouldProcess($RepoSlug, "Remove $UUID from default reviewers")) {
            Invoke-BitbucketAPI -Path $endpoint -Method Delete

            [pscustomobject]@{
                UUID     = $UUID
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
            ValueFromPipeline = $true,
            HelpMessage = 'Array of users to set as the default reviewers.')]
        [string[]]$UUIDs
    )
    Process {
        $existingUsers = Get-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug

        if ($existingUsers.Count -eq 0) {
            foreach ($uuid in $UUIDs) {
                Add-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug -UUID $uuid
            }
        }
        else {
            # Calculate the delta between existing and expected users
            $delta = Compare-Object -ReferenceObject $existingUsers.uuid -DifferenceObject $UUIDs

            # Add missing users
            $missingUsers = ($delta | Where-Object { $_.SideIndicator -eq '=>' }).InputObject

            if ($missingUsers) {
                foreach ($missingUser in $missingUsers) {
                    Add-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug -UUID $missingUser
                }
            }

            # Remove extra users
            $extraUsers = ($delta | Where-Object { $_.SideIndicator -eq '<=' }).InputObject

            if ($extraUsers) {
                foreach ($extraUser in $extraUsers) {
                    Remove-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug -UUID $extraUser
                }
            }
        }
    }
}