Import-Module '.\Atlassian.Bitbucket.Pipeline.psm1' -Force

Describe "Get-BitbucketPipelineStep" {
  $Workspace = 'T'
  $Repo = 'R'
  $PipelineUUID = '1'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline {}

  Get-BitbucketPipelineStep -RepoSlug $Repo -Workspace $Workspace -PipelineUUID $PipelineUUID

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline -ParameterFilter {
      $Path -like "repositories/$Workspace/$Repo/pipelines/$PipelineUUID/steps/*"
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