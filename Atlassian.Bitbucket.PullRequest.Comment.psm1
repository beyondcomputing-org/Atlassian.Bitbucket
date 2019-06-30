using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns all the comments in a pull request.

    .DESCRIPTION
        Returns all the comments in a pull request.

    .EXAMPLE
        C:\PS> Get-BitbucketPullRequestComment -RepoSlug 'Repo' -PullRequestID 1
        Returns all the comments on PR 1 in the `Repo` repository

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER PullRequestID
        The ID of the pull request in the repository.
#>
function Get-BitbucketPullRequestComment {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory = $true,
                    Position = 0,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The repository slug.')]
        [string]$RepoSlug,
        [Parameter( Mandatory = $true,
                    Position = 1,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The ID of the Pull Request')]
        [Alias('ID')]
        [string]$PullRequestID
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/pullrequests/$PullRequestID/comments"

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}

<#
    .SYNOPSIS
        Creates a new comment on a pull request.

    .DESCRIPTION
        Creates a new comment on a pull request and supports markdown.

    .EXAMPLE
        C:\PS> New-BitbucketPullRequestComment -RepoSlug 'Repo' -PullRequestID 1 -Comment 'Comment Text'
        Creates a new comment against the PR as the authenticated user.

    .EXAMPLE
        C:\PS> New-BitbucketPullRequestComment -RepoSlug 'Repo' -PullRequestID 1 -Comment "# Heading1 `n * Item1 `n * Item2"
        Creates a new comment with markdown against the PR as the authenticated user.  Includes an h1 heading and bullet items.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER PullRequestID
        The ID of the pull request in the repository.

    .PARAMETER Comment
        The text to use in the comment.  Supports Markdown.
#>
function New-BitbucketPullRequestComment {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory = $true,
                    Position = 0,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The repository slug.')]
        [string]$RepoSlug,
        [Parameter( Mandatory = $true,
                    Position = 1,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The ID of the Pull Request')]
        [Alias('ID')]
        [string]$PullRequestID,
        [Parameter( Mandatory = $true,
                    Position = 2,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'Comment to add to the Pull Request.  Supports Markdown for formatting.')]
        [string]$Comment
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/pullrequests/$PullRequestID/comments"

        $body = [ordered]@{
            content = [ordered]@{
                raw =  $Comment
            }
        } | ConvertTo-Json -Depth 2 -Compress

        if ($pscmdlet.ShouldProcess("PR $PullRequestID in $RepoSlug", 'create pull request comment')){
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Post
        }
    }
}