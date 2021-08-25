Import-Module '.\Atlassian.Bitbucket.User.psm1' -Force

Describe 'Get-BitbucketUserByGroup' {
    $Workspace = 'T'
    $GroupSlug = 'G'

    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User {}

    Get-BitbucketUsersByGroup -Workspace $Workspace -GroupSlug $GroupSlug

    It 'Has a valid path' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Path -eq "groups/$Workspace/$GroupSlug/members"
        }
    }

    It 'Has no body' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $null -eq $Body
        }
    }

    It 'Is API version 1.0' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $API_Version -eq '1.0'
        }
    }
}