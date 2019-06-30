using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns pull requests against a repository.

    .DESCRIPTION
        Returns all the pull requests in the specified state against the repository.  Defaults to PR's in an OPEN state.

    .EXAMPLE
        C:\PS> Get-BitbucketPullRequest -RepoSlug 'Repo'
        Returns all open PR's against the `Repo` repository.

    .EXAMPLE
        C:\PS> Get-BitbucketPullRequest -RepoSlug 'Repo' -State 'MERGED'
        Returns all merged PR's against the `Repo` repository.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER State
        State of the PR. Options: ['OPEN', 'MERGED', 'SUPERSEDED', 'DECLINED']
#>
function Get-BitbucketPullRequest {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [string]$RepoSlug,
        [Parameter( ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The state of the PR.  Defaults to OPEN')]
        [ValidateSet('OPEN', 'MERGED', 'SUPERSEDED', 'DECLINED')]
        [string]$State = 'OPEN'
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/pullrequests"

        # To Do - Add Filtering as needed https://developer.atlassian.com/bitbucket/api/2/reference/meta/filtering#query-pullreq
        # Most Repos have small sets of PR's so client side will work for now until a use case comes up besides state.
        if($State)
        {
            $endpoint += "?q=state=%22$State%22"
        }

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}

<#
    .SYNOPSIS
        Creates a pull request against a repository.

    .DESCRIPTION
        Creates a pull request against a repository.

    .EXAMPLE
        C:\PS> New-BitbucketPullRequest -RepoSlug 'Repo' -Title 'PR Title' -SourceBranch 'BranchName'
        Creates a new PR against the `Repo` repository from BranchName to the repositories main branch.

    .EXAMPLE
        C:\PS> New-BitbucketPullRequest -RepoSlug 'Repo' -Title 'Markdown' -SourceBranch 'BranchName' -Description "# Heading1 `n * Item1 `n * Item2"
        Creates a PR with markdown in the Description.  Includes an h1 heading and bullet items.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Title
        Title of the PR.

    .PARAMETER SourceBranch
        The source branch for the PR.

    .PARAMETER Description
        Description for the PR.  Supports Markdown.

    .PARAMETER CloseBranch
        Specifies if the source branch should be closed when the PR is merged.  Defaults to True.

    .PARAMETER DestinationBranch
        The destination branch for the PR.  Defaults to the repositories main branch specified in Bitbucket.
#>
function New-BitbucketPullRequest {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory = $true,
                    Position = 0,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The repository slug.')]
        [string]$RepoSlug,
        [Parameter( Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'Title of the PR.')]
        [string]$Title,
        [Parameter( Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The source branch for the PR.')]
        [string]$SourceBranch,
        [Parameter( ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'Description for the PR.')]
        [string]$Description,
        [Parameter( ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'Should the source branch be closed after PR is merged.  Defaults to True.')]
        [bool]$CloseBranch = $true,
        [Parameter( ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The destination branch for the PR.  Defaults to the repositories main branch specified in Bitbucket.')]
        [string]$DestinationBranch
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/pullrequests"

        $body = [ordered]@{
            title =  $Title
            description = $Description
            close_source_branch = $CloseBranch
            source = [ordered]@{
                branch = [ordered]@{
                    name = $SourceBranch
                }
            }
        }

        if($DestinationBranch){
            $body += [ordered]@{
                destination = @{
                    branch = @{
                        name = $DestinationBranch
                    }
                }
            }
        }

        $body = $body | ConvertTo-Json -Depth 3 -Compress

        if ($pscmdlet.ShouldProcess($RepoSlug, 'Create pull request')){
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Post
        }
    }
}