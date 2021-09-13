Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe "Get-BitbucketPipeline" {
  $Workspace = 'T'
  $Repo = 'R'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline {}

  Get-BitbucketPipeline -RepoSlug $Repo -Workspace $Workspace

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      $Path -like "repositories/$Workspace/$Repo/pipelines/*"
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