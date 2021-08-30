Import-Module '.\Atlassian.Bitbucket.Repository.psm1' -Force

Describe 'Get-BitbucketRepositoryBranch' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository { 
        $Response = New-Object PSObject -Property @{
            type = 'branch'
        }
        return $Response
    }

    $Workspace = 'T'
    $Repo = 'R'
    $Name = 'feature'

    Context 'Get all branches' {
        Get-BitbucketRepositoryBranch -Workspace $Workspace -RepoSlug $Repo

        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Method -eq $null
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Workspace/$Repo/refs/branches?q=name~`"`""
            }
        }

        It 'Has no body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Is paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Paginated -eq $true
            }
        }
    }

    Context 'Get specified branches' {
        Get-BitbucketRepositoryBranch -Workspace $Workspace -RepoSlug $Repo -Name $Name

        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Method -eq $null
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Workspace/$Repo/refs/branches?q=name~`"$Name`""
            }
        }

        It 'Has no body' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Is paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Paginated -eq $true
            }
        }
    }
}