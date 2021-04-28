class BranchRestriction {
  [Nullable[int]]$id
  [string]$kind
  [string]$pattern
  [string]$branch_match_kind = 'glob'
  [string]$branch_type
  [string]$type = 'branchrestriction'

  BranchRestriction([PSCustomObject]$Object) {
    $this.id = $Object.id
    $this.kind = $Object.kind
    $this.pattern = $Object.pattern
    $this.branch_match_kind = $Object.branch_match_kind
    $this.branch_type = $Object.branch_type
    $this.type = $Object.type
  }

  BranchRestriction($Kind, $Target, [bool]$IsGlob) {
    $this.kind = $Kind
    if ($IsGlob){
      $this.pattern = $Target
    }
    else{
      $this.branch_match_kind = 'branching_model'
      $this.branch_type = $Target
    }    
  }
}

class MergeCheck : BranchRestriction {
  [ValidateSet(
    'allow_auto_merge_when_builds_pass',
    'enforce_merge_checks',
    'require_all_dependencies_merged',
    'require_approvals_to_merge',
    'require_default_reviewer_approvals_to_merge',
    'require_no_changes_requested',
    'require_passing_builds_to_merge',
    'require_tasks_to_be_completed',
    'reset_pullrequest_approvals_on_change',
    'reset_pullrequest_changes_requested_on_change'
  )]
  [string]$kind
  [Nullable[int]]$value

  MergeCheck([PSCustomObject]$Object) : base($Object) {
    $this.value = $Object.value
  }

  MergeCheck($Kind, $Target, $Value, [bool]$IsGlob) : base($Kind, $Target, $IsGlob) {
    $this.value = $value
  }
}

class PermissionCheck : BranchRestriction {
  [ValidateSet(
    'delete',
    'force',
    'push',
    'restrict_merges'
  )]
  [string]$kind
  [User[]]$users = @()
  [Group[]]$groups = @()

  PermissionCheck([PSCustomObject]$Object) : base($Object) {
    $this.users = $Object.users
    $this.groups = $Object.groups
  }

  PermissionCheck($Kind, $UUID, $Target, $IsGlob, $IsGroup) : base($Kind, $Target, $IsGlob) {
    if ($IsGroup) {
      $this.groups = [Group]::New($UUID)
    }
    else {
      $this.users = [User]::New($UUID)
    }
  }
}

class Group {
  [string]$name
  [string]$uuid
  [string]$slug
  [string]$full_slug
  [Owner]$owner
  [string]$type = 'group'

  Group ([PSCustomObject]$Object) {
    $this.name = $Object.name
    $this.uuid = $Object.uuid
    $this.slug = $Object.slug
    $this.full_slug = $Object.full_slug
    $this.owner = $Object.owner
  }

  Group ([string]$UUID) {
    $this.uuid = $UUID
  }

}

class Owner {
  [string]$username
  [string]$display_name
  [string]$type
  [string]$uuid

  Owner ([PSCustomObject]$Object) {
    $this.username = $Object.username
    $this.display_name = $Object.display_name
    $this.type = $Object.type
    $this.uuid = $Object.uuid
  }
}

class User {
  [string]$display_name
  [string]$uuid
  [string]$nickname
  [string]$type = 'user'
  [string]$account_id

  User ([PSCustomObject]$Object) {
    $this.display_name = $Object.display_name
    $this.uuid = $Object.uuid
    $this.nickname = $Object.nickname
    $this.account_id = $Object.account_id
  }

  User ([string]$UUID) {
    $this.uuid = $UUID
  }
}