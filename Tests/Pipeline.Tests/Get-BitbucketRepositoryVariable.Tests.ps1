Import-Module '.\Atlassian.Bitbucket.Pipeline.Variable.psm1' -Force

Describe "Get-BitbucketRepositoryVariable" {
  $Workspace = 'T'
  $Repo = 'R'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable {}

  Get-BitbucketRepositoryVariable -RepoSlug $Repo -Workspace $Workspace

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $Path -eq "repositories/$Workspace/$Repo/pipelines_config/variables/"
    }
  }

  It 'Has no body' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $null -eq $Body
    }
  }
}