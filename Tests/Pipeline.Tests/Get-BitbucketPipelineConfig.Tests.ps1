Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe "Enable-BitbucketPipelineConfig" {
  $Team = 'T'
  $Repo = 'R'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline {}

  Get-BitbucketPipelineConfig -RepoSlug $Repo -Team $Team

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
        $Path -eq "repositories/$Team/$Repo/pipelines_config"
    }
  }

  It 'Uses the Get method' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      $Method -eq 'Get'
    }
  }

  It 'Has no body' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      $null -eq $Body
    }
  }
}