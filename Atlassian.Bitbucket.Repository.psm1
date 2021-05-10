using module .\Atlassian.Bitbucket.Authentication.psm1

<#
    .SYNOPSIS
        Returns all Repositories in the team.

    .DESCRIPTION
        Returns all the Bitbucket Repositories in the team, or all repositories in the specific project.

    .EXAMPLE
        C:\PS> Get-BitbucketRepository
        Returns all repositories for the currently selected team.

    .EXAMPLE
        C:\PS> Get-BitbucketRepository -ProjectKey 'KEY'
        Returns all repositories for the specified project.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER ProjectKey
        Project key in Bitbucket
#>
function Get-BitbucketRepository {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Project key in Bitbucket')]
        [string]$ProjectKey
    )

    Process {
        $endpoint = "repositories/$Team"

        if($RepoSlug){
            return Invoke-BitbucketAPI -Path "$endpoint/$RepoSlug"
        }elseif($ProjectKey){
            # Filter to a specific project
            $endpoint += "?q=project.key=%22$ProjectKey%22"
        }
        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}

<#
    .SYNOPSIS
        Creates a new repositories in the team.

    .DESCRIPTION
        Creates a new Bitbucket repositories in the team, and in a specific project if specified.

    .EXAMPLE
        C:\PS> New-BitbucketRepository -RepoSlug 'NewRepo'
        Creates a new repository in Bitbucket called NewRepo.  Since a project wasn't specified the repository is automatically assigned to the oldest project in the team.

    .EXAMPLE
        C:\PS> New-BitbucketRepository -RepoSlug 'NewRepo' -ProjectKey 'KEY'
        Creates a new repository in Bitbucket called NewRepo and puts it in the KEY project.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Name
        Sets a Friendly Name for the Repository

    .PARAMETER ProjectKey
        Project key in Bitbucket.

    .PARAMETER Private
        Whether the repo should be private or public.  Defaults to Private.

    .PARAMETER Description
        Description for the repo.

    .PARAMETER Language
        Programming language used in the repo.

    .PARAMETER ForkPolicy
        Fork policy of the repo.  [allow_forks, no_public_forks, no_forks]
#>
function New-BitbucketRepository {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Specify a Friendly Name for the Repo')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Project key in Bitbucket')]
        [string]$ProjectKey,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Is the repo private?')]
        [boolean]$Private = $true,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Description for the repo')]
        [string]$Description = '',
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Programming language used in the repo')]
        [ValidateSet('java', 'javascript','python','ruby','php','powershell')]
        [string]$Language = '',
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Fork policy of the repo.  [allow_forks, no_public_forks, no_forks]')]
        [ValidateSet('allow_forks', 'no_public_forks', 'no_forks')]
        [string]$ForkPolicy = 'no_forks'
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug"

        if($ProjectKey){
            $body = [ordered]@{
                scm = 'git'
                project = [ordered]@{
                    key = $ProjectKey
                }
                is_private = $Private
                name = if ($Name) { $Name } else { $RepoSlug }
                description = $Description
                language = $Language
                fork_policy = $ForkPolicy
            } | ConvertTo-Json -Depth 2 -Compress
        }else{
            $body = [ordered]@{
                scm = 'git'
                is_private = $Private
                name = if ($Name) { $Name } else { $RepoSlug }
                description = $Description
                language = $Language
                fork_policy = $ForkPolicy
            } | ConvertTo-Json -Depth 2 -Compress
        }

        if ($pscmdlet.ShouldProcess($RepoSlug, 'create')){
            return Invoke-BitbucketAPI -Path $endpoint -Body $body  -Method Post
        }
    }
}

<#
    .SYNOPSIS
        Updates an existing repository.

    .DESCRIPTION
        Updates properties on an existing repository in Bitbucket.  You can set one or many properties at a time.

    .EXAMPLE
        C:\PS> Set-BitbucketRepository -RepoSlug 'Repo' -Language 'Java'
        Sets the repo's language to Java

    .EXAMPLE
        C:\PS> Set-BitbucketRepository -RepoSlug 'Repo' -ProjectKey 'KEY'
        Moves the repo to the Project 'KEY'

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Name
        Rename the repo in Bitbucket. Also renames the Slug.

    .PARAMETER ProjectKey
        Project key in Bitbucket.

    .PARAMETER Private
        Whether the repo should be private or public.

    .PARAMETER Description
        Description for the repo.

    .PARAMETER Language
        Programming language used in the repo.

    .PARAMETER ForkPolicy
        Fork policy of the repo.  [allow_forks, no_public_forks, no_forks]
#>
function Set-BitbucketRepository {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( HelpMessage='Set the Friendly Name of the Repository')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter( HelpMessage='Project key in Bitbucket')]
        [string]$ProjectKey,
        [Parameter( HelpMessage='Is the repo private?')]
        [boolean]$Private,
        [Parameter( HelpMessage='Description for the repo')]
        [string]$Description,
        [Parameter( HelpMessage='Programming language used in the repo')]
        [ValidateSet('java', 'javascript','python','ruby','php','powershell')]
        [string]$Language,
        [Parameter( HelpMessage='Fork policy of the repo.  [allow_forks, no_public_forks, no_forks]')]
        [ValidateSet('allow_forks', 'no_public_forks', 'no_forks')]
        [string]$ForkPolicy
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug"
        $body = [ordered]@{}

        if($ProjectKey){
            $body += [ordered]@{
                project = [ordered]@{
                    key = $ProjectKey
                }
            }
        }
        if($Private){
            $body += [ordered]@{
                is_private = $Private
            }
        }
        if ($Name){
            $body += [ordered]@{
                name = $Name
            }
        }
        if($Description){
            $body += [ordered]@{
                description = $Description
            }
        }
        if($Language){
            $body += [ordered]@{
                language = $Language
            }
        }
        if($ForkPolicy){
            $body += [ordered]@{
                fork_policy = $ForkPolicy
            }
        }
        if($body.Count -eq 0){
            throw "No settings provided to update"
        }

        $body = $body | ConvertTo-Json -Depth 2 -Compress

        if ($pscmdlet.ShouldProcess($RepoSlug, 'update')){
            return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Put
        }
    }
}

<#
    .SYNOPSIS
        Deletes the specified repository.

    .DESCRIPTION
        Deletes the specified repository.  This is an irreversible operation.  This does not affect its forks.

    .EXAMPLE
        C:\PS> Remove-BitbucketRepository -RepoSlug 'Repo1'
        Deletes the repository named Repo1.

    .EXAMPLE
        C:\PS> Remove-BitbucketRepository -RepoSlug 'Repo1' -Redirect 'NewURL'
        Deletes the repository named Repo1 and leaves a redirect message for future visitors.

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Redirect
        If a repository has been moved to a new location, use this parameter to show users a friendly message in the Bitbucket UI that the repository has moved to a new location. However, a GET to this endpoint will still return a 404.
#>
function Remove-BitbucketRepository {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Redirect string')]
        [string]$Redirect
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug"

        if($Redirect){
            $endpoint += "?redirect_to=$Redirect"
        }

        if ($pscmdlet.ShouldProcess($RepoSlug, 'permanently delete')){
            return Invoke-BitbucketAPI -Path $endpoint -Method Delete
        }
    }
}

<#
    .SYNOPSIS
        Creates a new branch

    .DESCRIPTION
        Creates a branch in the specified repository. If no parent is specified, branch will be created from the latest commit of the default branch.

    .EXAMPLE
        C:\PS> Add-BitBucketRepositoryBranch -Branch 'NewBranch' -Team 'MyTeam' -RepoSlug 'Repo1'
        Adds new branch from the last commit of the default branch

    .EXAMPLE
        C:\PS> Add-BitBucketRepositoryBranch -Branch 'NewBranch' -Parent 'CommitHash'
        Adds new branch from the specified commit

    .EXAMPLE
        C:\PS> Add-BitBucketRepositoryBranch -Branch 'NewBranch' -Message 'Create new branch'
        Adds new branch with specified commit message

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Branch
        Name of the branch to create

    .PARAMETER Parent
        Optional hash of the commit to create the branch from

    .PARAMETER Message
        Optional commit message for the new branch
#>
function Add-BitbucketRepositoryBranch {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter( Mandatory=$true,
                    Position=1,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the branch to create.')]
        [string]$Branch,
        [Parameter(HelpMessage='Hash of the commit to create the branch from.')]
        [string]$Parent,
        [Parameter(HelpMessage='Commit message for the new branch.')]
        [string]$Message
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/src/"

        $body = [ordered]@{branch=$Branch}

        if ($Parent) {
            $body.Add("parents", $parent)
        }

        if ($Message) {
            $body.Add("message", $message)
        }

        return Invoke-BitbucketAPI -Path $endpoint -Body $body -Method Post -ContentType 'application/x-www-form-urlencoded'
    }
}

<#
    .SYNOPSIS
        Returns the branches in a specified repository.

    .DESCRIPTION
        Returns the branches in a specified repository.

    .EXAMPLE
        C:\ PS> Get-BitbucketRepositoryBranch -RepoSlug 'repo'
        Returns all the branches in the Repository named repo

    .EXAMPLE
        C:\ PS> Get-BitbucketRepositoryBranch -RepoSlug 'repo' -Name 'feature'
        Returns all the branches in the Repository named repo with the word feature in their name

    .PARAMETER Team
        Name of the team in Bitbucket.  Defaults to selected team if not provided.

    .PARAMETER RepoSlug
        Name of the repo in Bitbucket.

    .PARAMETER Name
        Name of the branch to search for.
#>
function Get-BitbucketRepositoryBranch {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipelineByPropertyName=$true,
                    HelpMessage='Name of the team in Bitbucket.  Defaults to selected team if not provided.')]
        [string]$Team = (Get-BitbucketSelectedTeam),
        [Parameter( Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage='The repository slug.')]
        [Alias('Slug')]
        [string]$RepoSlug,
        [Parameter(HelpMessage='Search for the specified branch name')]
        [string]$Name
    )

    Process {
        $endpoint = "repositories/$Team/$RepoSlug/refs/branches?q=name~`"$Name`""

        return Invoke-BitbucketAPI -Path $endpoint -Paginated
    }
}