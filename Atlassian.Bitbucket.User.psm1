using module .\Atlassian.Bitbucket.Authentication.psm1
<#
.Synopsis
   Gets the list of users with access to at least one repository for the workspace specified.
.DESCRIPTION
   This function returns a list of all the users with access to at least one repository given the workspace specified. If no workspace is specified,
   defaults to the selected workspace.
.EXAMPLE
   Get-BitbucketUser
   Returns a list of users of the default workspace.
.EXAMPLE
   Get-BitbucketUser -Workspace $Workspace
   Returns a list of users of the specified workspace.
#>
function Get-BitbucketUser {
   [CmdletBinding()]
   param(
      [Parameter( ValueFromPipelineByPropertyName = $true,
         HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
      [Alias("Team")]
      [string]$Workspace = (Get-BitbucketSelectedWorkspace)
   )

   Process {
      $endpoint = "workspaces/$Workspace/members"
      return Invoke-BitbucketAPI -Path $endpoint -Paginated
   }
}
<#
.Synopsis
   Gets the list of users associated to the group slug specified.
.DESCRIPTION
   This function returns a list of all the users associated to the group slug specified. If no workspace is specified,
   defaults to the selected workspace.
.EXAMPLE
   Get-BitbucketUsersByGroup -GroupSlug $GroupSlug
   Returns a list of users associated to the specified group slug for the default workspace.
.EXAMPLE
   Get-BitbucketUsersByGroup -Workspace $Workspace -GroupSlug $GroupSlug
   Returns a list of users associated to the specified group slug for the specified workspace.
#>
function Get-BitbucketUsersByGroup {
   [CmdletBinding()]
   [Obsolete('No longer supported by Atlassian')]
   param(
      [Parameter( ValueFromPipelineByPropertyName = $true,
         HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
      [Alias("Team")]
      [string]$Workspace = (Get-BitbucketSelectedWorkspace),
      [Parameter (HelpMessage = 'The group slug')]
      [string]$GroupSlug
   )

   Process {
      $endpoint = "groups/$Workspace/$GroupSlug/members"
      return Invoke-BitbucketAPI -Path $endpoint -API_Version '1.0'
   }
}
<#
.Synopsis
   Gets the list of user groups.
.DESCRIPTION
   This function returns a list of all the user groups. If no workspace is specified,
   defaults to the selected workspace.
.EXAMPLE
   Get-BitbucketGroup
   Returns a list of groups for the default workspace.
.EXAMPLE
   Get-BitbucketGroup -Workspace $Workspace
   Returns a list of groups for the specified workspace.
#>
function Get-BitbucketGroup {
   [CmdletBinding()]
   [Obsolete('No longer supported by Atlassian')]
   param(
      [Parameter( ValueFromPipelineByPropertyName = $true,
         HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
      [Alias("Team")]
      [string]$Workspace = (Get-BitbucketSelectedWorkspace)
   )

   Process {
      $endpoint = "groups/$Workspace"
      return Invoke-BitbucketAPI -Path $endpoint -API_Version '1.0'
   }
}
<#
.Synopsis
   Add a user to a group
.DESCRIPTION
   This function adds an existing user to an existing group. If no workspace is specified,
   defaults to the selected workspace.
.EXAMPLE
   Add-BitbucketUserToGroup -GroupSlug $GroupSlug -UserUuid $UserUuid
   Adds user to group within the default workspace.
.EXAMPLE
   Add-BitbucketUserToGroup -GroupSlug $GroupSlug -UserUuid $UserUuid -Workspace $Workspace
   Adds user to group within the specified workspace.
#>
function Add-BitbucketUserToGroup {
   [CmdletBinding()]
   [Obsolete('No longer supported by Atlassian')]
   param(
      [Parameter( ValueFromPipelineByPropertyName = $true,
         HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
      [Alias("Team")]
      [string]$Workspace = (Get-BitbucketSelectedWorkspace),
      [Parameter (HelpMessage = 'The group slug')]
      [string]$GroupSlug,
      [Parameter (HelpMessage = 'The user UUID')]
      [string]$UserUuid
   )

   Process {
      $endpoint = "groups/$Workspace/$GroupSlug/members/$UserUuid"
      return Invoke-BitbucketAPI -Path $endpoint -API_Version '1.0' -Method 'Put'
   }
}
