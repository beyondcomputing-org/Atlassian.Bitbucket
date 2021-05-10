Import-Module '.\Atlassian.Bitbucket.Repository.psm1' -Force

Describe 'Add-BitbucketRepositoryBranch' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository {}

    $Team = 'T'
    $RepoSlug = 'R'
    $Branch = 'B'
    $Parent = 'P'
    $Message = 'M'
    
    Add-BitbucketRepositoryBranch -Team $Team -RepoSlug $RepoSlug -Branch $Branch -Parent $Parent -Message $Message

    It 'Uses POST Method' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
            $Method -eq 'POST'
        }
    }

    It 'Has a valid path' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
            $Path -eq "repositories/$Team/$RepoSlug/src/"
        }
    }

    It 'Has correct ContentType' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
            $ContentType -eq "application/x-www-form-urlencoded"
        }
    }

    It 'Has a valid body'{
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
            $testBody = [ordered]@{branch=$Branch; parents=$Parent; message=$Message}
            ($testBody.Keys.Count -eq $Body.Keys.Count) -and ($testBody.Keys | ForEach-Object {$testBody[$_] -eq $Body[$_]})
        }
    }

    It 'Is not paginated' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository -ParameterFilter {
            $Paginated -eq $null
        }
    }
}