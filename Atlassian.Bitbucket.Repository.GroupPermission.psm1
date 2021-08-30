using module .\Atlassian.Bitbucket.Authentication.psm1
using module .\Classes\Atlassian.Bitbucket.Permissions.psm1
using module .\Atlassian.Bitbucket.Tools.psm1

function Get-BitbucketRepositoryGroupPermission {
    [OutputType([GroupPermissionV1])]
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug
    )

    Process {
        $endpoint = "group-privileges/$Workspace/$RepoSlug"
        $permissions = Invoke-BitbucketAPI -Path $endpoint -API_Version '1.0'

        foreach ($permission in $permissions) {
            [GroupPermissionV1]::New($permission)
        }
    }
}

function Add-BitbucketRepositoryGroupPermission {
    [OutputType([GroupPermissionV1])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The group slug.')]
        [string]$GroupSlug,
        [Parameter( Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The permission to give the group.')]
        [ValidateSet('read', 'write', 'admin')]
        [String]$Privilege
    )

    Process {
        $endpoint = "group-privileges/$Workspace/$RepoSlug/$Workspace/$GroupSlug"

        if ($pscmdlet.ShouldProcess("$GroupSlug $privilege in repo: $RepoSlug", 'grant')) {
            $response = Invoke-BitbucketAPI -Path $endpoint -Method Put -Body $privilege -API_Version '1.0' -ContentType 'application/x-www-form-urlencoded'
            Return [GroupPermissionV1]::New($response)
        }
    }
}

function Set-BitbucketRepositoryGroupPermission {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [GroupPermissionV1[]]$Permissions
    )

    Process {
        $currentPermissions = Get-BitbucketRepositoryGroupPermission -RepoSlug $RepoSlug -Workspace $Workspace

        # Remove extra permissions
        foreach ($current in $currentPermissions) {
            $extra = $true
            foreach ($new in $Permissions) {
                if (Compare-CustomObject $current $new) {
                    $extra = $false
                    break
                }
            }

            if ($extra) {
                $current | Remove-BitbucketRepositoryGroupPermission -RepoSlug $RepoSlug -Workspace $Workspace
            }
            else {
                Write-Verbose "Matching Permission: $($current.groupslug) - $($current.privilege)"
            }
        }

        # Add missing permissions
        foreach ($new in $Permissions) {
            $missing = $true
            foreach ($current in $currentPermissions) {
                if (Compare-CustomObject $new $current) {
                    $missing = $false
                    break
                }
            }

            if ($missing) {
                $new | Add-BitbucketRepositoryGroupPermission -RepoSlug $RepoSlug -Workspace $Workspace
            }
        }
    }
}

function New-BitbucketRepositoryGroupPermission {
    [OutputType([GroupPermissionV1])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [string]$GroupSlug,
        [ValidateSet('read', 'write', 'admin')]
        [string]$Privilege
    )
    if ($pscmdlet.ShouldProcess('GroupPermissionV1 Object', 'create')) {
        Return [GroupPermissionV1]::New($GroupSlug, $Privilege)
    }
}

function Remove-BitbucketRepositoryGroupPermission {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the workspace in Bitbucket.  Defaults to selected workspace if not provided.')]
        [Alias("Team")]
        [string]$Workspace = (Get-BitbucketSelectedWorkspace),
        [Parameter( Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The Slug of the group to be removed.')]
        [string]$GroupSlug
    )

    Process {
        $endpoint = "group-privileges/$Workspace/$RepoSlug/$Workspace/$GroupSlug"
        if ($pscmdlet.ShouldProcess("$GroupSlug in repo: $RepoSlug", 'delete')) {
            Return Invoke-BitbucketAPI -Path $endpoint -Method Delete -API_Version '1.0'
        }
    }
}