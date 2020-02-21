Import-Module '.\Atlassian.Bitbucket.Repository.Reviewer.psm1' -Force

Describe 'Set-BitbucketRepositoryReviewer' {
    $SpecifiedTeam = 'T'
    $SpecifiedRepoSlug = 'R'
    $SpecifiedUUID = 'fake1'

    Mock Get-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer { }
    Mock Add-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer { }
    Mock Remove-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer { }

    Context 'No default reviewers exist' {
        Set-BitbucketRepositoryReviewer -RepoSlug $SpecifiedRepoSlug -Team $SpecifiedTeam -UUIDs $SpecifiedUUID

        It 'Adds the specified user to the specified repo' {
            Assert-MockCalled Add-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer -ParameterFilter {
                $UUID -eq $SpecifiedUUID -and $SpecifiedRepoSlug -eq $RepoSlug -and $SpecifiedTeam -eq $Team
            }
        }
    }
        
    Context 'Specified user not a default reviewer' {
        # If a user already a default reviewer, they shouldn't be re-added. Only new users are added.
        $SpecifiedUUID = 'fake1', 'fake2'
        Mock Get-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer {
            [array]$ExistingUsers = [PSCustomObject] @{
                uuid = 'fake1'
            }
            return $ExistingUsers
        }

        Set-BitbucketRepositoryReviewer -RepoSlug $SpecifiedRepoSlug -Team $SpecifiedTeam -UUIDs $SpecifiedUUID

        It 'Only adds the expected user to the specified repo' {
            Assert-MockCalled Add-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer -ParameterFilter {
                $UUID -eq 'fake2' -and $SpecifiedRepoSlug -eq $RepoSlug -and $SpecifiedTeam -eq $Team
            }
            Assert-MockCalled Add-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer -Exactly 1
        }
    }

    Context 'Remove user from default reviewers' {
        # If a user is already a default reviewer, they should be removed. Only the users 
        $SpecifiedUUID = 'fake1'
        Mock Get-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer {
            [array]$ExistingUsers = [PSCustomObject] @{
                uuid = 'fake1', 'fake2'
            }
            return $ExistingUsers
        }
        Set-BitbucketRepositoryReviewer -RepoSlug $SpecifiedRepoSlug -Team $SpecifiedTeam -UUIDs $SpecifiedUUID

        It 'Only removes the extra user from the specified repo' {
            Assert-MockCalled Remove-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer -ParameterFilter {
                $UUID -eq 'fake2' -and $SpecifiedRepoSlug -eq $RepoSlug -and $SpecifiedTeam -eq $Team
            }
            Assert-MockCalled Remove-BitbucketRepositoryReviewer -ModuleName Atlassian.Bitbucket.Repository.Reviewer -Exactly 1
        }
    }
}