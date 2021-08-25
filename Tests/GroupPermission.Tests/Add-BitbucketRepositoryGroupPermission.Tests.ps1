Import-Module '.\Atlassian.Bitbucket.Repository.GroupPermission.psm1' -Force

Describe 'Add-BitbucketRepositoryGroupPermission' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { 
        $Response = New-Object PSObject -Property @{
            groupslug = 'slug'
            privilege = $body 
        }
        return $Response
    }

    $Workspace = 'T'
    $Repo = 'R'
    $Group = 'G'
    $Privilege = 'read'
    
    Context 'Create new permission from pipeline' {
        $Permission = New-BitbucketRepositoryGroupPermission -GroupSlug $Group -Privilege $Privilege
        $Permission | Add-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Path -eq "group-privileges/$Workspace/$Repo/$Workspace/$Group"
            }
        }

        It 'Has a valid body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Privilege -eq $Body
            }
        }
    }

    Context 'Create new permission' {
        Add-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -GroupSlug $Group -Privilege $Privilege

        It 'Uses PUT Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Method -eq 'PUT'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Path -eq "group-privileges/$Workspace/$Repo/$Workspace/$Group"
            }
        }

        It 'Has a valid body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Privilege -eq $Body
            }
        }

        It 'Uses v1 API' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                '1.0' -eq $API_Version
            }
        }

        It 'Uses ContentType application/x-www-form-urlencoded' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                'application/x-www-form-urlencoded' -eq $ContentType
            }
        }
    }
}