Import-Module '.\Atlassian.Bitbucket.User.psm1' -Force

Describe 'Get-BitbucketGroup' {
    $Workspace = 'T'

    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User {}

    Get-BitbucketGroup -Workspace $Workspace

    It 'Has a valid path' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Path -eq "groups/$Workspace"
        }
    }

    It 'Has no body' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $null -eq $Body
        }
    }

    It 'Uses v1 API' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            '1.0' -eq $API_Version
        }
    }
}