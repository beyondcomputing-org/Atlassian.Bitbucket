function Compare-CustomObject {
  [OutputType('System.Boolean')]
  [CmdletBinding()]
  param(
      [Parameter(Position=0)]
      [PSObject]$ReferenceObject,
      [Parameter(Position=1)]
      [PSObject]$DifferenceObject,
      [Parameter()]
      [String[]]$IgnoreProperty
  )
  if($null -eq $ReferenceObject -and $null -eq $DifferenceObject){
    return $true
  }elseif($null -eq $ReferenceObject -or $null -eq $DifferenceObject){
    return $false
  }

  # Compare Object Type
  if($ReferenceObject.GetType() -ne $DifferenceObject.GetType()){
    return $false
  }

  # Check for basic types that allow direct equality comparison
  if(Confirm-IsComparableType $ReferenceObject){
    # Compare Value of basic type
    if($ReferenceObject -ne $DifferenceObject){
      return $false
    }
  }elseif($ReferenceObject.GetType().BaseType.Name -eq 'Array'){
    # Handle Array
    # Check Array Length Matches
    if($ReferenceObject.Length -ne $DifferenceObject.Length){
      return $false
    }elseif($ReferenceObject.Length -ne 0){
      # Check for Object arrays
      if(!(Confirm-IsComparableType $ReferenceObject[0])){
        $properties = ($ReferenceObject[0] | Get-Member | Where-Object -Property MemberType -In -Value @('Property', 'NoteProperty')).Name

        # Sort the object arrays before comparing
        $referenceArray = $ReferenceObject | Sort-Object -Property $properties
        $differenceArray = $DifferenceObject | Sort-Object -Property $properties
      }else{
        # Sort the arrays before comparing
        $referenceArray = $ReferenceObject | Sort-Object
        $differenceArray = $DifferenceObject | Sort-Object
      }

      # Check Values
      for ($i = 0; $i -lt $referenceArray.Count; $i++) {
        if(!(Compare-CustomObject $referenceArray[$i] $differenceArray[$i])){
          return $false
        }
      }
    }
  }else{
    # Object Comparison
    # Compare Members
    $referenceMembers = ($ReferenceObject | Get-Member | `
      Where-Object -Property MemberType -In -Value @('Property', 'NoteProperty') | `
      Where-Object -Property Name -NotIn -Value $IgnoreProperty).Name | Sort-Object

    $differenceMembers = ($DifferenceObject | Get-Member | `
      Where-Object -Property MemberType -In -Value @('Property', 'NoteProperty') | `
      Where-Object -Property Name -NotIn -Value $IgnoreProperty).Name | Sort-Object

    if($null -eq $referenceMembers -and $null -eq $differenceMembers){
      Write-Warning 'The objects being compared contain no properties.  Thus the objects will always be equal.'
    }elseif($null -eq $referenceMembers -or $null -eq $differenceMembers){
      return $false
    }else{
      if(Compare-Object $referenceMembers $differenceMembers){
        return $false
      }

      foreach ($member in $referenceMembers) {
        # Compare Object
        if(!(Compare-CustomObject $ReferenceObject.$member $DifferenceObject.$member)){
          return $false
        }
      }
    }
  }

  # All Checks Passed
  return $true
}

function Confirm-IsComparableType{
  [OutputType('System.Boolean')]
  [CmdletBinding()]
  param(
      [Parameter(Position=0)]
      $Object
  )
  # Primatives + String
  $ComparableTypes = @('Boolean', 'Byte', 'SByte', 'Int16', 'UInt16', 'Int32', 'UInt32', 'Int64', 'UInt64', 'IntPtr', 'UIntPtr', 'Char', 'Double', 'Single', 'String')

  if($Object.GetType().BaseType.Name -eq 'ValueType' -or $Object.GetType().Name -in $ComparableTypes){
    return $true
  }
  return $false
}