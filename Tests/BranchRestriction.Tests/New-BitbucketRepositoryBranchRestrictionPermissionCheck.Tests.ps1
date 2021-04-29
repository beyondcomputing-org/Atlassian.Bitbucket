Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'New-BitbucketRepositoryBranchRestrictionPermissionCheck' {
    $Kind = 'push'
    $Pattern = 'master'
    $BranchType = 'development'
    $UUID = '{12a1a123-a1ab-1234-a12a-1abc12345a12}'

    Context 'Creates User Permission Check using Glob Matching' {
        $PermissionCheck = New-BitbucketRepositoryBranchRestrictionPermissionCheck -Kind $Kind -Pattern $Pattern -UUID $UUID

        It 'Is correct type' {
            $PermissionCheck.GetType().Name | Should Be 'PermissionCheck'
        }

        It 'Has correct kind' {
            $PermissionCheck.kind | Should Be $Kind
        }

        It 'Has correct pattern' {
            $PermissionCheck.pattern | Should Be $Pattern
        }

        It 'Has empty branch_type' {
            $PermissionCheck.branch_type | Should Be ""
        }

        It 'Has one user' {
            $PermissionCheck.users.Count | Should Be 1
        }

        It 'Has correct user UUID' {
            $PermissionCheck.users.uuid | Should Be $UUID
        }

        It 'Has empty groups' {
            $PermissionCheck.groups.Count | Should Be 0
        }
    }

    Context 'Creates User Permission Check using branching_model Matching' {
        $PermissionCheck = New-BitbucketRepositoryBranchRestrictionPermissionCheck -Kind $Kind -BranchType $BranchType -UUID $UUID

        It 'Is correct type' {
            $PermissionCheck.GetType().Name | Should Be 'PermissionCheck'
        }

        It 'Has correct kind' {
            $PermissionCheck.kind | Should Be $Kind
        }

        It 'Has correct pattern' {
            $PermissionCheck.pattern | Should Be ""
        }

        It 'Has empty branch_type' {
            $PermissionCheck.branch_type | Should Be $BranchType
        }

        It 'Has one user' {
            $PermissionCheck.users.Count | Should Be 1
        }

        It 'Has correct user UUID' {
            $PermissionCheck.users.uuid | Should Be $UUID
        }

        It 'Has empty groups' {
            $PermissionCheck.groups.Count | Should Be 0
        }
    }

    Context 'Creates Group Permission Check using Glob Matching' {
        $PermissionCheck = New-BitbucketRepositoryBranchRestrictionPermissionCheck -Kind $Kind -Pattern $Pattern -UUID $UUID -IsGroup

        It 'Is correct type' {
            $PermissionCheck.GetType().Name | Should Be 'PermissionCheck'
        }

        It 'Has correct kind' {
            $PermissionCheck.kind | Should Be $Kind
        }

        It 'Has correct pattern' {
            $PermissionCheck.pattern | Should Be $Pattern
        }

        It 'Has empty branch_type' {
            $PermissionCheck.branch_type | Should Be ""
        }

        It 'Has empty users' {
            $PermissionCheck.users.Count | Should Be 0
        }

        It 'Has one group' {
            $PermissionCheck.groups.Count | Should Be 1
        }

        It 'Has correct group UUID' {
            $PermissionCheck.groups.uuid | Should Be $UUID
        }
    }

    Context 'Creates Group Permission Check using branching_model Matching' {
        $PermissionCheck = New-BitbucketRepositoryBranchRestrictionPermissionCheck -Kind $Kind -BranchType $BranchType -UUID $UUID -IsGroup

        It 'Is correct type' {
            $PermissionCheck.GetType().Name | Should Be 'PermissionCheck'
        }

        It 'Has correct kind' {
            $PermissionCheck.kind | Should Be $Kind
        }

        It 'Has correct pattern' {
            $PermissionCheck.pattern | Should Be ""
        }

        It 'Has empty branch_type' {
            $PermissionCheck.branch_type | Should Be $BranchType
        }

        It 'Has empty users' {
            $PermissionCheck.users.Count | Should Be 0
        }

        It 'Has one group' {
            $PermissionCheck.groups.Count | Should Be 1
        }

        It 'Has correct group UUID' {
            $PermissionCheck.groups.uuid | Should Be $UUID
        }
    }
}