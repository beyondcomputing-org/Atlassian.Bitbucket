Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'Add-BitbucketRepositoryBranchRestriction' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction {
        $Response = New-Object PSObject -Property @{
            id = (New-Guid).Guid
        }
        return $Response
    }

    $Workspace = 'T'
    $Repo = 'R'

    Context 'Create new Glob based branch restriction' {
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind 'require_approvals_to_merge' -Pattern 'master' -Value 2
        Add-BitbucketRepositoryBranchRestriction -Workspace $Workspace -RepoSlug $Repo -Restriction $MergeCheck

        It 'Uses POST Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Path -eq "repositories/$Workspace/$Repo/branch-restrictions"
            }
        }

        It 'Has a valid body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                ($MergeCheck | Select-Object -ExcludeProperty branch_type | ConvertTo-Json -Depth 2 -Compress) -eq $Body
            }
        }

        It "Removes the branch_type property when branch_match_kind equals 'glob'" {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $null -eq ($Body | ConvertFrom-Json -Depth 3 | Select-Object -ExpandProperty branch_type -ErrorAction Ignore)
            }
        }
    }

    Context 'Create new branch_model based branch restriction' {
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind 'require_approvals_to_merge' -BranchType 'development' -Value 2
        Add-BitbucketRepositoryBranchRestriction -Workspace $Workspace -RepoSlug $Repo -Restriction $MergeCheck

        It 'Uses POST Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                $Path -eq "repositories/$Workspace/$Repo/branch-restrictions"
            }
        }

        It 'Has a valid body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchRestriction -ParameterFilter {
                ($MergeCheck | ConvertTo-Json -Depth 2 -Compress) -eq $Body
            }
        }
    }
}