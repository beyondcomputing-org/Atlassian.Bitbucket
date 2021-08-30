Import-Module '.\Atlassian.Bitbucket.Repository.GroupPermission.psm1' -Force

Describe 'Remove-BitbucketRepositoryGroupPermission' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { 
        return $null
    }

    $Workspace = 'T'
    $Repo = 'R'
    $GroupSlug = 'group-slug'
    
    Context 'Remove Group Permission' {
        Remove-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -GroupSlug $GroupSlug

        It 'Uses DELETE Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Path -eq "group-privileges/$Workspace/$Repo/$Workspace/$GroupSlug"
            }
        }

        It 'Has no body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Uses v1 API' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                '1.0' -eq $API_Version
            }
        }
    }

    Context 'Accepts pipeline input' {
        $Permission = New-Object PSObject -Property @{
            groupslug = $GroupSlug
        }

        $Permission | Remove-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -Confirm:$false

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Path -eq "group-privileges/$Workspace/$Repo/$Workspace/$GroupSlug"
            }
        }
    }

    Context 'Supports WhatIf' {
        Remove-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo -GroupSlug $GroupSlug -WhatIf

        It 'Does not call the mock' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -Exactly 0
        }
    }
}