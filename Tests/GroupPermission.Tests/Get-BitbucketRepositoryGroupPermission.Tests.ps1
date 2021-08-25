Import-Module '.\Atlassian.Bitbucket.Repository.GroupPermission.psm1' -Force

Describe 'Get-BitbucketRepositoryGroupPermission' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission { 
        $Response = New-Object PSObject -Property @{
            group     = @{
                slug = 'group-slug'
            }
            privilege = 'read'
        }
        return $Response
    }

    $Workspace = 'T'
    $Repo = 'R'
    
    Context 'Get Permissions' {
        Get-BitbucketRepositoryGroupPermission -Workspace $Workspace -RepoSlug $Repo

        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Method -eq $null
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Path -eq "group-privileges/$Workspace/$Repo"
            }
        }

        It 'Has no body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Not paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.GroupPermission -ParameterFilter {
                $Paginated -eq $null
            }
        }
    }
}