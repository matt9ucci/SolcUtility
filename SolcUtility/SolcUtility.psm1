<#
.EXAMPLE
	New-StandardJsonInput $HOME\HelloWorld.sol
.EXAMPLE
	New-StandardJsonInput -Path $HOME\HelloWorld.sol -EvmVersion byzantium
#>
function New-StandardJsonInput {
	param (
		[Parameter(Position = 0, HelpMessage = '*.sol file location')]
		[Alias('Url')]
		[string[]]$Path,
		[ValidateSet('homestead', 'tangerineWhistle', 'spuriousDragon', 'byzantium', 'constantinople')]
		[string]$EvmVersion,
		[uint64]$OptimizeRuns,
		[ValidateSet('abi', 'ast', 'devdoc', 'evm', 'evm.assembly', 'evm.bytecode', 'evm.bytecode.linkReferences', 'evm.bytecode.object', 'evm.bytecode.opcodes', 'evm.bytecode.sourceMap', 'evm.deployedBytecode', 'evm.deployedBytecode.linkReferences', 'evm.deployedBytecode.object', 'evm.deployedBytecode.opcodes', 'evm.deployedBytecode.sourceMap', 'evm.gasEstimates', 'evm.legacyAssembly', 'evm.methodIdentifiers', 'ewasm', 'ewasm.wast', 'ewasm.wasm', 'ir', 'legacyAST', 'metadata', 'userdoc')]
		[string[]]$Artifact
	)

	$hashTable = [ordered]@{
		language = "Solidity"
		sources  = @{}
		settings = @{
			outputSelection = @{
				'*' = @{ '*' = , '*' }
			}
		}
	}

	foreach ($p in $Path) {
		$hashTable.sources["$p"] = @{ 'urls' = , "$p" }
	}

	#region settings
	if ($EvmVersion) {
		$hashTable.settings.evmVersion = $EvmVersion
	}

	if ($OptimizeRuns) {
		$hashTable.settings.optimizer = @{
			enabled = $true
			runs    = $OptimizeRuns
		}
	}

	if ($Artifact) {
		$hashTable.settings.outputSelection.'*' = @{ '*' = $Artifact }
	}
	#endregion

	$hashTable | ConvertTo-Json -Depth 4
}

<#
.SYNOPSIS
	Converts from solc standard JSON input to output
.EXAMPLE
	New-StandardJsonInput $HOME\HelloWorld.sol | ConvertTo-StandardJsonOutput
#>
function ConvertTo-StandardJsonOutput {
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$StandardJsonInput
	)

	$StandardJsonInput | solc --standard-json --allow-paths .
}

<#
.SYNOPSIS
	Estimates gas
.EXAMPLE
	Measure-GasEstimate $HOME\HelloWorld.sol
.EXAMPLE
	Measure-GasEstimate -Path $HOME\HelloWorld.sol -EvmVersion byzantium -Sum
#>
function Measure-GasEstimate {
	param (
		[Parameter(Position = 0, HelpMessage = '*.sol file location')]
		[Alias('Url')]
		[string[]]$Path,
		[ValidateSet('homestead', 'tangerineWhistle', 'spuriousDragon', 'byzantium', 'constantinople')]
		[string]$EvmVersion,
		[uint64]$OptimizeRuns,
		[Alias('Total')]
		[switch]$Sum
	)

	$PSBoundParameters.Remove('Sum')
	$output = solcps @PSBoundParameters | ConvertFrom-Json -AsHashtable

	foreach ($contracts in $output.contracts.Values) {
		foreach ($name in $contracts.Keys) {
			$estimate = $contracts.$name.evm.gasEstimates
			$creation = $estimate.creation
			$external = $estimate.external
			$internal = $estimate.internal
			if ($Sum) {
				[pscustomobject]@{
					Name     = $name
					Creation = $creation.totalCost
					External = if ($external.Values -contains 'infinite') {
						'infinite'
					} else {
						($external.Values | Measure-Object -Sum).Sum
					}
					Internal = if ($internal.Values -contains 'infinite') {
						'infinite'
					} else {
						($internal.Values | Measure-Object -Sum).Sum
					}
				}
			} else {
				[pscustomobject]@{
					Name     = $name
					Creation = $creation
					External = $external
					Internal = $internal
				}
			}
		}
	}
}

<#
.SYNOPSIS
	Returns solc version (e.g. 0.4.24)
.EXAMPLE
	Get-SolcVersion
	# returns 0.4.24
.EXAMPLE
	Get-SolcVersion -Full
	# returns 0.4.24+commit.6ae8fb59.Windows.msvc
#>
function Get-SolcVersion([switch]$Full) {
	$pattern = if ($Full) { 'Version:(.*)' } else { 'Version:(.*)\+.*' }
	(solc --version | Select-String $pattern -List).Matches[0].Groups[1].Value.Trim()
}

<#
.SYNOPSIS
	Compiles Solidity source code like solc
.EXAMPLE
	solcps $HOME\HelloWorld.sol
.EXAMPLE
	solcps -Path $HOME\HelloWorld.sol -EvmVersion byzantium
#>
function solcps {
	param (
		[Parameter(Position = 0, HelpMessage = '*.sol file location')]
		[Alias('Url')]
		[string[]]$Path,
		[ValidateSet('homestead', 'tangerineWhistle', 'spuriousDragon', 'byzantium', 'constantinople')]
		[string]$EvmVersion,
		[uint64]$OptimizeRuns,
		[ValidateSet('abi', 'ast', 'devdoc', 'evm', 'evm.assembly', 'evm.bytecode', 'evm.bytecode.linkReferences', 'evm.bytecode.object', 'evm.bytecode.opcodes', 'evm.bytecode.sourceMap', 'evm.deployedBytecode', 'evm.deployedBytecode.linkReferences', 'evm.deployedBytecode.object', 'evm.deployedBytecode.opcodes', 'evm.deployedBytecode.sourceMap', 'evm.gasEstimates', 'evm.legacyAssembly', 'evm.methodIdentifiers', 'ewasm', 'ewasm.wast', 'ewasm.wasm', 'ir', 'legacyAST', 'metadata', 'userdoc')]
		[string[]]$Artifact
	)

	New-StandardJsonInput @PSBoundParameters | ConvertTo-StandardJsonOutput
}

<#
.SYNOPSIS
	Selects objects from solc standard JSON output
#>
function Select-StandardJsonOutput {
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$StandardJsonOutput,
		[Parameter(Position = 1, Mandatory)]
		[ValidateSet('Contract', 'ABI', 'Assembly', 'Bytecode', 'Opcode')]
		[string]$Item
	)

	$hashTable = $StandardJsonOutput | ConvertFrom-Json -AsHashtable
	$selected = @{}
	switch ($Item) {
		Contract {
			foreach ($contract in $hashTable.contracts.Values) {
				foreach ($key in $contract.keys) {
					$selected.Add($key, ($contract[$key] | ConvertTo-Json -Depth 4 -Compress))
				}
			}
		}
		ABI {
			foreach ($contract in $hashTable.contracts.Values) {
				foreach ($key in $contract.keys) {
					$selected.Add($key, ($contract[$key].abi | ConvertTo-Json -Compress))
				}
			}
		}
		Assembly {
			foreach ($contract in $hashTable.contracts.Values) {
				foreach ($key in $contract.keys) {
					$selected.Add($key, ($contract[$key].evm.assembly))
				}
			}
		}
		Bytecode {
			foreach ($contract in $hashTable.contracts.Values) {
				foreach ($key in $contract.keys) {
					$selected.Add($key, ($contract[$key].evm.bytecode.object))
				}
			}
		}
		Opcode {
			foreach ($contract in $hashTable.contracts.Values) {
				foreach ($key in $contract.keys) {
					$selected.Add($key, ($contract[$key].evm.bytecode.opcodes))
				}
			}
		}
	}
	$selected
}
