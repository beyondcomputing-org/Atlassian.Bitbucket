Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'Remove-BitbucketRepositoryBranchRestriction' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { 
        return $null
    }

    $Team = 'T'
    $Repo = 'R'
    $ID = 123
    
    Context 'Remove Branch Restriction' {
        Remove-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -RestrictionID $ID -Confirm:$false

        It 'Uses DELETE Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo/branch-restrictions/$ID"
            }
        }

        It 'Has no body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Body -eq $null
            }
        }
    }

    Context 'Accepts pipeline input' {
        $Restriction = New-Object PSObject -Property @{
            id = 123
        }

        $Restriction | Remove-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -Confirm:$false

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Path -eq "repositories/$Team/$($Repo)/branch-restrictions/$ID"
            }
        }
    }

    Context 'Supports WhatIf' {
        Remove-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -RestrictionID $ID -WhatIf

        It 'Does not call the mock' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -Exactly 0
        }
    }
}