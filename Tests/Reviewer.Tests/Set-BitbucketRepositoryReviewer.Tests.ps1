Import-Module '.\Atlassian.Bitbucket.Repository.Reviewer.psm1' -Force

Describe 'Set-BitbucketRepositoryReviewer' {

    Context 'Compare objects' {
        # Sourced from https://github.com/chriskuech/functional/blob/master/functional.psm1
        # don't use `-is [PSCustomObject]`
        # https://github.com/PowerShell/PowerShell/issues/9557
        function isPsCustomObject($v) {
            $v.PSTypeNames -contains 'System.Management.Automation.PSCustomObject'
        }
        function recursiveEquality($a, $b) {
            if ($a -is [array] -and $b -is [array]) {
                Write-Debug "recursively test arrays '$a' '$b'"
                if ($a.Count -ne $b.Count) {
                    return $false
                }
                $inequalIndexes = 0..($a.Count - 1) | ? { -not (recursiveEquality $a[$_] $b[$_]) }
                return $inequalIndexes.Count -eq 0
            }
            if ($a -is [hashtable] -and $b -is [hashtable]) {
                Write-Debug "recursively test hashtable '$a' '$b'"
                $inequalKeys = $a.Keys + $b.Keys `
                | Sort-Object -Unique `
                | Where-Object { -not (recursiveEquality $a[$_] $b[$_]) }
                return $inequalKeys.Count -eq 0
            }
            if ((isPsCustomObject $a) -and (isPsCustomObject $b)) {
                Write-Debug "a is pscustomobject: $($a -is [psobject])"
                Write-Debug "recursively test objects '$a' '$b'"
                $inequalKeys = $a.psobject.Properties + $b.psobject.Properties `
                | ForEach-Object Name `
                | Sort-Object -Unique `
                | Where-Object { -not (recursiveEquality $a.$_ $b.$_) }
                return $inequalKeys.Count -eq 0
            }
            Write-Debug "test leaves '$a' '$b'"
            return (($null -eq $a -and $null -eq $b) -or ($null -ne $a -and $null -ne $b -and $a.GetType() -eq $b.GetType() -and $a -eq $b))
        }
        <#
        .SYNOPSIS
        Returns true if all elements in the pipeline are truthy
        #>
        function Test-All {
            [OutputType([boolean])]
            Param()
  
            foreach ($e in $input) {
                if (-not $e) {
                    return $false
                }
            }
            return $true
        }
        <#
        .SYNOPSIS
        Returns true if all elements in the pipeline are equival
        .DESCRIPTION
        Compares each element in the pipeline to the first pipeline element using a
        deep/recursive equality check of the properties and items
        #>
        function Test-Equality {
            [OutputType([boolean])]
            Param(
                # The objects to compare for equality
                [Parameter(Mandatory, ValueFromPipeline)]
                [ValidateNotNullOrEmpty()]
                [object[]] $Object
            )
  
            $head = $input | Select -First 1
            $input | Select -Skip 1 | % { recursiveEquality $head $_ } | Test-All
        }
  
        $UUID1 = "{$((New-Guid).Guid)}"
        $UUID2 = "{$((New-Guid).Guid)}"
        $UUID3 = "{$((New-Guid).Guid)}"
        $object1 = New-Object PSObject -Property @{
            uuid = $UUID1, $UUID2
        }

        $object2 = New-Object PSObject -Property @{
            uuid = $UUID1, $UUID2
        }

        $object3 = New-Object PSObject -Property @{
            uuid = $UUID1
        }

        $object4 = New-Object PSObject -Property @{
            uuid = $UUID1, $UUID2, $UUID3
        }

        It 'UUID objects should match' {
            $object1, $object2 | Test-Equality | Should -BeTrue
        }

        It 'UUID objects should not match - one less UUID' {
            $object1, $object3 | Test-Equality | Should -BeFalse
        }

        It 'UUID objects should not match - one more UUID' {
            $object1, $object4 | Test-Equality | Should -BeFalse
        }
    }
    
    Context 'Missing Users' {
        $Team = 'T'
        $RepoSlug = 'R'
        $UUID = "{$((New-Guid).Guid)}"
        Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.Reviewer { 
            $Response = New-Object PSObject -Property @{
                uuid     = $UUID
                team     = $Team
                reposlug = $RepoSlug
                action   = 'Added'
            }
            return $Response
        }
        Add-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug -UUID $UUID
        
        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.Reviewer -ParameterFilter {
                $Path -eq "repositories/$Team/$RepoSlug/default-reviewers/$UUID"
            }
        }

        It 'Uses Put method' {
            $Method -eq 'Put'
        }

        It 'Has action equal to Added' {
            $Response.Action -eq 'Added'
        }
    }

    Context 'Extra Users' {
        $Team = 'T'
        $RepoSlug = 'R'
        $UUID = "{$((New-Guid).Guid)}"
        Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.Reviewer { 
            $Response = New-Object PSObject -Property @{
                uuid     = $UUID
                team     = $Team
                reposlug = $RepoSlug
                action   = 'Deleted'
            }
            return $Response
        }
        Remove-BitbucketRepositoryReviewer -Team $Team -RepoSlug $RepoSlug -UUID $UUID -Confirm:$false
        
        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.Reviewer -ParameterFilter {
                $Path -eq "repositories/$Team/$RepoSlug/default-reviewers/$UUID"
            }
        }

        It 'Uses Delete method' {
            $Method -eq 'Delete'
        }

        It 'Has action equal to Deleted' {
            $Response.Action -eq 'Deleted'
        }
    }

    Context 'Same users' {
        Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Repository.Reviewer { }
        It 'Has no response' {
            $null -eq $Response
        }
    }
}