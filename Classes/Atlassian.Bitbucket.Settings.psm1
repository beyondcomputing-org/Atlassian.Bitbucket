class BitbucketSettings {
    static [String]$BASE_URL = 'https://api.bitbucket.org'
    static [String]$API_VERSION = '2.0'
    static [String]$VERSION_URL = [BitbucketSettings]::BASE_URL + '/' + [BitbucketSettings]::API_VERSION + '/'
    static [String]$SAVE_DIR = "${env:\userprofile}\.Atlassian.Bitbucket"
    static [String]$SAVE_FILE = 'BitbucketAuth.xml'
    static [String]$SAVE_PATH = [BitbucketSettings]::SAVE_DIR + '/' + [BitbucketSettings]::SAVE_FILE
}