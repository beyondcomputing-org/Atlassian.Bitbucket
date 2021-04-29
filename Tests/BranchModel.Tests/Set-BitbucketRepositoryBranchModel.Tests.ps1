Import-Module '.\Atlassian.Bitbucket.Repository.BranchModel.psm1'

Describe 'Set-BitbucketRepositoryBranchModel' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel { 
        $Response = New-Object PSObject -Property @{
            type = 'branching_model'
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'
    $TestBody = [ordered]@{
        development = [ordered]@{
            name = $null
            use_mainbranch = $true
        }
    } | ConvertTo-Json -Depth 2 -Compress

    Context 'Set Branching Model' {
        Set-BitbucketRepositoryBranchModel -Team $Team -RepoSlug $Repo -Branch 'development' -UseMainBranch
        
        It 'Uses PUT Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo/branching-model/settings"
            }
        }

        It 'Has correct body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Body -eq $TestBody
            }
        }

        It 'Is not paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Paginated -eq $null
            }
        }
    }
}