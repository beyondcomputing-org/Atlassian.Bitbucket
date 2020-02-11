Import-Module '.\Atlassian.Bitbucket.User.psm1' -Force

Describe 'Get-BitbucketUserByGroup' {
    $Team = 'T'
    $GroupSlug = 'G'

    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User {}

    Get-BitbucketUsersByGroup -Team $Team -GroupSlug $GroupSlug

    It 'Has a valid path' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Path -eq "groups/$Team/$GroupSlug/members"
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