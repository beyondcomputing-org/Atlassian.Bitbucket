Import-Module '.\Atlassian.Bitbucket.Repository.psm1' -Force

Describe 'Remove-BitbucketRepository' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository { 
        return $null
    }

    $Team = 'T'
    $Repo = 'R'
    
    Context 'Remove Repo' {
        Remove-BitbucketRepository -Team $Team -RepoSlug $Repo -Confirm:$false

        It 'Uses DELETE Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo"
            }
        }

        It 'Has no body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Body -eq $null
            }
        }
    }

    Context 'Accepts pipeline input' {
        $Repo = New-Object PSObject -Property @{
            scm = 'git'
            uuid = (New-Guid)
            slug = 'reponame'
            description = 'desc'
            language = 'powershell'
        }

        $Repo | Remove-BitbucketRepository -Team $Team -Confirm:$false

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Team/$($Repo.slug)"
            }
        }
    }

    Context 'Supports WhatIf' {
        Remove-BitbucketRepository -Team $Team -RepoSlug $Repo -WhatIf

        It 'Does not call the mock' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -Exactly 0
        }
    }
}