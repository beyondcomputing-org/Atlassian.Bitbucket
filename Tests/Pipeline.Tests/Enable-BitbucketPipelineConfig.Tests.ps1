Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe "Enable-BitbucketPipelineConfig" {
  $Workspace = 'T'
  $Repo = 'R'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline {}

  Enable-BitbucketPipelineConfig -RepoSlug $Repo -Workspace $Workspace

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      $Path -eq "repositories/$Workspace/$Repo/pipelines_config"
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