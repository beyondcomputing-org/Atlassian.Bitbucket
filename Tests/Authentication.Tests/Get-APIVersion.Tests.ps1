using module ..\..\Classes\Atlassian.Bitbucket.Settings.psm1
Describe "Get API Version" {

    Context 'Get default API version' {
        It "Returns a default value" {
            $expected = [BitbucketSettings]::new()
            $expected.API_VERSION | should -BeExactly "2.0"
        }
    }

    Context 'Get overridden API Version' {
        $Version = "1.0"
        It "Returns an override value" {
            $expected = [BitbucketSettings]::new($Version)
            $expected.API_VERSION | should -BeExactly "$Version"
        }
    }
}