Import-Module -Name $PSScriptRoot\..\SolcUtility -Force

Describe 'New-StandardJsonInput' {
	Context "without parameters" {
		It "returns skeleton" {
			$expected = @"
{
  "language": "Solidity",
  "sources": {},
  "settings": {
    "outputSelection": {
      "*": {
        "*": [
          "*"
        ]
      }
    }
  }
}
"@
			New-StandardJsonInput | Should Be $expected
		}
	}
}

Describe 'New-StandardJsonInput -Path' {
	$helloWorld = "$PSScriptRoot\HelloWorld.sol"
	$greeter = "$PSScriptRoot\Greeter.sol"
	Context "without the parameter name" {
		It "returns 'urls'" {
			$j = New-StandardJsonInput $helloWorld | ConvertFrom-Json -AsHashtable
			$j.sources.ContainsKey("$helloWorld") | Should Be $true
			$j.sources["$helloWorld"].urls | Should Be @("$helloWorld")
		}
	}
	Context "multiple *.sol files" {
		It "returns multiple *.sol paths" {
			$j = New-StandardJsonInput -Path $helloWorld, $greeter | ConvertFrom-Json -AsHashtable
			$j.sources["$helloWorld"].urls | Should Be @("$helloWorld")
			$j.sources["$greeter"].urls | Should Be @("$greeter")
		}
	}
}

Describe 'New-StandardJsonInput -EvmVersion byzantium' {
	It "returns byzantium" {
		$j = New-StandardJsonInput -EvmVersion byzantium | ConvertFrom-Json -AsHashtable
		$j.settings.evmVersion | Should Be "byzantium"
	}
}
