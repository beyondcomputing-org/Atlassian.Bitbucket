#Requires -Module 'Selenium'

$ProjectKey = 'SEM'
$Description = "# Why? #`n`n# What? #`n`n# How this was tested? #`n"

function Get-Cookies {
  [CmdletBinding()]
  param(
    $Timeout = 60000
  )
  $Driver = Start-SeChrome -Arguments @("--app=https://bitbucket.org/account/signin/")

  # Wait for user to complete login process
  do {
    Write-Progress 'Please login to Bitbucket.' -SecondsRemaining ($Timeout / 1000)
    if ($Timeout -gt 0) {
      Start-Sleep -Milliseconds 100
      $Timeout -= 100
    }
    else {
      Throw "Exceeded timeout of $Timeout ms waiting for user to login and navigate to dashboard."
    }
  } until ($Driver.Url -eq 'https://bitbucket.org/dashboard/overview')

  # Get Cookies
  $cookies = $Driver.Manage().Cookies.AllCookies

  # Stop Browser
  $Driver.Quit()

  Return $cookies
}

function Get-Session {
  [CmdletBinding()]
  param(
    $Cookies
  )
  $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
  foreach ($_cookie in $Cookies) {
    # Create Cookie
    $cookie = New-Object System.Net.Cookie
    $cookie.Name = $_cookie.Name
    $cookie.Value = $_cookie.Value
    $cookie.Domain = $_cookie.Domain
    if ($_cookie.Expiry) {
      $cookie.Expires = $_cookie.Expiry
    }

    # Add Cookie to Session
    $session.Cookies.Add($cookie)
  }
  return $session;
}

$cookies = Get-Cookies
$session = Get-Session -Cookies $cookies

$repos = Get-BitbucketRepository -ProjectKey $ProjectKey

foreach ($repo in $repos) {
  $URI = "https://bitbucket.org/$($repo.full_name)/admin/pullrequests/default-pull-request-description/"

  $Token = ($cookies | Where-Object Name -eq 'csrftoken').Value

  $headers = @{'referer' = "https://bitbucket.org/$($repo.full_name)/admin/pullrequests/default-pull-request-description/" }

  $Body = @{
    'default_pull_request_description' = $Description
    'csrfmiddlewaretoken'              = $Token
  };

  Invoke-WebRequest -Method Post -Uri $URI -Headers $headers -WebSession $session -ContentType 'application/x-www-form-urlencoded' -Body $Body
}