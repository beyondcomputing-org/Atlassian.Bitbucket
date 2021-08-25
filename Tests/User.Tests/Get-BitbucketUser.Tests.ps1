Import-Module '.\Atlassian.Bitbucket.User.psm1' -Force

Describe 'Get-BitbucketUser' {
    $Workspace = 'T'

    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User {}

    Get-BitbucketUser -Workspace $Workspace

    It 'Has a valid path' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Path -eq "users/$Workspace/members"
        }
    }

    It 'Has no body' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $null -eq $Body
        }
    }

    It 'Is paginated' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Paginated -eq $true
        }
    }
}