using module .\Atlassian.Bitbucket.Settings.psm1

class BitbucketAuth {
    # Singleton Storage
    static [BitbucketAuth] $Instance
    
    # Parameters
    [PSCredential]$Credential
    [Object]$User
    [String]$Team

    # Instatiator
    static [BitbucketAuth] NewInstance([PSCredential]$Credential) {
        # Remove existing instance
        [BitbucketAuth]::ClearInstance()
        
        # Create new instance and validate
        $Auth = [BitbucketAuth]::new()
        $Auth.Credential = $Credential

        if (!$Auth.ValidateCredential()) {
            throw 'Login Failed - credentials are invalid.'
        }

        # Save instance
        [BitbucketAuth]::instance = $Auth
        return [BitbucketAuth]::instance
    }

    static [Void] ClearInstance(){
        [BitbucketAuth]::instance = $null
    }

    # Get Instance or return error requesting login
    static [BitbucketAuth] GetInstance() {
        if ([BitbucketAuth]::instance -eq $null) {
            throw 'You are not logged in.  Please login with Login-Bitbucket'
        }else{
            return [BitbucketAuth]::instance
        }
    }

    hidden [bool] ValidateCredential() {
        $URI = [BitbucketSettings]::VERSION_URL + 'user'

        try {
            $this.User = Invoke-RestMethod -Uri $URI -Method Get -Headers @{Authorization=("Basic {0}" -f $this.GetBasicAuth())}
            return $true
        }
        catch {
            return $false
        } 
    }

    [string] GetBasicAuth() {
        return [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $this.Credential.GetNetworkCredential().UserName, $this.Credential.GetNetworkCredential().Password)))
    }
}