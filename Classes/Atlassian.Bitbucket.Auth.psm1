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
        $Auth.ValidateLoginAndSaveUser()

        [BitbucketAuth]::instance = $Auth
        return [BitbucketAuth]::instance
    }

    static [Void] ClearInstance(){
        [BitbucketAuth]::instance = $null
    }

    # Get Instance or return error requesting login
    static [BitbucketAuth] GetInstance() {
        if ([BitbucketAuth]::instance -eq $null) {
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
            $this.User = Invoke-RestMethod -Uri $URI -Method Get -Headers @{Authorization=("Basic {0}" -f $this.GetBasicAuth())}
        }
        catch {
            throw 'Login Failed - credentials are invalid.  Use Login-Bitbucket to re-authenticate.'
        } 
    }

    # Convert credentials to basic auth form
    [string] GetBasicAuth() {
        return [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $this.Credential.GetNetworkCredential().UserName, $this.Credential.GetNetworkCredential().Password)))
    }

    # Save the settings to the local system
    [void] Save(){
        if(!(Test-Path([BitbucketSettings]::SAVE_DIR))){
            New-Item -Type Directory -Path [BitbucketSettings]::SAVE_DIR
        }

        $this | Export-CliXml -Path ([BitbucketSettings]::SAVE_PATH)  -Encoding 'utf8' -Force
    }

    # Load Saved Credentials
    hidden static [BitbucketAuth] Load(){
        if(Test-Path([BitbucketSettings]::SAVE_PATH)){
            $Import = Import-CliXml -Path ([BitbucketSettings]::SAVE_PATH)
            $Auth = [BitbucketAuth]::new()

            $Auth.Credential = $Import.Credential
            $Auth.User = $Import.User
            $Auth.Team = $Import.Team
            
            $Auth.ValidateLoginAndSaveUser()
            [BitbucketAuth]::instance = $Auth
            return [BitbucketAuth]::instance
        }
        return $null
    }
}