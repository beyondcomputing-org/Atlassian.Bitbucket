# Atlassian.Bitbucket
See module manifest `Atlassian.Bitbucket.psd1` for more information.

## Build Status
|Windows|Linux|macOS|
|---|---|---|
|[![Build Status](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_apis/build/status/beyondcomputing-org.Atlassian.Bitbucket?branchName=master&jobName=Build_PS_Win2016)](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_build/latest?definitionId=6&branchName=master)|[![Build Status](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_apis/build/status/beyondcomputing-org.Atlassian.Bitbucket?branchName=master&jobName=Build_PSCore_Ubuntu1604)](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_build/latest?definitionId=6&branchName=master)|[![Build Status](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_apis/build/status/beyondcomputing-org.Atlassian.Bitbucket?branchName=master&jobName=Build_PSCore_MacOS1013)](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_build/latest?definitionId=6&branchName=master)|

## Using The Module
### Authentication
The module provides session level authentication with optional machine / user encrypted persistance between sessions.

#### Login
 `Login-Bitbucket`

#### Persistence
Use `Login-Bitbucket -Save` when logging in or `Save-BitbucketLogin` at any time to save the information to an encrypted file that will be automatically loaded when you start a new session.

### Teams
The module will automatically select your team if you have 1 when logging in or prompt you to choose from a list of teams.  Cmdlets will default to the team selected unless specified.  If you wish to change the team run `Select-BitbucketTeam`.  If you want to save the change run `Save-BitbucketLogin` again.

### CMDLETs
To get more information on each cmdlet run `Get-Help <CMDLET Name>`

#### Authentication CMDLETs
- Get-BitbucketLogin
- Get-BitbucketSelectedTeam
- Get-BitbucketTeam
- New-BitbucketLogin
- Remove-BitbucketLogin
- Save-BitbucketLogin
- Select-BitbucketTeam

#### Pipeline CMDLETs
- Start-BitbucketPipeline
- Wait-BitbucketPipeline

#### Project CMDLETs
- Get-BitbucketProject

#### Repository CMDLETs
- Add-BitbucketRepositoryReviewer
- Get-BitbucketRepository
- Get-BitbucketRepositoryEnvironment
- Get-BitbucketRepositoryDeployment
- Get-BitbucketRepositoryReviewer
- New-BitbucketRepository
- Remove-BitbucketRepository
- Remove-BitbucketRepositoryReviewer
- Set-BitbucketRepository
- Set-BitbucketRepositoryReviewer

## Changes
See CHANGELOG.md for more information.

## Contributing
See CONTRIBUTING.md for more information.