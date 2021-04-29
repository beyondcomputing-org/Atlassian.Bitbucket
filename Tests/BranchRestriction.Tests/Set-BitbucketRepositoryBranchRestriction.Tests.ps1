Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'Set-BitbucketRepositoryBranchRestriction' {
    Mock Add-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { }
    Mock Remove-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { }

    $Team = 'T'
    $Repo = 'R'
    
    Context 'Matching Glob Restriction' {
        Mock Get-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { 
            return New-Object PSObject -Property @{
                id = 123
                kind = 'require_approvals_to_merge'
                pattern = 'master'
                value = 2
                branch_match_kind = 'glob'
                type = 'branchrestriction'
            } | ConvertTo-BranchRestriction
        }

        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind 'require_approvals_to_merge' -Pattern 'master' -Value 2
        Set-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -Restriction $MergeCheck

        It 'Does not add restriction' {
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
        }

        It 'Does not remove restriction' {
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
        }
    }

    Context 'Matching branching_model Restriction' {
        Mock Get-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { 
            return New-Object PSObject -Property @{
                id = 123
                kind = 'require_approvals_to_merge'
                pattern = ''
                value = 2
                branch_match_kind = 'branching_model'
                branch_type = 'development'
                type = 'branchrestriction'
            } | ConvertTo-BranchRestriction
        }

        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind 'require_approvals_to_merge' -BranchType 'development' -Value 2
        Set-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -Restriction $MergeCheck

        It 'Does not add restriction' {
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
        }

        It 'Does not remove restriction' {
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
        }
    }

    Context 'Mismatched Restriction' {
        $response = New-Object PSObject -Property @{
            id = 123
            kind = 'require_approvals_to_merge'
            pattern = 'production'
            value = 2
            branch_match_kind = 'glob'
            type = 'branchrestriction'
        } | ConvertTo-BranchRestriction
        Mock Get-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { 
            return $response
        }.GetNewClosure()
        
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind 'require_approvals_to_merge' -Pattern 'master' -Value 2
        Set-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -Restriction $MergeCheck

        It 'Adds restriction' {
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Restriction -eq $MergeCheck
            }
        }

        It 'Removes restriction' {
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $RestrictionID -eq $response.id
            }
        }
    }

    Context 'Missing Restriction' {
        Mock Get-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction { 
            return $null
        }
        
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind 'require_approvals_to_merge' -Pattern 'master' -Value 2
        Set-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -Restriction $MergeCheck

        It 'Adds restriction' {
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Restriction -eq $MergeCheck
            }
        }

        It 'Does not remove restriction' {
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
        }
    }

    Context 'Complex Restrictions' {
        $response1 = New-Object PSObject -Property @{
            id = 123
            kind = 'require_approvals_to_merge'
            pattern = 'master'
            value = 2
            branch_match_kind = 'glob'
            type = 'branchrestriction'
        } | ConvertTo-BranchRestriction
    
        $response2 = New-Object PSObject -Property @{
            id = 124
            kind = 'delete'
            pattern = 'master'
            users = @()
            groups = @()
            branch_match_kind = 'glob'
            type = 'branchrestriction'
        } | ConvertTo-BranchRestriction

        Mock Get-BitbucketRepositoryBranchRestriction -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction {
            return @($response1, $response2)
        }.GetNewClosure()
        
        $MergeCheck = @()
        $MergeCheck += New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind $response1.kind -Pattern $response1.pattern -Value $response1.value
        $MergeCheck += New-BitbucketRepositoryBranchRestrictionPermissionCheck -Kind 'push' -BranchType 'hotfix' -UUID '{12a1a123-a1ab-1234-a12a-1abc12345a12}'
        $MergeCheck += New-Object PSObject -Property @{
            id = 124
            kind = 'delete'
            pattern = 'production'
            users = @()
            groups = @()
            branch_match_kind = 'glob'
            type = 'branchrestriction'
        } | ConvertTo-BranchRestriction

        Set-BitbucketRepositoryBranchRestriction -Team $Team -RepoSlug $Repo -Restriction $MergeCheck

        It 'Adds correct restriction' {
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 2 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Restriction -eq $MergeCheck[1]
            }
            Assert-MockCalled Add-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Restriction -eq $MergeCheck[2]
            }
        }

        It 'Removes restriction' {
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction
            Assert-MockCalled Remove-BitbucketRepositoryBranchRestriction -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $RestrictionID -eq $response2.id
            }
        }
    }
}