Import-Module '.\Atlassian.Bitbucket.Repository.BranchRestriction.psm1' -Force

Describe 'ConvertTo-BranchRestriction MergeCheck' {
    $kinds = @(
        'enforce_merge_checks',
        'require_approvals_to_merge',
        'require_default_reviewer_approvals_to_merge',
        'require_passing_builds_to_merge',
        'require_tasks_to_be_completed',
        'reset_pullrequest_approvals_on_change'
    )

    foreach ($kind in $kinds) {
        Context $kind {
            $Restriction = New-Object PSObject -Property @{
                id = 123
                kind = $kind
                pattern = 'master'
                value = 2
                branch_match_kind = 'glob'
                type = 'branchrestriction'
            }
            $MergeCheck = $Restriction | ConvertTo-BranchRestriction
    
            It 'Is correct object type' {
                $MergeCheck.GetType().Name | Should Be 'MergeCheck'
            }
    
            It 'Has correct property value for field id' {
                $MergeCheck.id | Should Be $Restriction.id
            }
    
            It 'Has correct property value for field kind' {
                $MergeCheck.kind | Should Be $Restriction.kind
            }
    
            It 'Has correct property value for field pattern' {
                $MergeCheck.pattern | Should Be $Restriction.pattern
            }
    
            It 'Has correct property value for field value' {
                $MergeCheck.value | Should Be $Restriction.value
            }
    
            It 'Has correct property value for field branch_match_kind' {
                $MergeCheck.branch_match_kind | Should Be $Restriction.branch_match_kind
            }
    
            It 'Has correct property value for field type' {
                $MergeCheck.type | Should Be $Restriction.type
            }
        }
    }
}

Describe 'ConvertTo-BranchRestriction PermissionCheck' {
    $kinds = @(
        'delete',
        'force',
        'push',
        'restrict_merges'
    )

    foreach ($kind in $kinds) {
        Context $kind {
            $Restriction = New-Object PSObject -Property @{
                id = 123
                kind = $kind
                pattern = 'master'
                users = @()
                groups = @()
                branch_match_kind = 'glob'
                type = 'branchrestriction'
            }
            $Check = $Restriction | ConvertTo-BranchRestriction
    
            It 'Is correct object type' {
                $Check.GetType().Name | Should Be 'PermissionCheck'
            }
    
            It 'Has correct property value for field id' {
                $Check.id | Should Be $Restriction.id
            }
    
            It 'Has correct property value for field kind' {
                $Check.kind | Should Be $Restriction.kind
            }
    
            It 'Has correct property value for field pattern' {
                $Check.pattern | Should Be $Restriction.pattern
            }
    
            It 'Has correct property value for field users' {
                $Check.users | Should Be $Restriction.users
            }

            It 'Has correct property value for field groups' {
                $Check.groups | Should Be $Restriction.groups
            }
    
            It 'Has correct property value for field branch_match_kind' {
                $Check.branch_match_kind | Should Be $Restriction.branch_match_kind
            }
    
            It 'Has correct property value for field type' {
                $Check.type | Should Be $Restriction.type
            }
        }
    }
}