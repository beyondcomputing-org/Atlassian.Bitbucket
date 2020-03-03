Import-Module '.\Atlassian.Bitbucket.Repository.GroupPermission.psm1' -Force

Describe 'New-BitbucketRepositoryGroupPermission' {    
    $GroupSlug = 'group-slug'
    $Privilege = 'read'

    Context 'Creates Group Permission' {
        $Permission = New-BitbucketRepositoryGroupPermission -GroupSlug $GroupSlug -Privilege $Privilege

        It 'Is correct type' {
            $Permission.GetType().Name | Should Be 'GroupPermissionV1'
        }

        It 'Has correct kind' {
            $Permission.groupslug | Should Be $GroupSlug
        }

        It 'Has correct pattern' {
            $Permission.privilege | Should Be $Privilege
        }
    }
}