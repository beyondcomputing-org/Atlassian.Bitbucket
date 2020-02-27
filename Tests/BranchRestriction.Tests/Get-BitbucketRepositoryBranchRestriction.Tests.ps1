Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'Get-BitbucketRepositoryBranchRestriction' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { 
        $Response = New-Object PSObject -Property @{
            id = 123
            kind = 'delete'
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'
    
    Context 'Get restrictions' {
        Get-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo

        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Method -eq $null
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo/branch-restrictions/"
            }
        }

        It 'Has no body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Is paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Paginated -eq $true
            }
        }
    }
}