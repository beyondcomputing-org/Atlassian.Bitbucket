Import-Module '.\Atlassian.Bitbucket.Tools.psm1' -Force

Describe 'Compare-CustomObject' {
    Context 'Correctly compares complex objects' {
        It 'Equal nested objects' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                }
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                }
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }

        It 'Non Equal nested objects' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                }
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value1'
                }
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }

        It 'Equal nested arrays' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                    Array = @(
                        'item1',
                        'item2'
                    )   
                }
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                    Array = @(
                        'item1',
                        'item2'
                    )      
                }
            }
            Compare-CustomObject $object1 $object2 | should be $true
        }

        It 'Non Equal nested arrays' {
            $object1 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                    Array = @(
                        'item1',
                        'item2'
                    )   
                }
            }

            $object2 = [PSCustomObject]@{
                Property1 = 'Value1'
                Nested = [PSCustomObject]@{
                    Property2 = 'Value2'
                    Array = @(
                        'item1',
                        'item'
                    )      
                }
            }
            Compare-CustomObject $object1 $object2 | should be $false
        }
    }
}