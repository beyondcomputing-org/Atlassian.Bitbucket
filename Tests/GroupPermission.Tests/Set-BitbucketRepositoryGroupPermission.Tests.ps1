using module .\..\..\Classes\Atlassian.Bitbucket.Permissions.psm1

Import-Module '.\Atlassian.Bitbucket.Repository.GroupPermission.psm1' -Force

Describe 'Set-BitbucketRepositoryGroupPermission' {
    Mock Add-BitbucketRepositoryGroupPermission -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { }
    Mock Remove-BitbucketRepositoryGroupPermission -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { }

    $Workspace = 'T'
    $Repo = 'R'
    
    Context 'Matching Permission' {
        $response = [GroupPermissionV1]::New('group-slug', 'read')
        Mock Get-BitbucketRepositoryGroupPermission -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { 
            return $response
        }.GetNewClosure()

        $Permission = [GroupPermissionV1]::New($response.groupslug, $response.privilege)
        Set-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -Permissions $Permission

        It 'Does not add Permission' {
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
        }

        It 'Does not remove Permission' {
            Assert-MockCalled Remove-BitbucketRepositoryGroupPermission -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
        }
    }

    Context 'Mismatched Permission' {
        $response = [GroupPermissionV1]::New('group-slug', 'read')
        Mock Get-BitbucketRepositoryGroupPermission -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { 
            return $response
        }.GetNewClosure()
        
        $Permission = [GroupPermissionV1]::New($response.groupslug, 'write')
        Set-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -Permissions $Permission

        It 'Adds Permission' {
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $groupslug -eq $Permission.groupslug -and $privilege -eq $Permission.privilege
            }
        }

        It 'Removes Permission' {
            Assert-MockCalled Remove-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
            Assert-MockCalled Remove-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $response.groupslug -eq $groupslug
            }
        }
    }

    Context 'Missing Permission' {
        Mock Get-BitbucketRepositoryGroupPermission -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { 
            return $null
        }
        
        $Permission = [GroupPermissionV1]::New('group-slug', 'write')
        Set-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -Permission $Permission

        It 'Adds Permission' {
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $groupslug -eq $Permission.groupslug -and $privilege -eq $Permission.privilege
            }
        }

        It 'Does not remove Permission' {
            Assert-MockCalled Remove-BitbucketRepositoryGroupPermission -Exactly 0 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
        }
    }

    Context 'Complex Permissions' {
        $response1 = [GroupPermissionV1]::New('group-admin', 'admin')
        $response2 = [GroupPermissionV1]::New('group', 'read')

        Mock Get-BitbucketRepositoryGroupPermission -ModuleName Atlassian.Bitbucket.Repository.GroupPermission {
            return @($response1, $response2)
        }.GetNewClosure()
        
        $Permissions = @()
        $Permissions += [GroupPermissionV1]::New('group-admin', 'admin')
        $Permissions += [GroupPermissionV1]::New('group', 'write')

        Set-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -Permission $Permissions

        It 'Adds correct Permission' {
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
            Assert-MockCalled Add-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $groupslug -eq $Permissions[1].groupslug -and $privilege -eq $Permissions[1].privilege
            }
        }

        It 'Removes Permission' {
            Assert-MockCalled Remove-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission
            Assert-MockCalled Remove-BitbucketRepositoryGroupPermission -Exactly 1 -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $groupslug -eq $Response2.groupslug
            }
        }
    }
}