Import-Module '.\Atlassian.Bitbucket.Authentication.psm1' -Force

Describe 'Get-BitbucketTeam' {
    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Authentication { 
        $Response = New-Object PSObject -Property @{
            values = 'Value1'
        }
        return $Response
    }
    
    Context 'Get-BitbucketTeam' {
        $result = Get-BitbucketTeam

        It 'Uses default GET Method' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Authentication -ParameterFilter {
                $Method -eq $null
            }
        }

        It 'Has a valid path' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Authentication -ParameterFilter {
                $Path -eq "teams?role=member"
            }
        }

        It 'Has no body'{
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Authentication -ParameterFilter {
                $Body -eq $null
            }
        }

        It 'Is not paginated' {
            Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.Authentication -ParameterFilter {
                $Paginated -eq $null
            }
        }

        It 'Returns value' {
            $result | Should -Be 'Value1'
        }
    }
}