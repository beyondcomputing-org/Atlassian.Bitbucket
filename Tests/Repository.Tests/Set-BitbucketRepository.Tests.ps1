Import-Module '.\Atlassian.Bitbucket.Repository.psm1' -Force

Describe 'Set-BitbucketRepository' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'
    
    Context 'Updating Project' {
        $Key = 'K'
        Set-BitbucketRepository -Team $Team -RepoSlug $Repo -ProjectKey $Key

        It 'Uses PUT Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Method -eq 'PUT'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo"
            }
        }

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                ([ordered]@{
                    project = [ordered]@{
                        key = $Key
                    }
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }

    Context 'Updating Project and Language' {
        $Key = 'K'
        $Language = 'powershell'
        Set-BitbucketRepository -Team $Team -RepoSlug $Repo -ProjectKey $Key -Language $Language

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                ([ordered]@{
                    project  = [ordered]@{
                        key  = $Key
                    }
                    language = $Language
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }

    Context 'Provides no properties to set' {
        It 'Should throw an error' {
            {Set-BitbucketRepository -Team $Team -RepoSlug $Repo} | Should -Throw
        }
    }

    Context 'Accepts pipeline input only for slug' {
        $Key = 'K'
        $Repo = New-Object PSObject -Property @{
            scm = 'git'
            uuid = (New-Guid)
            slug = 'reponame'
            description = 'desc'
            language = 'powershell'
        }

        $Repo | Set-BitbucketRepository -Team $Team -ProjectKey $Key

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Path -eq "repositories/$Team/$($Repo.slug)"
            }
        }

        It 'Has a valid body with no other properties'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                ([ordered]@{
                    project  = [ordered]@{
                        key  = $Key
                    }
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }
}