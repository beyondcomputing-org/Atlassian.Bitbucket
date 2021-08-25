Import-Module '.\Atlassian.Bitbucket.Pipeline.Variable.psm1' -Force

Describe "Remove-BitbucketRepositoryVariable" {
  $Workspace = 'T'
  $Repo = 'R'
  $Key = 'K'
  $UUID = 'abc'
  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable {}
  Mock Get-BitbucketRepositoryVariable -ModuleName Atlassian.Bitbucket.Pipeline.Variable {
    $Data = [pscustomobject]@{
      key  = 'K'
      uuid = 'abc'
    }
    Return $Data
  }

  Remove-BitbucketRepositoryVariable -RepoSlug $Repo -Workspace $Workspace -Key $Key

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $Path -eq "repositories/$Workspace/$Repo/pipelines_config/variables/abc"
    }
  }

  It 'Uses the DELETE method' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $Method -eq 'Delete'
    }
  }

  It 'Has no body' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $null -eq $Body
    }
  }
}