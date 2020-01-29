Import-Module '.\Atlassian.Bitbucket.Pipeline.Variable.psm1' -Force

Describe "Get-BitbucketRepositoryVariable" {
  $Team = 'T'
  $Repo = 'R'

  Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable {}

  Get-BitbucketRepositoryVariable -RepoSlug $Repo -Team $Team

  It 'Has a valid path' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
        $Path -eq "repositories/$Team/$Repo/pipelines_config/variables/"
    }
  }

  It 'Has no body' {
    Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Pipeline.Variable -ParameterFilter {
      $null -eq $Body
    }
  }
}