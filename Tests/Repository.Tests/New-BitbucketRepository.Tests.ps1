Import-Module '.\Atlassian.Bitbucket.Repository.psm1' -Force

Describe 'New-BitbucketRepository' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'
    
    Context 'Create new repo with only required params' {
        New-BitbucketRepository -Team $Team -RepoSlug $Repo

        It 'Uses POST Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                $Method -eq 'POST'
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
                    scm = 'git'
                    is_private = $true
                    name = $Repo
                    description = ''
                    language = ''
                    fork_policy = 'no_forks'
                } | ConvertTo-Json -Depth 2 -Compress) -eq $Body
            }
        }
    }

    Context 'Create new repo with a project specified' {
        $Key = 'K'
        New-BitbucketRepository -Team $Team -RepoSlug $Repo -ProjectKey $Key

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                ([ordered]@{
                    scm = 'git'
                    project = [ordered]@{
                        key = $Key
                    }
                    is_private = $true
                    name = $Repo
                    description = ''
                    language = ''
                    fork_policy = 'no_forks'
                } | ConvertTo-Json -Depth 2 -Compress) -eq $Body
            }
        }
    }

    Context 'Create new repo with all properties specified' {
        $Name = 'Repo Name'
        $Key = 'K'
        $Private = $false
        $Description = 'desc'
        $Language = 'powershell'
        $Fork = 'allow_forks'
        New-BitbucketRepository -Team $Team -RepoSlug $Repo -Name $Name -ProjectKey $Key -Private $Private -Description $Description -Language $Language -ForkPolicy $Fork

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
                ([ordered]@{
                    scm = 'git'
                    project = [ordered]@{
                        key = $Key
                    }
                    is_private = $Private
                    name = $Name
                    description = $Description
                    language = $Language
                    fork_policy = $Fork
                } | ConvertTo-Json -Depth 2 -Compress) -eq $Body
            }
        }
    }
}