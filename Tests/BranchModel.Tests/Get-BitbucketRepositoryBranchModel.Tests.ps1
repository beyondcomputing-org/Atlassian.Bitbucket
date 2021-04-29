Import-Module '.\Atlassian.Bitbucket.Repository.BranchModel.psm1'

Describe 'Get-BitbucketRepositoryBranchModel' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel { 
        $Response = New-Object PSObject -Property @{
            type = 'branching_model'
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'

    Context 'Get Branching Model' {
        Get-BitbucketRepositoryBranchModel -Team $Team -RepoSlug $Repo
        
        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Method -eq $null
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo/branching-model"
            }
        }

        It 'Has no body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Is not paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.BranchModel -ParameterFilter {
                $Paginated -eq $null
            }
        }
    }
}