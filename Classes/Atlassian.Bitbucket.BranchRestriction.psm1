class BranchRestriction {
  [Nullable[int]]$id
  [string]$kind
  [string]$pattern
  [string]$branch_match_kind = 'glob'
  [string]$type = 'branchrestriction'

  BranchRestriction([PSCustomObject]$Object) {
    $this.id = $Object.id
    $this.kind = $Object.kind
    $this.pattern = $Object.pattern
    $this.branch_match_kind = $Object.branch_match_kind
    $this.type = $Object.type
  }

  BranchRestriction($Kind, $Pattern) {
    $this.kind = $Kind
    $this.pattern = $Pattern
  }
}

class MergeCheck : BranchRestriction {
  [ValidateSet(
    'require_approvals_to_merge',
    'require_default_reviewer_approvals_to_merge',
    'require_passing_builds_to_merge',
    'require_tasks_to_be_completed'
  )]
  [string]$kind
  [Nullable[int]]$value

  MergeCheck([PSCustomObject]$Object) : base($Object) {
    $this.value = $Object.value
  }

  MergeCheck($Kind, $Pattern, $Value) : base($Kind, $Pattern) {
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
}

class Group {
  [string]$name
  [string]$slug
  [string]$full_slug
  [Owner]$owner
  [string]$type = 'group'

  Group ([PSCustomObject]$Object) {
    $this.name = $Object.name
    $this.slug = $Object.slug
    $this.full_slug = $Object.full_slug
    $this.owner = $Object.owner
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
}