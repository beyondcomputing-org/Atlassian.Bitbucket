Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe "Enable-BitbucketPipelineConfig" {
  $Team = 'T'
  $Repo = 'R'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline {}

  Enable-BitbucketPipelineConfig -RepoSlug $Repo -Team $Team

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
        $Path -eq "repositories/$Team/$Repo/pipelines_config"
    }
  }

  It 'Uses the PUT method' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      $Method -eq 'Put'
    }
  }

  It 'Has a valid body' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      ($Body | ConvertFrom-Json).enabled -eq $true
    }
  }
}