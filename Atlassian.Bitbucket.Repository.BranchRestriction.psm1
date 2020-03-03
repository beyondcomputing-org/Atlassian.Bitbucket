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

        $body = $Restriction | ConvertTo-Json -Depth 3 -Compress

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
                if(Compare-CustomObject $current $new -IgnoreProperty 'id')
                {
                    $extra = $false
                    break
                }
            }

            if($extra)
            {
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
            'require_approvals_to_merge',
            'require_default_reviewer_approvals_to_merge',
            'require_passing_builds_to_merge',
            'require_tasks_to_be_completed'
        )]
        [string]$Kind,
        [string]$Pattern,
        [int]$Value
    )
    if ($pscmdlet.ShouldProcess('MergeCheck Object', 'create')){
        Return [MergeCheck]::New($kind, $pattern, $value)
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