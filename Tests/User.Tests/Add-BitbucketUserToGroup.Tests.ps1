Import-Module '.\Atlassian.Bitbucket.User.psm1' -Force

Describe 'Add-BitbucketUserToGroup' {
    $Workspace = 'T'
    $GroupSlug = 'G'
    $UserUuid = 'U'

    Mock Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User {}

    Add-BitbucketUserToGroup -Workspace $Workspace -GroupSlug $GroupSlug -UserUuid $UserUuid

    It 'Uses PUT Method' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Method -eq 'PUT'
        }
    }
    
    It 'Has a valid path' {
        Assert-MockCalled Invoke-BitbucketAPI -ModuleName Atlassian.Bitbucket.User -ParameterFilter {
            $Path -eq "groups/$Workspace/$GroupSlug/members/$UserUuid"
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