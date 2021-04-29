using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns the current Branch Model Configuration for a given repository.

    .DESCRIPTION
        Returns the current Branch Model Configuration for a given repository.

    .EXAMPLE
        C:\ PS> Get-BitbucketRepositoryBranchModel -RepoSlug 'repo'
        Returns the Branch Model Configuration for the Repository 'repo'

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.
#>
function Get-BitbucketRepositoryBranchModel {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipelineByPropertyName=$true,
        HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Position=0,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/branching-model"

        return Invoke-BitbucketAPI -Path $endpoint
    }
}

<#
    .SYNOPSIS
        Modifies the Branch Model Configuration for a given Repository

    .DESCRIPTION
        Use this Function to modify the Branch Model Configuration for a given Repository.
        Specify the Production and Development Branches as well as Branch Prefixes.

    .EXAMPLE
        C:\ PS> Set-BitbucketRepositoryBranchModel -RepoSlug 'repo' -Branch 'development' -TargetBranch 'develop'
        Specifies the Branch named 'develop' as the development branch.

    .EXAMPLE
        C:\ PS> Set-BitbucketRepositoryBranchModel -RepoSlug 'repo' -Branch 'production' -UseMainBranch
        Specifies the current main branch as the production branch.

    .EXAMPLE
        C:\ PS> Set-BitbucketRepositoryBranchModel -RepoSlug 'repo' -Branch 'production' -UseMainBranch -Enabled:$false
        Disables the production branch

    .EXAMPLE
        C:\ PS> Set-BitbucketRepositoryBranchModel -RepoSlug 'repo' -BranchTypePrefix 'feature' -BranchPrefix 'new-feature/' -Enabled
        Enables the 'feature' Branch Prefix and sets the Prefix to 'new-feature/'

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Branch
        Name of the Branch to re-target

    .PARAMETER UseMainBranch
        Target the current Main Branch

    .PARAMETER TargetBranch
        Target the specified Branch

    .PARAMETER BranchTypePrefix
        Name of the Branch Prefix to Modify

    .PARAMETER BranchPrefix
        The Prefix to apply to the specified BranchTypePrefix

    .PARAMETER Enabled
        Enables the production or specified BranchTypePrefix
#>
function Set-BitbucketRepositoryBranchModel {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter( ValueFromPipelineByPropertyName=$true,
        HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),

        [Parameter( Position=0,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,

        [Parameter( ParameterSetName = 'branchmodel',
            HelpMessage = 'Which Branch to Modify')]
        [ValidateSet(
            'development',
            'production'
        )]
        [string]$Branch,

        [Parameter( ParameterSetName = 'branchmodel',
            HelpMessage = 'Set Branch to Target Main Branch')]
        [switch]$UseMainBranch,

        [Parameter( ParameterSetName = 'branchmodel',
            HelpMessage = 'Set Branch to Target a Named Branch')]
        [ValidateNotNullOrEmpty()]
        [string]$TargetBranch,

        [Parameter( ParameterSetName = 'prefix',
            HelpMessage = 'Modify the specified Branch Type Prefix')]
        [ValidateSet(
            'bugfix',
            'feature',
            'hotfix',
            'release'
        )]
        [string]$BranchTypePrefix,

        [Parameter( ParameterSetName = 'prefix',
            HelpMessage = 'Set the Prefix for the specified Branch Type')]
        [ValidateNotNullOrEmpty()]
        [string]$BranchPrefix,

        [Parameter(HelpMessage = 'Enable the specified item (development is always enabled)')]
        [switch]$Enabled
    )
    
    Process {
        $endpoint = "repositories/$Team/$RepoSlug/branching-model/settings"

        if ($Branch -eq 'development') {
            if ($UseMainBranch) {
                $body = [ordered]@{
                    development = [ordered]@{
                        name = $null
                        use_mainbranch = $true
                    }
                } | ConvertTo-Json -Depth 2 -Compress
            }
            else {
                $body = [ordered]@{
                    development = [ordered]@{
                        name = $TargetBranch
                        use_mainbranch = $false
                    }
                } | ConvertTo-Json -Depth 2 -Compress
            }
            $target = $Branch
        }
        elseif ($Branch -eq 'production') {
            if ($UseMainBranch) {
                $body = [ordered]@{
                    production = [ordered]@{
                        name = $null
                        use_mainbranch = $true
                        enabled = if ($Enabled) { $true } else { $false }
                    }
                } | ConvertTo-Json -Depth 2 -Compress
            }
            else {
                $body = [ordered]@{
                    production = [ordered]@{
                        name = $TargetBranch
                        use_mainbranch = $false
                        enabled = if ($Enabled) { $true } else { $false }
                    }
                } | ConvertTo-Json -Depth 2 -Compress
            }
            $target = $Branch
        }
        elseif ($BranchTypePrefix.Length -gt 0) {
            $body = [ordered]@{
                branch_types = @([ordered]@{
                    kind = $BranchTypePrefix
                    enabled = if ($Enabled) { $true } else { $false }
                    prefix = $BranchPrefix
                })
            } | ConvertTo-Json -Depth 3 -Compress
            $target = $BranchTypePrefix
        }

        if($PSCmdlet.ShouldProcess("$target", 'Update Branching Model')) {
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Put
        }
    }
}