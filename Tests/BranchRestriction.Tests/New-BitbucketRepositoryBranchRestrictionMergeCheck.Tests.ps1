Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'New-BitbucketRepositoryBranchRestrictionMergeCheck' {    
    $Kind = 'require_approvals_to_merge'
    $Pattern = 'master'
    $Value = 2

    Context 'Creates Merge Check with Value' {
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