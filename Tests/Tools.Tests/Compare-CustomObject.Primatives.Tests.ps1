Import-Module '.\Atlassian.Bitbucket.Tools.psm1' -Force

Describe 'Compare-CustomObject' {
    Context 'Correctly compares primative values' {
        It 'Equal Strings' {
            Compare-CustomObject 'string1' 'string1' | should be $true
        }

        It 'Non Equal Strings' {
            Compare-CustomObject 'string1' 'string2' | should be $false
        }

        It 'Equal Integers' {
            Compare-CustomObject 1 1 | should be $true
        }

        It 'Non Equal Integers' {
            Compare-CustomObject 1 2 | should be $false
        }

        It 'Equal Decimals' {
            Compare-CustomObject 1.11 1.11 | should be $true
        }

        It 'Non Equal Decimals' {
            Compare-CustomObject 1.11 1.12 | should be $false
        }

        It 'True Boolean' {
            Compare-CustomObject $true $true | should be $true
        }

        It 'False Boolean' {
            Compare-CustomObject $false $false | should be $true
        }

        It 'Non Equal Boolean' {
            Compare-CustomObject $true $false | should be $false
        }

        It 'Equal integer with String' {
            Compare-CustomObject 12 '12' | should be $false
        }

        It 'Equal Boolean with String' {
            Compare-CustomObject $false 'false' | should be $false
        }

        It 'Nulls' {
            Compare-CustomObject $null $null | should be $true
        }

        It 'Null and String' {
            Compare-CustomObject $null 'null' | should be $false
        }

        It 'String and Null' {
            Compare-CustomObject 'null' $null | should be $false
        }
    }
}