Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe 'Wait-BitbucketPipeline' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline { 
        $Response = New-Object PSObject -Property @{
            uuid = (New-Guid).Guid
            build_number = 1
            state = New-Object PSObject -Property @{
                name = 'COMPLETED'
            }
        }
        return $Response
    }

    $Team = 'T'
    
    Context 'Pipeline Input from Start-BitbucketPipeline' {
        $Pipeline = New-Object PSObject -Property @{
            uuid       = (New-Guid).Guid
            repository = New-Object PSObject -Property @{
                uuid = (New-Guid).Guid
            }
        }

        $Pipeline | Wait-BitbucketPipeline -Team $Team

        It 'Uses the repo and pipeline uuid from the pipeline input' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
                $path -eq "repositories/$Team/$($Pipeline.repository.uuid)/pipelines/$($Pipeline.uuid)"
            }
        }
    }
}