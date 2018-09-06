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
