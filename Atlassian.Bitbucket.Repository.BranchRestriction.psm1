using module .\Atlassian.Bitbucket.Authentication.psm1
using module .\Classes\Atlassian.Bitbucket.BranchRestriction.psm1
using module .\Atlassian.Bitbucket.Tools.psm1

function Get-BitbucketRepositoryBranchRestriction {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/branch-restrictions/"
        Return Invoke-BitbucketAPI -Path $endpoint -Paginated | ConvertTo-BranchRestriction
    }
}

function Add-BitbucketRepositoryBranchRestriction {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [BranchRestriction]$Restriction
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/branch-restrictions"

        # Check for proper usage of the BranchRestriction.  Must not use the base type.
        if($Restriction.GetType().Name -eq 'BranchRestriction'){
            throw 'Do not use the base type BranchRestriction object.  Instead use the MergeCheck or PermissionCheck object type.'
        }

        # If the branch_match_kind is Glob, remove branch_type property, otherwise the Bitbucket API will throw an exception
        if ($Restriction.branch_match_kind -eq 'Glob') {
            $globRestriction = $Restriction | Select-Object -ExcludeProperty branch_type
            $body = $globRestriction | ConvertTo-Json -Depth 3 -Compress
        }
        else {
            $body = $Restriction | ConvertTo-Json -Depth 3 -Compress
        }

        if ($pscmdlet.ShouldProcess("branch restriction: $($Restriction.kind) in $RepoSlug", 'add')){
            Return Invoke-BitbucketAPI -Path $endpoint -Method Post -Body $body
        }
    }
}

function Set-BitbucketRepositoryBranchRestriction {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [BranchRestriction[]]$Restrictions
    )

    Process{
        $currentRestrictions = Get-BitbucketRepositoryBranchRestriction -RepoSlug $RepoSlug -Team $Team

        # Remove extra restrictions
        foreach ($current in $currentRestrictions)
        {
            $extra = $true
            foreach ($new in $Restrictions)
            {
                Write-Debug "Comparing $($current.kind) with $($new.kind)"
                if(Compare-CustomObject $current $new -IgnoreProperty 'id')
                {
                    $extra = $false
                    break
                }
            }

            if($extra)
            {
                Write-Verbose "Removing Restriction: $($current.kind)"
                Remove-BitbucketRepositoryBranchRestriction -RepoSlug $RepoSlug -Team $Team -RestrictionID $current.id
            }
            else
            {
                Write-Verbose "Matching Restriction: $($current.kind)"
            }
        }

        # Add missing restrictions
        foreach ($new in $Restrictions)
        {
            $missing = $true
            foreach ($current in $currentRestrictions)
            {
                if(Compare-CustomObject $new $current -IgnoreProperty 'id')
                {
                    $missing = $false
                    break
                }
            }

            if($missing)
            {
                Add-BitbucketRepositoryBranchRestriction -RepoSlug $RepoSlug -Team $Team -Restriction $new
            }
        }
    }
}

function Remove-BitbucketRepositoryBranchRestriction {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The ID of the branch restriction to delete.')]
        [Alias('ID')]
        [int]$RestrictionID
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/branch-restrictions/$RestrictionID"
        if ($pscmdlet.ShouldProcess("branch restriction: $RestrictionID in $RepoSlug", 'delete')){
            Return Invoke-BitbucketAPI -Path $endpoint -Method Delete
        }
    }
}

function New-BitbucketRepositoryBranchRestrictionMergeCheck {
    [OutputType([MergeCheck])]
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [ValidateSet(
            'allow_auto_merge_when_builds_pass',
            'enforce_merge_checks',
            'require_all_dependencies_merged',
            'require_approvals_to_merge',
            'require_default_reviewer_approvals_to_merge',
            'require_no_changes_requested',
            'require_passing_builds_to_merge',
            'require_tasks_to_be_completed',
            'reset_pullrequest_approvals_on_change',
            'reset_pullrequest_changes_requested_on_change'
        )]
        [string]$Kind,
        [Nullable[int]]$Value,

        [Parameter(ParameterSetName = "glob")]
        [string]$Pattern,

        [Parameter(ParameterSetName = "branchtype")]
        [ValidateSet(
            'feature',
            'bugfix',
            'release',
            'hotfix',
            'development',
            'production'
        )]
        [string]$BranchType

    )
    if ($pscmdlet.ShouldProcess('MergeCheck Object', 'create')){
        if (-not ([string]::IsNullOrEmpty($BranchType))){
            Return [MergeCheck]::New($kind, $branchtype, $value, $false)
        }

        Return [MergeCheck]::New($kind, $pattern, $value, $true)
    }
}

function New-BitbucketRepositoryBranchRestrictionPermissionCheck {
    [OutputType([PermissionCheck])]
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param (
        [ValidateSet(
            'delete',
            'force',
            'push',
            'restrict_merges'
        )]
        [string]$Kind,
        [string]$UUID,

        [Parameter(ParameterSetName = "glob")]
        [string]$Pattern,

        [Parameter(ParameterSetName = "branchtype")]
        [ValidateSet(
            'feature',
            'bugfix',
            'release',
            'hotfix',
            'development',
            'production'
        )]
        [string]$BranchType,

        [switch]$IsGroup
    )

    [string]$target = $Pattern
    [bool]$isGlob = $true
    if (-not ([string]::IsNullOrEmpty($BranchType))) {
        $target = $BranchType
        $isGlob = $false
    }

    if ($pscmdlet.ShouldProcess('PermissionCheck Object', 'create')){
        Return [PermissionCheck]::New($kind, $uuid, $target, $isGlob, $isgroup)
    }
}

function ConvertTo-BranchRestriction {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true)]
        [PSCustomObject]$Object
    )

    Process {
        switch -regex ($Object.kind) {
            '^require_|enforce_|reset_' { [MergeCheck]::New($Object) }
            Default { [PermissionCheck]::New($Object) }
        }
    }
}