Import-Module '.\Atlassian.Bitbucket.Tools.psm1' -Force

Describe 'Compare-CustomObject' {    
    Context 'Correctly compares arrays' {
        $array = @('item1', 'item2', 'item3')
        $arrayObject = @([PSCustomObject]@{1 = '1'},[PSCustomObject]@{1 = '2'})

        It 'Blank Arrays' {
            Compare-CustomObject @() @() | should be $true
        }

        It 'Blank Reference Array' {
            Compare-CustomObject @() @('item1', 'item2') | should be $false
        }

        It 'Blank Difference Array' {
            Compare-CustomObject @('item1', 'item2') @() | should be $false
        }

        It 'Equal Arrays' {
            Compare-CustomObject $array @('item1', 'item2', 'item3') | should be $true
        }

        It 'Non Equal Arrays' {
            Compare-CustomObject $array @('item1', 'item2', 'item') | should be $false
        }

        It 'Different Length Arrays' {
            Compare-CustomObject $array @('item1', 'item2') | should be $false
        }

        It 'UnSorted Arrays' {
            Compare-CustomObject $array @('item1', 'item3', 'item2') | should be $true
        }

        It 'Equal Object Arrays' {
            Compare-CustomObject $arrayObject @([PSCustomObject]@{1 = '1'}, [PSCustomObject]@{1 = '2'}) | should be $true
        }

        It 'Non Equal Object Arrays' {
            Compare-CustomObject $arrayObject @([PSCustomObject]@{1 = '1'}, [PSCustomObject]@{1 = '1'}) | should be $false
        }

        It 'UnSorted Object Arrays' {
            Compare-CustomObject $arrayObject @([PSCustomObject]@{1 = '2'}, [PSCustomObject]@{1 = '1'}) | should be $true
        }

        It 'Object Arrays with Different Properties' {
            Compare-CustomObject $arrayObject @([PSCustomObject]@{1 = '2'}, [PSCustomObject]@{2 = '1'}) | should be $false
        }
    }
}