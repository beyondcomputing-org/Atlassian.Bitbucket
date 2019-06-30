Import-Module '.\Atlassian.Bitbucket.PullRequest.Comment.psm1' -Force

Describe 'New-BitbucketPullRequestComment' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.PullRequest.Comment { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'
    $ID = 1
    $Comment = 'Comment'
    
    Context 'Create plain comment' {
        New-BitbucketPullRequestComment -Team $Team -RepoSlug $Repo -PullRequestID $ID -Comment $Comment

        It 'Uses Post Method' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest.Comment -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest.Comment -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo/pullrequests/$ID/comments"
            }
        }

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -Exactly 1 -ModuleName Atlassian.Bitbucket.PullRequest.Comment -ParameterFilter {
                ([ordered]@{
                    content = [ordered]@{
                        raw =  $Comment
                    }
                } | ConvertTo-Json -Depth 3 -Compress) -eq $Body
            }
        }
    }
}