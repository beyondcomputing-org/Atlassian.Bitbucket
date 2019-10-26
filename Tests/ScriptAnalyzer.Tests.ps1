Describe 'ScriptAnalyzer' {
	Context 'Validating ScriptAnalyzer installation' {
		It 'Checking Invoke-ScriptAnalyzer exists.' {
			{ Get-Command Invoke-ScriptAnalyzer -ErrorAction Stop } | Should Not Throw
		}
	}
}

Describe 'ScriptAnalyzer issues found' {
	$results = Invoke-ScriptAnalyzer *
	$scripts = $results.ScriptName | Get-Unique

	Context 'Checking results' {
		It 'Should have no issues' {
			$results.count | Should Be 0
		}
	}

	foreach ($script in $scripts) {
		Context $script {
			$issues = $results | Where-Object {$_.ScriptName -eq $script}

			foreach ($issue in $issues) {
				It "On line: $($issue.Line) - $($issue.Message)" {
					$true | Should Be $False
				}
			}
		}
	}
}