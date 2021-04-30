# Changelog

## Deprecated Features

_These will be removed in the next major release_

- N/A

## 0.27.0
- Added work around to Invoke-BitbucketAPI for bug [BCLOUD-20796](https://jira.atlassian.com/browse/BCLOUD-20796)

## 0.26.0
- Added `Add-BitbucketUserToGroup`
- Added `Get-BitbucketGroup`

## 0.25.1
- Fixed example for `New-BitbucketPullRequest`
- Updated readme to call out use of App Passwords for basic auth

## 0.25.0
- Added Reviewers to `New-BitbucketPullRequest`

## 0.24.1
- Fixed `Get-BitbucketProjectDeploymentReport` to use passed in team if provided
- Improved error handling for authentication loading

## 0.24.0
- Added `Add-BitbucketRepositoryGroupPermission`
- Added `Get-BitbucketRepositoryGroupPermission`
- Added `New-BitbucketRepositoryGroupPermission`
- Added `Remove-BitbucketRepositoryGroupPermission`
- Added `Set-BitbucketRepositoryGroupPermission`

## 0.23.0
- Updated to support premium checks in branch restriction code
- Added WhatIf support to `Add-BitbucketRepositoryBranchRestriction`

## 0.22.0
- Added `Add-BitbucketRepositoryBranchRestriction`
- Added `Get-BitbucketRepositoryBranchRestriction`
- Added `New-BitbucketRepositoryBranchRestrictionMergeCheck`
- Added `Remove-BitbucketRepositoryBranchRestriction`
- Added `Set-BitbucketRepositoryBranchRestriction`

## 0.21.0
- Updated `Add-BitbucketRepositoryReviewer` to use uuid instead of nickname
- Updated `Remove-BitbucketRepositoryReviewer` to use uuid instead of nickname
- Updated `Set-BitbucketRepositoryReviewer` to use uuid instead of nickname
- Added `Get-BitbucketUser`
- Added `Get-BitbucketUsersByGroup`
- Added additional test coverage

## 0.20.0
- Added `Get-BitbucketRepositoryVariable`
- Added `New-BitbucketRepositoryVariable`
- Added `Remove-BitbucketRepositoryVariable`
- Added `Enable-BitbucketPipelineConfig`
- Added `Get-BitbucketPipelineConfig`
- Updated `Get-BitBucketRepositoryEnvironmentVariable` to no longer be internal
- Updated `New-BitBucketRepositoryEnvironmentVariable` to no longer be internal
- Updated `Remove-BitBucketRepositoryEnvironmentVariable` to no longer be internal

## 0.19.0
- Breaking Change: Removed ProjectKey Parameter from `Get-BitbucketProjectDeploymentReport` which now accepts pipeline input of repos
- Improved `Get-BitbucketProjectDeploymentReport` HTML to allow minimizing and maximizing of rows

## 0.18.1
- Fixed `Get-BitbucketProjectDeploymentReport` to show failed runs using a combination of State and Status

## 0.18.0
- Added Date to HTML report

## 0.17.0
- Improved styling of HTML report from `Get-BitbucketProjectDeploymentReport`
- Adding fields parameter for fetching additional fields to `Get-BitbucketRepositoryDeployment`

## 0.16.0
- Added EnvironmentName filter to `Get-BitbucketRepositoryEnvironment`
- Updated `Get-BitbucketRepositoryDeployment` to have sort option and sort by latest deployment
- Updated `Get-BitbucketRepositoryDeployment` to add new filter options for environment
- Added `Get-BitbucketProjectDeploymentReport`

## 0.15.3
- Updated OAuth 2.0 to not use Authentication parameter on Invoke-RestMethod to support older versions of PowerShell

## 0.15.2
- Fixed issue with save command when the folder did not already exist

## 0.15.1
- Fixed OAuth 2.0 bug

## 0.15.0
- Added Experimental support for OAuth 2.0 Authentication
- Added Experimental support for Internal API's (See below)
- Added `Get-BitbucketRepositoryEnvironmentVariable` (Experimental)
- Added `New-BitbucketRepositoryEnvironmentVariable` (Experimental)
- Added `Remove-BitbucketRepositoryEnvironmentVariable` (Experimental)
- Rewrote Pester tests for ScriptAnalyzer to improve speed and issue resolution

## 0.14.0
- Updated `Set-BitbucketRepository` pipeline parameter options\*
- Added more unit tests

## 0.13.0
- Updated `Get-BitbucketRepository` to allow specifying a specific repository\*

## 0.12.0
- Added Slug alias to RepoSlug to simplify pipelining

## 0.11.0
- Added License, Icon and Tags

## 0.10.0
- Added `Get-BitbucketPullRequestComment`
- Added `New-BitbucketPullRequestComment`

## 0.9.0
- Added `Get-BitbucketPullRequest`
- Added `New-BitbucketPullRequest`

## 0.8.0
- Added `New-BitbucketRepositoryEnvironment`
- Added `Remove-BitbucketRepositoryEnvironment`

## 0.7.0
- Added `Set-BitbucketRepository`

## 0.6.0
- Added cmdlets for managing default reviewers on a repository
- Added `Add-BitbucketRepositoryReviewer`
- Added `Get-BitbucketRepositoryReviewer`
- Added `Remove-BitbucketRepositoryReviewer`
- Added `Set-BitbucketRepositoryReviewer`

## 0.5.0
- Added `New-BitbucketRepository`
- Added `Remove-BitbucketRepository`

## 0.4.0
- Added `Start-BitbucketPipeline` and `Wait-BitbucketPipeline`

## 0.3.0
- Added `Get-BitbucketRepositoryDeployment`

## 0.2.0
- Added `Get-BitbucketRepositoryEnvironment`

## 0.1.0
- Pre-Release

---

Check the [Mastering Markdown](https://guides.github.com/features/mastering-markdown/) for basic syntax.

---

Following [Semantic Versioning](https://semver.org/)

---

\*Major version zero (0.y.z) is for initial development. Anything may change at any time. Thus a breaking change was introduced in this version.
