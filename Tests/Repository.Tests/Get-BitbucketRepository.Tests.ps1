Import-Module '.\Atlassian.Bitbucket.Repository.psm1' -Force

Describe 'Get-BitbucketRepository' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
        }
        return $Response
    }

    $Team = 'T'
    
    Context 'Get single repo' {
        $Repo = 'R'
        Get-BitbucketRepository -Team $Team -RepoSlug $Repo

        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Method -eq $null
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

        It 'Is not paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Paginated -eq $null
            }
        }
    }

    Context 'Get all repos' {
        Get-BitbucketRepository -Team $Team

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Team"
            }
        }

        It 'Is paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Paginated -eq $true
            }
        }
    }

    Context 'Get all project repos' {
        $Key = 'K'
        Get-BitbucketRepository -Team $Team -ProjectKey $Key

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$($Team)?q=project.key=%22$Key%22"
            }
        }

        It 'Is paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Paginated -eq $true
            }
        }
    }
}