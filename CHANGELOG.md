# Changelog

## Deprecated Features
*These will be removed in the next major release*
- N/A

0.16.0
-----
- Added EnvironmentName filter to `Get-BitbucketRepositoryEnvironment`
- Updated `Get-BitbucketRepositoryDeployment` to have sort option and sort by latest deployment
- Updated `Get-BitbucketRepositoryDeployment` to add new filter options for environment
- Added `Get-BitbucketProjectDeploymentReport`

0.15.3
-----
- Updated OAuth 2.0 to not use Authentication parameter on Invoke-RestMethod to support older versions of PowerShell

0.15.2
-----
- Fixed issue with save command when the folder did not already exist

0.15.1
-----
- Fixed OAuth 2.0 bug

0.15.0
-----
- Added Experimental support for OAuth 2.0 Authentication
- Added Experimental support for Internal API's (See below)
- Added `Get-BitbucketRepositoryEnvironmentVariable` (Experimental)
- Added `New-BitbucketRepositoryEnvironmentVariable` (Experimental)
- Added `Remove-BitbucketRepositoryEnvironmentVariable` (Experimental)
- Rewrote Pester tests for ScriptAnalyzer to improve speed and issue resolution

0.14.0
-----
- Updated `Set-BitbucketRepository` pipeline parameter options*
- Added more unit tests

0.13.0
-----
- Updated `Get-BitbucketRepository` to allow specifying a specific repository*

0.12.0
-----
- Added Slug alias to RepoSlug to simplify pipelining

0.11.0
-----
- Added License, Icon and Tags

0.10.0
-----
- Added `Get-BitbucketPullRequestComment`
- Added `New-BitbucketPullRequestComment`

0.9.0
-----
- Added `Get-BitbucketPullRequest`
- Added `New-BitbucketPullRequest`

0.8.0
-----
- Added `New-BitbucketRepositoryEnvironment`
- Added `Remove-BitbucketRepositoryEnvironment`

0.7.0
-----
- Added `Set-BitbucketRepository`

0.6.0
-----
- Added cmdlets for managing default reviewers on a repository
- Added `Add-BitbucketRepositoryReviewer`
- Added `Get-BitbucketRepositoryReviewer`
- Added `Remove-BitbucketRepositoryReviewer`
- Added `Set-BitbucketRepositoryReviewer`

0.5.0
-----
- Added `New-BitbucketRepository`
- Added `Remove-BitbucketRepository`

0.4.0
-----
- Added `Start-BitbucketPipeline` and `Wait-BitbucketPipeline`

0.3.0
-----
- Added `Get-BitbucketRepositoryDeployment`

0.2.0
-----
- Added `Get-BitbucketRepositoryEnvironment` 

0.1.0
-----
- Pre-Release

- - - - -
Check the [Mastering Markdown](https://guides.github.com/features/mastering-markdown/) for basic syntax.
- - - - -
Following [Semantic Versioning](https://semver.org/)
- - - - -
*Major version zero (0.y.z) is for initial development. Anything may change at any time.  Thus a breaking change was introduced in this version.