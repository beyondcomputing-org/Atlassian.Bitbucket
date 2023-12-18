Import-Module '.\Atlassian.Bitbucket.Pipeline.Variable.psm1' -Force

Describe "New-BitbucketRepositoryVariable" {
  $Workspace = 'T'
  $Repo = 'R'
  $Key = 'K'
  $Value = 'V'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable {}

  New-BitbucketRepositoryVariable -RepoSlug $Repo -Workspace $Workspace -Key $Key -Value $Value

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $Path -eq "repositories/$Workspace/$Repo/pipelines_config/variables"
    }
  }

  It 'Uses the POST method' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $Method -eq 'Post'
    }
  }

  It 'Has a valid body' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      ($Body | ConvertFrom-Json).key -eq $Key
    }
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      ($Body | ConvertFrom-Json).value -eq $Value
    }
  }
}