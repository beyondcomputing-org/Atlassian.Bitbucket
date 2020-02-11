class BitbucketSettings {
    static [String]$BASE_URL = 'https://api.bitbucket.org'
    [String]$API_VERSION
    [String]$VERSION_URL
    static [String]$INTERNAL_URL = [BitbucketSettings]::BASE_URL + '/internal/'
    static [String]$SAVE_DIR = "${env:\userprofile}\.Atlassian.Bitbucket"
    static [String]$SAVE_FILE = 'BitbucketAuth.xml'
    static [String]$SAVE_PATH = [BitbucketSettings]::SAVE_DIR + '/' + [BitbucketSettings]::SAVE_FILE

    BitbucketSettings() {
        $this.Init('2.0')
    }

    BitbucketSettings(
        [string]$ApiVersion
    ) {
        $this.Init($ApiVersion)
    }
    hidden Init([string]$ApiVersion) {
        $this.API_VERSION = $ApiVersion
        $this.VERSION_URL = [BitbucketSettings]::BASE_URL + '/' + $this.API_VERSION + '/'
    }
}