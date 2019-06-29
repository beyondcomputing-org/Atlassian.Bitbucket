Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe 'Start-BitbucketPipeline' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
            build_number = 1
            state = New-Object PSObject -Property @{
                name = 'PENDING'
            }
        }
        return $Response
    }

    $Team = 'T'
    $Repo = 'R'
    $Branch = 'B'
    
    Context 'Default pipeline' {
        Start-BitbucketPipeline -Team $Team -RepoSlug $Repo -Branch $Branch

        It 'Uses POST Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                $Path -eq "repositories/$Team/$Repo/pipelines/"
            }
        }

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                (@{
                    target = @{
                        ref_type = 'branch'
                        type     = 'pipeline_ref_target'
                        ref_name = $Branch
                    }
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }

    Context 'No branch specified' {
        Start-BitbucketPipeline -Team $Team -RepoSlug $Repo

        It 'Defaults to master branch'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                (@{
                    target = @{
                        ref_type = 'branch'
                        type     = 'pipeline_ref_target'
                        ref_name = 'master'
                    }
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }

    Context 'Custom Pipeline' {
        $Custom = 'C'
        Start-BitbucketPipeline -Team $Team -RepoSlug $Repo -Branch $Branch -Custom $Custom

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                (@{
                    target = @{
                        ref_type = 'branch'
                        type     = 'pipeline_ref_target'
                        ref_name = $Branch
                        selector = @{
                            type    = 'custom'
                            pattern = $Custom
                        }
                    }
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }

    Context 'Single Variable' {
        $Var = @{var1 = 'value1'}

        Start-BitbucketPipeline -Team $Team -RepoSlug $Repo -Branch $Branch -Variables $Var

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                (@{
                    target = @{
                        ref_type = 'branch'
                        type     = 'pipeline_ref_target'
                        ref_name = $Branch
                    }
                    variables = [array]$Var
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }

    Context 'Multiple Variables' {
        $Var = @{var1 = 'value1'},@{var2 = 'value2'}

        Start-BitbucketPipeline -Team $Team -RepoSlug $Repo -Branch $Branch -Variables $Var

        It 'Has a valid body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                (@{
                    target = @{
                        ref_type = 'branch'
                        type     = 'pipeline_ref_target'
                        ref_name = $Branch
                    }
                    variables = $Var
                } | ConvertTo-Json -Compress) -eq $Body
            }
        }
    }
}