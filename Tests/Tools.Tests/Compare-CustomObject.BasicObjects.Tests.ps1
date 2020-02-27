Import-Module '.\Atlassian.Bitbucket.Tools.psm1' -Force

Describe 'Compare-CustomObject' {
    Context 'Correctly compares basic objects' {
        It 'Empty Objects' {
            $object1 = [PSCustomObject]@{
            }

            $object2 = [PSCustomObject]@{
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }

        It 'Empty Reference Object' {
            $object1 = [PSCustomObject]@{
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'Empty Difference Object' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value'
            }

            $object2 = [PSCustomObject]@{
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'Equal Empty Properties' {
            $object1 = [PSCustomObject]@{
                Property1 = $null
            }

            $object2 = [PSCustomObject]@{
                Property1 = $null
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }

        It 'Empty Reference Properties' {
            $object1 = [PSCustomObject]@{
                Property1 = $null
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'Empty Difference Properties' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value'
            }

            $object2 = [PSCustomObject]@{
                Property1 = $null
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }
        
        It 'With a single matching note property' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value'
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }

        It 'With a single non matching note property' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'With multiple matching note properties' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }

        It 'With multiple non matching note properties' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value'
                Property3 = 'Value3'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'With missing note properties' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }
        
        It 'With extra note properties' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'With different note properties' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property4 = 'Value3'
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'With different ordered note properties' {
            $object1 = [PSCustomObject][ordered]@{
                Property1 = 'Value1'
                Property2 = 'Value2'
                Property3 = 'Value3'
            }

            $object2 = [PSCustomObject][ordered]@{
                Property1 = 'Value1'
                Property3 = 'Value3'
                Property2 = 'Value2'
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }
    }
}