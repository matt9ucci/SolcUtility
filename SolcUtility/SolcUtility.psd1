@{

RootModule           = 'SolcUtility'
ModuleVersion        = '0.0.0.180905'
CompatiblePSEditions = @('Core')
GUID                 = '5a0925f4-a45e-4bca-9b71-5da6674e8ee6'
Author               = 'Masatoshi Higuchi'
CompanyName          = 'N/A'
Copyright            = '(c) Masatoshi Higuchi. All rights reserved.'
Description          = 'PowerShell module for Solidity compiler (solc)'
PowerShellVersion    = '6.0'

FunctionsToExport = @('New-StandardJsonInput')
CmdletsToExport   = @()
VariablesToExport = @()
AliasesToExport   = @()

PrivateData = @{ PSData = @{
	Tags         = @('solidity', 'solc')
	LicenseUri   = 'https://github.com/matt9ucci/SolcUtility/blob/master/LICENSE'
	ProjectUri   = 'https://github.com/matt9ucci/SolcUtility'
	ReleaseNotes = 'Initial release'
} }

}
