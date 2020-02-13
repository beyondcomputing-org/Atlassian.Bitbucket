using module .\Atlassian.Bitbucket.Authentication.psm1
<#
.Synopsis
   Gets the list of users with access to at least one repository for the team specified.
.DESCRIPTION
   This function returns a list of all the users with access to at least one repository given the team specified. If no team is specified,
   defaults to the selected team.
.EXAMPLE
   Get-BitbucketUser
   Returns a list of users of the default team.
.EXAMPLE
   Get-BitbucketUser -Team $Team
   Returns a list of users of the specified team.
#>
function Get-BitbucketUser {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam)
    )

    Process {
        $endpoint = "users/$Team/members"
        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}
<#
.Synopsis
   Gets the list of users associated to the group slug specified.
.DESCRIPTION
   This function returns a list of all the users associated to the group slug specified. If no team is specified,
   defaults to the selected team.
.EXAMPLE
   Get-BitbucketUsersByGroup -GroupSlug $GroupSlug
   Returns a list of users associated to the specified group slug for the default team.
.EXAMPLE
   Get-BitbucketUsersByGroup -Team $Team -GroupSlug $GroupSlug
   Returns a list of users associated to the specified group slug for the specified team.
#>
function Get-BitbucketUsersByGroup {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter (HelpMessage='The group slug')]
        [string]$GroupSlug
    )

    Process {
        $endpoint = "groups/$Team/$GroupSlug/members"
        return Invoke-BitbucketAPI -Path $endpoint -API_Version '1.0'
    }
}