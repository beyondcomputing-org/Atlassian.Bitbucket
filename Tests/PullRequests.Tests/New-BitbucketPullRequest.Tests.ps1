Import-Module '.\Atlassian.Bitbucket.PullRequest.psm1' -Force

Describe 'New-BitbucketPullRequest' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.PullRequest { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
        }
        return $Response
    }

    $Workspace = 'T'
    $Repo = 'R'
    $Title = 'Title'
    $Source = 'SBranch'
    
    Context 'Create Basic PR' {
        New-BitbucketPullRequest -Workspace $Workspace -RepoSlug $Repo -Title $Title -SourceBranch $Source

        It 'Uses Post Method' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest -ParameterFilter {
                $Path -eq "repositories/$Workspace/$Repo/pullrequests"
            }
        }

        It 'Has a valid body' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest -ParameterFilter {
                ([ordered]@{
                        title               = $Title
                        description         = ''
                        close_source_branch = $true
                        source              = [ordered]@{
                            branch = [ordered]@{
                                name = $Source
                            }
                        }
                        reviewers           = @()
                    } | ConvertTo-Json -Depth 3 -Compress) -eq $Body
            }
        }
    }

    Context 'Adding Optional Fields' {
        $Description = 'Description'
        $Close = $false
        $Destination = 'DBranch'
        $Reviewers = @([PSCustomObject]@{
                uuid = 'testid'
            })

        New-BitbucketPullRequest -Workspace $Workspace -RepoSlug $Repo -Title $Title -SourceBranch $Source -Description $Description -CloseBranch $Close -DestinationBranch $Destination -Reviewers $Reviewers

        It 'Uses Post Method' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest -ParameterFilter {
                $Path -eq "repositories/$Workspace/$Repo/pullrequests"
            }
        }

        It 'Has a valid body' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest -ParameterFilter {
                ([ordered]@{
                        title               = $Title
                        description         = $Description
                        close_source_branch = $Close
                        source              = [ordered]@{
                            branch = [ordered]@{
                                name = $Source
                            }
                        }
                        reviewers           = $Reviewers
                        destination         = @{
                            branch = @{
                                name = $Destination
                            }
                        }
                    } | ConvertTo-Json -Depth 3 -Compress) -eq $Body
            }
        }
    }
}