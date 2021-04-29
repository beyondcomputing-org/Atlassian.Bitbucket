Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'New-BitbucketRepositoryBranchRestrictionMergeCheck' {    
    $Kind = 'require_approvals_to_merge'
    $Pattern = 'master'
    $BranchType = 'development'
    $Value = 2

    Context 'Creates Merge Check with Value using Glob Matching' {
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind $Kind -Pattern $Pattern -Value $Value

        It 'Is correct type' {
            $MergeCheck.GetType().Name | Should Be 'MergeCheck'
        }

        It 'Has correct kind' {
            $MergeCheck.kind | Should Be $Kind
        }

        It 'Has correct pattern' {
            $MergeCheck.pattern | Should Be $Pattern
        }

        It 'Has empty branch_type' {
            $MergeCheck.branch_type | Should Be ""
        }

        It 'Has correct value' {
            $MergeCheck.value | Should Be $Value
        }
    }

    Context 'Creates Merge Check with Value using Branching_Model Matching' {
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind $Kind -BranchType $BranchType -Value $Value

        It 'Is correct type' {
            $MergeCheck.GetType().Name | Should Be 'MergeCheck'
        }

        It 'Has correct kind' {
            $MergeCheck.kind | Should Be $Kind
        }

        It 'Has empty pattern' {
            $MergeCheck.pattern | Should Be ""
        }

        It 'Has correct branch_type' {
            $MergeCheck.branch_type | Should Be $BranchType
        }

        It 'Has correct value' {
            $MergeCheck.value | Should Be $Value
        }
    }

    Context 'Creates Merge Check without Value' {
        $MergeCheck = New-BitbucketRepositoryBranchRestrictionMergeCheck -Kind $Kind -Pattern $Pattern -Value $Value

        It 'Has correct kind' {
            $MergeCheck.kind | Should Be $Kind
        }

        It 'Has correct pattern' {
            $MergeCheck.pattern | Should Be $Pattern
        }
    }
}