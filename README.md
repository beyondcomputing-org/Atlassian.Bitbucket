# Atlassian.Bitbucket
See module manifest `Atlassian.Bitbucket.psd1` for more information.

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

#### Project CMDLETs
- Get-BitbucketProject

#### Repository CMDLETs
- Get-BitbucketRepository

## Changes
See CHANGELOG.md for more information.

## Contributing
See CONTRIBUTING.md for more information.