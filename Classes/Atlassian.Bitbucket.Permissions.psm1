class GroupPermissionV1 {
  [String]$groupslug
  [ValidateSet('read','write','admin')]
  [String]$privilege

  GroupPermissionV1 ([PSCustomObject]$Object) {
    $this.groupslug = $Object.group.slug
    $this.privilege = $Object.privilege
  }

  GroupPermissionV1 ([String]$GroupSlug, [String]$Privilege) {
    $this.groupslug = $GroupSlug
    $this.privilege = $Privilege
  }
}

class UserV1 {
  [String]$display_name
  [String]$uuid
  [String]$nickname
  [String]$account_id

  UserV1 ([PSCustomObject]$Object) {
    $this.display_name = $Object.display_name
    $this.uuid = $Object.uuid
    $this.nickname = $Object.nickname
    $this.account_id = $Object.account_id
  }
}