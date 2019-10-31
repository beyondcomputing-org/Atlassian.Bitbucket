using module .\Atlassian.Bitbucket.Settings.psm1

class BitbucketAuth {
    # Singleton Storage
    static [BitbucketAuth] $Instance

    # Parameters
    [PSCredential]$Credential
    [Object]$User
    [String]$Team
    [String]$AuthType

    # OAuth Parameters
    [PSCredential]$AtlassianCredential
    [PSCredential]$OAuthConsumer
    $Token

    # Instatiator
    static [BitbucketAuth] NewInstance([PSCredential]$Credential) {
        # Remove existing instance
        [BitbucketAuth]::ClearInstance()

        # Create new instance and validate
        $Auth = [BitbucketAuth]::new()
        $Auth.Credential = $Credential
        $Auth.AuthType = 'Basic'
        $Auth.ValidateLoginAndSaveUser()

        [BitbucketAuth]::instance = $Auth
        return [BitbucketAuth]::instance
    }

    # OAuth 2 Instantiator
    static [BitbucketAuth] NewInstance([PSCredential]$AtlassianCredential, [PSCredential]$OAuthConsumer){
        # Remove existing instance
        [BitbucketAuth]::ClearInstance()

        # Create new instance and validate
        $Auth = [BitbucketAuth]::new()
        $Auth.AtlassianCredential = $AtlassianCredential
        $Auth.OAuthConsumer = $OAuthConsumer
        $Auth.AuthType = 'Bearer'
        $Auth.GetAuthToken()
        $Auth.ValidateLoginAndSaveUser()

        [BitbucketAuth]::instance = $Auth
        return [BitbucketAuth]::instance
    }

    static [Void] ClearInstance(){
        [BitbucketAuth]::instance = $null
    }

    # Get Instance or return error requesting login
    static [BitbucketAuth] GetInstance() {
        if ($null -eq [BitbucketAuth]::instance) {
            # Try loading saved settings
            if([BitbucketAuth]::load()){
                return [BitbucketAuth]::instance
            }else{
                throw 'You are not logged in.  Please login with Login-Bitbucket.'
            }
        }else{
            return [BitbucketAuth]::instance
        }
    }

    # Test the credentials and save the user object
    hidden [Void] ValidateLoginAndSaveUser() {
        $URI = [BitbucketSettings]::VERSION_URL + 'user'

        try {
            $this.User = Invoke-RestMethod -Uri $URI -Method Get -Headers $this.GetAuthHeader()
        }
        catch {
            throw 'Login Failed - credentials are invalid.  Use Login-Bitbucket to re-authenticate.'
        }
    }

    # Get Authentication Header
    [Hashtable] GetAuthHeader() {
        switch ($this.AuthType) {
            'Basic' {
                $basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $this.Credential.GetNetworkCredential().UserName, $this.Credential.GetNetworkCredential().Password)))
                return @{Authorization = "Basic $basicAuth"}
            }
            'Bearer' {
                if($this.Token.expires -le (Get-Date)){
                    $this.GetAuthToken()
                }
                return @{Authorization = "Bearer $($this.Token.accessToken)"}
            }
            Default {
                Throw "Unknown Authentication Type: $($this.AuthType)"
            }
        }
        Throw 'Unhandled condition'
    }

    # Get Token
    hidden [Void] GetAuthToken() {
        $body = @{
            grant_type = 'password'
            username = $this.AtlassianCredential.GetNetworkCredential().UserName
            password = $this.AtlassianCredential.GetNetworkCredential().Password
        }

        # Generate the Authentication Header using the ClientID / Secret
        # Not using -Authentication as older versions of Invoke-RestMethod don't support it
        $basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $this.OAuthConsumer.GetNetworkCredential().UserName, $this.OAuthConsumer.GetNetworkCredential().Password)))
        $header = @{Authorization = "Basic $basicAuth"}

        # Get the token from Bitbucket
        $response = Invoke-RestMethod 'https://bitbucket.org/site/oauth2/access_token' -Method Post -Headers $header -Body $body

        # Parse the scopes from the response
        $scope_parts = $response.scopes -split ' '
        $scopes = @()
        foreach ($scope in $scope_parts) {
            $parts = $scope -split ':'

            $scopes += [PSCustomObject]@{
                Name = $parts[0]
                Permission = $parts[1]
            }
        }

        # Store the token
        $this.Token = [PSCustomObject]@{
            accessToken = $response.access_token
            scopes = $scopes
            expires = (Get-Date).AddSeconds($response.expires_in)
            refreshToken = $response.refresh_token
            tokenType = $response.token_type
        }
    }

    # Save the settings to the local system
    [void] Save(){
        if(!(Test-Path([BitbucketSettings]::SAVE_DIR))){
            New-Item -Type Directory -Path ([BitbucketSettings]::SAVE_DIR)
        }

        # Create a filtered object to save
        $Save = [PSCustomObject]@{
            User = $this.User
            Team = $this.Team
            Credential = $this.Credential
            AtlassianCredential = $this.AtlassianCredential
            OAuthConsumer = $this.OAuthConsumer
            AuthType = $this.AuthType
        }

        $Save | Export-CliXml -Path ([BitbucketSettings]::SAVE_PATH)  -Encoding 'utf8' -Force
    }

    # Load Saved Credentials
    hidden static [BitbucketAuth] Load(){
        if(Test-Path([BitbucketSettings]::SAVE_PATH)){
            $Import = Import-CliXml -Path ([BitbucketSettings]::SAVE_PATH)
            $Auth = [BitbucketAuth]::new()

            $Auth.User = $Import.User
            $Auth.Team = $Import.Team
            $Auth.Credential = $Import.Credential
            $Auth.AtlassianCredential = $Import.AtlassianCredential
            $Auth.OAuthConsumer = $Import.OAuthConsumer
            $Auth.AuthType = $Import.AuthType

            switch ($Auth.AuthType) {
                'Basic' {
                    $Auth.ValidateLoginAndSaveUser()
                }
                'Bearer' {
                    $Auth.GetAuthToken()
                    $Auth.ValidateLoginAndSaveUser()
                }
                Default {
                    Throw "Unknown Authentication Type: $($Auth.AuthType)"
                }
            }

            [BitbucketAuth]::instance = $Auth
            return [BitbucketAuth]::instance
        }
        return $null
    }
}